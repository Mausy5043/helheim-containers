#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

IMAGE_TAG="lektrix/trend:latest"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}"  \
    --file Containerfile \
    .

# cp -rv ./config/* /srv/containers/lektrix/config

printf "\nYou can now enable/start the lektrix-trend.service to run this container.\n\n"
