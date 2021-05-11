# The MIT License
#
# Copyright (c) 2021, Serhiy Makarenko

FROM node:12-alpine AS base

ENV CHROME_BIN="/usr/bin/chromium-browser"
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"

WORKDIR /usr/src/app

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --no-cache upgrade && \
    apk add --no-cache udev ttf-opensans chromium ca-certificates dumb-init && \
    rm -rf /tmp/*

FROM base as build

ENV GRAFANA_RENDERER_VERSION=2.0.1
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

COPY --from=build /usr/src/app/node_modules node_modules
COPY --from=build /usr/src/app/build build
COPY --from=build /usr/src/app/proto proto
COPY --from=build /usr/src/app/dev.json config.json

EXPOSE 8081

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "build/app.js", "server", "--config=config.json"]
