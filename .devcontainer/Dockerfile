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
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/rbenv/rbenv.git ${RBENV_ROOT} \
    && git clone https://github.com/rbenv/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build 

# Install Ruby and initialize rbenv
RUN eval "$(rbenv init -)" \
    && rbenv install ${RUBY_VERSION} \
    && rbenv global ${RUBY_VERSION}

RUN gem install ruby-lsp 
RUN gem install lefthook 

WORKDIR /factoche
