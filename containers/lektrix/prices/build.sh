#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

IMAGE_TAG="lektrix/prices:latest"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}"  \
    --pull=always \
    --no-cache \
    --build-context lektrix=/home/beheer/git/lektrix \
    --file Containerfile \
    .

# cp -rv ./config/* /srv/containers/lektrix/config

printf "\nYou can now enable/start the lektrix-prices.service to run this container.\n\n"

exit 0
# shellcheck disable=SC2034
podman run -it --rm  \
    --name lektrix-prices-dev \
    -v /etc/localtime:/etc/localtime:ro \
    -v /home/beheer/git/lektrix/bin:/app/scripts:rw \
    -v /srv/containers/lektrix/data:/app/data:rw \
    -v /srv/containers/lektrix/config:/app/config:rw \
    lektrix/prices:latest \
    bash
