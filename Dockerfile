# syntax=docker/dockerfile:1

FROM ubuntu:latest AS builder-base

LABEL org.opencontainers.image.authors="victor@sixtop.net"

# Install dependencies
RUN apt update && apt upgrade -y
RUN apt install -y bash git build-essential python3 python3-dev python3-venv curl nodejs npm vim
RUN curl -sSL https://install.python-poetry.org | python3 -
RUN curl https://sh.rustup.rs | sh -s -- -y
RUN curl https://bootstrap.pypa.io/get-pip.py | python3 -

# Setup environment
RUN ln -s /usr/bin/python3 /usr/bin/python
ENV PATH="/root/.local/bin:/root/.cargo/bin:$PATH"
SHELL ["/bin/bash", "-c"]
RUN rustup update -- nightly && rustup default nightly

# Checkpoint
RUN git --version && make --version && python --version && pip --version && node --version && npm --version && poetry --version && rustc --version && cargo --version

# Get sources
WORKDIR /user/src
RUN git clone --recurse-submodules -j8 -b dev https://github.com/sixtop/activitywatch.git

WORKDIR /user/src/activitywatch
RUN python -m venv venv
ENV VIRTUAL_ENV="/user/src/activitywatch/venv"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

FROM builder-base AS make
RUN make build
