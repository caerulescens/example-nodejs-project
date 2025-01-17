ARG VERSION_DEBIAN=bookworm
ARG VERSION_NODE=21
ARG APP_PATH=/opt/app
ARG APP_HOST=0.0.0.0
ARG APP_PORT=3000
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
RUN set -ex \
    && groupadd --system --gid "${USER_GID}" "${USER}" \
    && useradd --system --uid "${USER_UID}" --gid "${USER_GID}" --no-create-home "${USER}" \
    && apt-get update \
    && apt-get purge -y --auto-remove \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

FROM base as builder
ARG APP_PATH
WORKDIR ${APP_PATH}
COPY package.json package-lock.json ./
RUN npm install
COPY . .

FROM base AS runtime
ARG APP_PATH
ARG APP_HOST
ARG APP_PORT
ARG USER
WORKDIR ${APP_PATH}
COPY --from=builder ${APP_PATH} ${APP_PATH}
USER ${USER}
CMD ["npm", "start"]
EXPOSE ${APP_PORT}
