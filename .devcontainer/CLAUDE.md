# Claude Instructions

## Container-First Command Policy

When executing Python commands in this workspace, always run them inside the Docker Compose service container.

### Required command pattern

- Use: `docker compose exec <container_name> <args...>`
- Default container/service name in this workspace: `app`
- Preferred examples:
  - `docker compose exec app python -m pytest -v`
  - `docker compose exec app python -m voice_core.scripts.some_script`
  - `docker compose exec app sh -lc "python -V"`

### Prohibited patterns

- Do not use `poetry run python ...`
- Do not use `poetry run pytest ...`
- Do not execute Python directly on the host when an equivalent container command is available.

### Fallback behavior

- If `app` is unavailable, select the correct service from `docker-compose.yml` and still use `docker compose exec <service> ...`.
- If containers are not running, start them first, then run commands with `docker compose exec`.
