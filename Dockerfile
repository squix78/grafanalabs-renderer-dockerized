# The MIT License
#
# Copyright (c) 2022, Serhiy Makarenko

FROM node:14-alpine3.11 AS base

ENV CHROME_BIN="/usr/bin/chromium-browser"
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"

WORKDIR /usr/src/app

RUN apk --no-cache upgrade && \
    apk add --no-cache udev ttf-opensans unifont chromium ca-certificates dumb-init && \
    rm -rf /tmp/*

FROM base as build

ENV GRAFANA_RENDERER_VERSION=3.2.0
ENV CXXFLAGS="-Wno-ignored-qualifiers -Wno-stringop-truncation -Wno-cast-function-type"

RUN apk add git && \
    git clone https://github.com/grafana/grafana-image-renderer.git && \
    cd grafana-image-renderer/ && \
    git fetch --all --tags && \
    git checkout tags/v${GRAFANA_RENDERER_VERSION} -b v${GRAFANA_RENDERER_VERSION} && \
    cd .. && \
    mv grafana-image-renderer/* /usr/src/app/ && \
    rm -rf grafana-image-renderer

RUN apk add --no-cache libc6-compat python alpine-sdk
RUN npm install -g node-gyp
RUN npm install --build-from-source=grpc

COPY . ./

RUN yarn install --pure-lockfile
RUN yarn run build

EXPOSE 8081

CMD [ "yarn", "run", "dev" ]

FROM base
LABEL maintainer="serhiy.makarenko@me.com"

ARG GF_UID="472"
ARG GF_GID="472"
ENV GF_PATHS_HOME="/usr/src/app"

WORKDIR $GF_PATHS_HOME

RUN addgroup -S -g $GF_GID grafana && \
    adduser -S -u $GF_UID -G grafana grafana && \
    mkdir -p "$GF_PATHS_HOME" && \
    chown -R grafana:grafana "$GF_PATHS_HOME"

ENV NODE_ENV=production

COPY --from=build /usr/src/app/node_modules node_modules
COPY --from=build /usr/src/app/build build
COPY --from=build /usr/src/app/proto proto
COPY --from=build /usr/src/app/default.json config.json
COPY --from=build /usr/src/app/plugin.json plugin.json

EXPOSE 8081

USER grafana

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "build/app.js", "server", "--config=config.json"]
