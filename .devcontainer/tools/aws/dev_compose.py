#!/usr/bin/python3
"""AWS SSO pre-auth wrapper for docker compose.

Usage:
  python .devcontainer/tools/aws_compose.py up
  python .devcontainer/tools/aws_compose.py up --build
  python .devcontainer/tools/aws_compose.py logs -f app

Environment:
  AWS_PROFILE (default: dev) - profile passed to `aws login --profile <profile>`

Notes:
  - Authenticates with AWS SSO, exports credentials, and forwards arguments to `docker compose`.
  - Exits with the same code as the docker compose command.
"""

from __future__ import annotations

import os
import subprocess
from typing import Dict, List

import typer

app = typer.Typer(
    add_completion=False,
    context_settings={"allow_extra_args": True, "ignore_unknown_options": True},
)


def run_cmd(cmd: List[str], env: Dict[str, str] | None = None) -> int:
    """Run a shell command and stream output, returning the exit code."""
    proc = subprocess.Popen(cmd, env=env)
    proc.communicate()
    return proc.returncode


def credentials_are_expired(profile: str) -> bool:
    """Check if AWS credentials for profile are expired.

    Returns True if credentials are expired or invalid, False if still valid.
    """
    try:
        subprocess.check_output(
            ["aws", "sts", "get-caller-identity", "--profile", profile],
            stderr=subprocess.DEVNULL,
            text=True,
        )
        return False  # Credentials are valid
    except subprocess.CalledProcessError:
        return True  # Credentials are expired or invalid


def get_aws_credentials(profile: str) -> Dict[str, str]:
    """Export AWS credentials from profile and return as environment dict.

    Uses `aws configure export-credentials` to get temporary credentials
    after SSO login, then parses the output into environment variables.
    """
    try:
        # Run aws configure export-credentials to get credentials
        creds_cmd = [
            "aws",
            "configure",
            "export-credentials",
            "--profile",
            profile,
            "--format",
            "env-no-export",
        ]
        creds_output = subprocess.check_output(creds_cmd, text=True)

        # Parse the output (format: VAR=value, one per line)
        env = os.environ.copy()
        for line in creds_output.strip().split("\n"):
            line = line.strip()
            if not line or "=" not in line:
                continue
            # Remove 'export ' prefix if present
            if line.startswith("export "):
                line = line[7:]  # len('export ') = 7
            key, value = line.split("=", 1)
            # Remove quotes if present
            value = value.strip("\"'")
            env[key] = value
        return env
    except subprocess.CalledProcessError as e:
        typer.echo(f"❌ Failed to export AWS credentials: {e}")
        raise typer.Exit(code=1)


@app.command(
    context_settings={"allow_extra_args": True, "ignore_unknown_options": True}
)
def compose(
    ctx: typer.Context,
    profile: str = typer.Option(
        "dev", "--profile", "-p", envvar="AWS_PROFILE", help="AWS profile for aws login"
    ),
    dry_run: bool = typer.Option(
        False, "--dry-run", help="Show commands without executing"
    ),
):
    """Run docker compose after ensuring AWS SSO login and exporting credentials."""
    compose_args = ctx.args
    if not compose_args:
        typer.echo(
            "Usage: python .devcontainer/tools/aws_compose.py <docker compose args>"
        )
        raise typer.Exit(code=1)

    compose_cmd = ["docker", "compose", *compose_args]

    # Skip AWS login for commands that don't need credentials
    skip_login_commands = ["down", "ps", "logs", "stop", "kill", "rm"]
    needs_login = not any(cmd in compose_args for cmd in skip_login_commands)

    if needs_login:
        # Check if credentials are already valid before logging in
        if credentials_are_expired(profile):
            login_cmd = ["aws", "login", "--profile", profile]
            typer.echo(f"🔐 Credentials expired. Running: {' '.join(login_cmd)}")
            if not dry_run:
                login_rc = run_cmd(login_cmd)
                if login_rc != 0:
                    typer.echo(f"❌ aws login failed with exit code {login_rc}")
                    raise typer.Exit(code=login_rc)
            else:
                typer.echo("(dry-run) skipping execution")
        else:
            typer.echo("✅ Credentials are still valid, skipping login")

        typer.echo(f"📋 Exporting AWS credentials for profile '{profile}'")
        if not dry_run:
            env = get_aws_credentials(profile)
            typer.echo("✅ Credentials exported")
        else:
            env = os.environ.copy()
            typer.echo("(dry-run) skipping credential export")
    else:
        typer.echo(f"⏩ Skipping AWS login for '{compose_args[0]}' command")
        env = os.environ.copy()
        # Set dummy AWS vars to prevent docker-compose warnings
        env.setdefault("AWS_ACCESS_KEY_ID", "")
        env.setdefault("AWS_SECRET_ACCESS_KEY", "")
        env.setdefault("AWS_REGION", "us-east-1")
        env.setdefault("AWS_DEFAULT_REGION", "us-east-1")
        env.setdefault("AWS_SESSION_TOKEN", "")

    typer.echo(f"🐳 Running: {' '.join(compose_cmd)}")
    if dry_run:
        typer.echo("(dry-run) skipping execution")
        raise typer.Exit(code=0)

    compose_rc = run_cmd(compose_cmd, env=env)
    raise typer.Exit(code=compose_rc)


def main() -> None:
    app()


if __name__ == "__main__":
    main()
