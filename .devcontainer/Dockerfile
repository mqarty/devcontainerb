FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y \
    software-properties-common

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    gnupg \
    dirmngr \
    software-properties-common \
    bash-completion \
    curl \
    default-jre \
    dnsutils \
    git \
    iputils-ping \
    jq \
    nodejs \
    npm \
    openssh-client \
    pipx \
    postgresql \
    python3 \
    python3-pip \
    sudo \
    tree \
    unzip \
    vim \
    wget \
    zip

# Validate Node
RUN node --version && npm --version && npx --version

# Install UV
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# # Install Microsoft package repository and .NET SDK (use 8.0 for stable availability)
RUN add-apt-repository -y ppa:dotnet/backports && \
    apt-get update -y && \
    apt-get install -y dotnet-sdk-9.0 && \
    /bin/rm -rf /var/lib/apt/lists/*

# Install python-level packages that aren't always available as apt packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends python3-boto3 python3-poetry && \
    /bin/rm -rf /var/lib/apt/lists/*

# Configure git
RUN git config --global init.defaultBranch main
RUN git config --global pull.rebase true

# Set Container time to my local time
RUN ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

# Install UV
