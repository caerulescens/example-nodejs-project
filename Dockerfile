ARG BUILD_PATH=/opt/build
ARG INSTALL_PATH=/opt/app
ARG HOST=0.0.0.0
ARG PORT=8000
ARG USER=appuser
ARG USER_GID=10001
ARG USER_UID=10001

FROM node:21-bookworm-slim AS base
LABEL maintainer="caerulescens <caerulescens.github@proton.me>"
ARG USER
ARG USER_GID
ARG USER_UID
ENV \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NOWARNINGS=yes
# todo: env PATH
RUN set -ex \
    && groupadd --system --gid "${USER_GID}" "${USER}" \
    && useradd --system --uid "${USER_UID}" --gid "${USER_GID}" --no-create-home "${USER}" \
    && apt-get update \
    && apt-get purge -y --auto-remove \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

FROM base as builder
ARG BUILD_PATH
WORKDIR $BUILD_PATH
# todo: cache dependencies
# todo: copy source files

FROM base AS runtime
ARG BUILD_PATH
ARG INSTALL_PATH
ARG PORT
ARG USER
WORKDIR $INSTALL_PATH
