# General
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/SerhiyMakarenko/grafanalabs-renderer-dockerized/blob/grafanalabs-renderer-dockerized/stable/LICENSE)

A Grafana remote image renderer that handles rendering panels & dashboards to PNGs using headless chrome.

Since Grafana Labs for some reason not able to provide an image for architectures, different from amd64 I decide to fix this misunderstanding. This image provides an ability to run [grafana-image-renderer](https://hub.docker.com/r/grafana/grafana-image-renderer) container on hardware with ARM CPU.

# Details
Currently, the image supports the following CPU architectures:
 - x86_64 (amd64);
 - armhf (arm32v6);
 - aarch6 (arm64v8).

This means that the image can be used on regular PC's with Intel CPU as well as on single-board computers like Raspberry Pi with ARM CPU.

# Usage
To run container you need to execute command listed below:
```
docker run -d --name grafanalabs-image-renderer \
    serhiymakarenko/grafanalabs-image-renderer:latest
```

# Related
- [Support for arm cpu #7](https://github.com/grafana/grafana-image-renderer/issues/7);
- [Grafana Image Renderer official image](https://hub.docker.com/r/grafana/grafana-image-renderer);
