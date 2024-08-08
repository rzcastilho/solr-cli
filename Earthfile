VERSION 0.7

setup:
    ARG ELIXIR_VERSION=1.16.0
    ARG OTP_VERSION=26.2.1
    ARG ALPINE_VERSION=3.18.4

    FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION}

    RUN apk update \
        && apk upgrade \
        && apk add build-base git curl gpg dirmngr gawk xz 7zip bash

    ENV ASDF_DIR=/root/.asdf

    RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0

    # Add asdf to PATH, so it can be run in this Dockerfile
    ENV PATH="$PATH:/root/.asdf/bin"

    # Add asdf shims to PATH, so installed executables can be run in this Dockerfile
    ENV PATH=$PATH:/root/.asdf/shims

    RUN asdf plugin add zig \
        && asdf install zig 0.13.0 \
        && asdf global zig 0.13.0
        
    WORKDIR /app

    RUN mix local.hex --force && \
        mix local.rebar --force

build:
    ARG MIX_ENV=prod
    FROM +setup
    ENV MIX_ENV=${MIX_ENV}

    COPY mix.exs mix.lock ./
    RUN mix deps.get --only $MIX_ENV
    RUN mkdir config

    COPY config/config.exs config/${MIX_ENV}.exs config/
    RUN mix deps.compile
    
    COPY lib lib

    RUN mix compile

    COPY config/runtime.exs config/

release:
    FROM +build
    RUN mix release
    SAVE ARTIFACT burrito_out AS LOCAL assets
