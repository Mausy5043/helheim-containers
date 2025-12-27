#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

IMAGE_TAG="lektrix/trend:latest"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}"  \
    --build-context lektrix=/home/beheer/git/lektrix \
    --file Containerfile \
    .

# cp -rv ./config/* /srv/containers/lektrix/config

printf "\nYou can now enable/start the lektrix-trend.service to run this container.\n\n"

exit 0
# shellcheck disable=SC2034
podman run -it --rm  \
    -v /etc/localtime:/etc/localtime:ro \
    -v /home/beheer/git/lektrix/bin:/app/scripts:ro \
    -v /srv/containers/lektrix/data:/app/data:rw \
    -v /srv/containers/lektrix/www:/app/www:rw \
    lektrix/trend:latest \
    bash
