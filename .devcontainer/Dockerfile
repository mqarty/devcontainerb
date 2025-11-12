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
    pipx \
    postgresql \
    python3 \
    python3-pip \
    sudo \
    unzip \
    vim \
    wget \
    zip && \
    rm -rf /var/lib/apt/lists/*

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
# See setup-git-safe.sh