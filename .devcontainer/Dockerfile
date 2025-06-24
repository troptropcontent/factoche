FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG RUBY_VERSION=3.3.6
ENV RBENV_ROOT="/usr/local/rbenv"
ENV PATH="${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:${PATH}"

RUN apt-get update \
    && apt-get install -y \
    autoconf \
    bison \
    rustc \
    libyaml-dev \
    libreadline6-dev \
    zlib1g-dev \
    libncurses5-dev \
    libffi-dev \
    libpq-dev \
    curl \
    git \
    build-essential \
    vim \
    gpg \
    && rm -rf /var/lib/apt/lists/*

# Install 1Password CLI
RUN curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
    tee /etc/apt/sources.list.d/1password.list && \
    mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
    mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg && \
    apt-get update && \
    apt-get install -y 1password-cli && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} \
    && git clone https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build 

# Install Ruby and initialize rbenv
RUN eval "$(rbenv init -)" \
    && rbenv install ${RUBY_VERSION} \
    && rbenv global ${RUBY_VERSION}

RUN gem install ruby-lsp 
RUN gem install lefthook 

WORKDIR /factoche
