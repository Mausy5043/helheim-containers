#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

IMAGE_TAG="lektrix/webserver:latest"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}"  \
    --file Containerfile \
    .

cp ./config/* /srv/containers/lektrix/config

echo
echo "You can run the container with: podman run -d -p 8080:80 ${IMAGE_TAG}"
