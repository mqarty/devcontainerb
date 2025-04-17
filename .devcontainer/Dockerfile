FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    bash-completion \
    curl \
    git \
    jq \
    python3-boto3 \
    python3-pip \
    sudo \
    unzip \
    vim \
    wget

# Configure git
RUN git config --global --add safe.directory /workspaces/devcontainerb
# RUN git config --system safe.directory /workspaces/<your-path>
# RUN git config --system core.hooksPath /workspaces/<your-path>/.git-hooks
