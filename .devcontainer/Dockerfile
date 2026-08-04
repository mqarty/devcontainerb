FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

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
    zsh \
    fzf \
    tree \
    vim \
    # Network tools
    dnsutils \
    iputils-ping \
    openssh-client \
    erofs-utils \
    # Development tools
    git \
    gh \
    jq \
    make \
    sudo \
    # Python build dependencies for pyenv
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    # Language runtimes
    default-jre \
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

# Install Node.js 20.x for Twilio CLI compatibility
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    /bin/rm -rf /var/lib/apt/lists/*

# Install pyenv
RUN curl https://pyenv.run | bash

# Validate Node.js installation
RUN node --version && npm --version && npx --version

# Install UV (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Terraform (architecture-aware binary install)
ARG TERRAFORM_VERSION=1.10.5
RUN arch="$(dpkg --print-architecture)" && \
    case "$arch" in \
    amd64) tf_arch="amd64" ;; \
    arm64) tf_arch="arm64" ;; \
    *) echo "Unsupported architecture: $arch" && exit 1 ;; \
    esac && \
    curl -fsSLo /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${tf_arch}.zip" && \
    unzip -o /tmp/terraform.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/terraform && \
    rm -f /tmp/terraform.zip && \
    terraform -version

# Configure git
RUN git config --global init.defaultBranch main
RUN git config --global pull.rebase true

# Install AWS CLI (architecture-aware binary install)
RUN arch="$(dpkg --print-architecture)" && \
    case "$arch" in \
    amd64) aws_arch="x86_64" ;; \
    arm64) aws_arch="aarch64" ;; \
    *) echo "Unsupported architecture: $arch" && exit 1 ;; \
    esac && \
    curl -fsSLo /tmp/awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip" && \
    unzip -o /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip && \
    aws --version
COPY aws-config /root/.aws/config
COPY aws-credentials /root/.aws/credentials

# Install Twilio CLI and dev-phone plugin (combine into one layer)
# https://github.com/twilio-labs/dev-phone
RUN npm install -g --ignore-scripts twilio-cli && \
    twilio plugins:install @twilio-labs/plugin-dev-phone

# Install Claude CLI
RUN curl -fsSL https://claude.ai/install.sh | bash

RUN ln -sf /usr/share/zoneinfo/${TZ:-UTC} /etc/localtime

# SOPS — required by OTHER repos' local secret pipelines that run inside this
# shared devcontainer (e.g. the workflows repo's `make local-env` decrypts
# local/secrets.enc.json for the team Twilio secrets). devcontainerb itself no
# longer uses SOPS, but the image is shared across repos that still do.
RUN arch="$(dpkg --print-architecture)" && \
    curl -LO "https://github.com/getsops/sops/releases/download/v3.12.1/sops-v3.12.1.linux.${arch}" && \
    mv "sops-v3.12.1.linux.${arch}" /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# # DuckDb
# RUN curl https://install.duckdb.org | sh


# # Install .NET SDK (separate layer as it changes less frequently)
# RUN add-apt-repository -y ppa:dotnet/backports && \
#     apt-get update -y && \
#     apt-get install -y dotnet-sdk-9.0 && \
#     /bin/rm -rf /var/lib/apt/lists/*
# Install .NET SDK 9.0 via Microsoft package feed

# RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg && \
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" \
#     > /etc/apt/sources.list.d/microsoft-prod.list && \
#     apt-get update -y && \
#     apt-get install -y dotnet-sdk-9.0 && \
#     /bin/rm -rf /var/lib/apt/lists/*

# Google Cloud CLI
RUN apt-get update -y

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
    https://packages.cloud.google.com/apt cloud-sdk main" \
    | tee /etc/apt/sources.list.d/google-cloud-sdk.list

RUN apt-get update -y && apt-get install -y google-cloud-cli

CMD ["sleep", "infinity"]
