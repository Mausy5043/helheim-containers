#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

IMAGE_TAG="lektrix/web:latest"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}"  \
    --pull=always \
    --no-cache \
    --file Containerfile \
    .

cp -rv ./config/* /srv/containers/lektrix/config

printf "\nYou can now enable/start the lektrix-web.service to run this container.\n\n"

exit 0
# shellcheck disable=SC2034
podman run -it --rm \
    --name lektrix-web \
    --publish 18080:80 \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /srv/containers/lektrix/www:/var/www/html:ro \
    --volume /srv/containers/lektrix/config/lighttpd.conf:/etc/lighttpd/lighttpd.conf:ro \
      lektrix/web:latest
