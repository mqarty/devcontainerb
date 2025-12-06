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
    zip && \
    rm -rf /var/lib/apt/lists/*

RUN node --version && npm --version && npx --version

# # Install Microsoft package repository and .NET SDK (use 8.0 for stable availability)
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/24.04/prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends dotnet-sdk-8.0 && \
    rm -rf /var/lib/apt/lists/*

# Install python-level packages that aren't always available as apt packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends python3-boto3 python3-poetry && \
    rm -rf /var/lib/apt/lists/*

# Configure git
RUN git config --global init.defaultBranch main
RUN git config --global pull.rebase true

# Set Container time to my local time
RUN ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime