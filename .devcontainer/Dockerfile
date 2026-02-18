FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Combine all apt installations to reduce layers and improve caching
# Order: base tools, then language runtimes, then development tools
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    # Base utilities
    ca-certificates \
    apt-transport-https \
    gnupg \
    dirmngr \
    software-properties-common \
    curl \
    wget \
    unzip \
    zip \
    # Shell and terminal tools
    bash-completion \
    fzf \
    tree \
    vim \
    zsh \
    # Network tools
    dnsutils \
    iputils-ping \
    openssh-client \
    # Development tools
    git \
    jq \
    sudo \
    # Language runtimes
    default-jre \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-boto3 \
    python3-jinja2 \
    python3-poetry \
    python3-pydantic \
    python3-typer \
    python3-yaml  \
    pipx \
    postgresql && \
    /bin/rm -rf /var/lib/apt/lists/*

RUN pipx install pre-commit

# Validate Node.js installation
RUN node --version && npm --version && npx --version

# Install UV (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install .NET SDK (separate layer as it changes less frequently)
RUN add-apt-repository -y ppa:dotnet/backports && \
    apt-get update -y && \
    apt-get install -y dotnet-sdk-9.0 && \
    /bin/rm -rf /var/lib/apt/lists/*

# Configure git
RUN git config --global init.defaultBranch main
RUN git config --global pull.rebase true

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    aws --version
COPY aws-config /root/.aws/config
COPY aws-credentials /root/.aws/credentials

# Install Twilio CLI and dev-phone plugin (combine into one layer)
# https://github.com/twilio-labs/dev-phone
RUN npm install -g twilio-cli && \
    twilio plugins:install @twilio-labs/plugin-dev-phone

RUN ln -sf /usr/share/zoneinfo/${TZ:-UTC} /etc/localtime
