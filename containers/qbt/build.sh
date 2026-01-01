#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

IMAGE_TAG="qbt:latest"

podman build \
    --tag "${IMAGE_TAG}" \
    --pull=always \
    --no-cache \
    --file Containerfile \
    .


# printf "\nYou can now enable/start the qbt.service to run this container.\n\n"

exit 0
# below is example command to copy&paste to run container interactively
# shellcheck disable=SC2034

    # --network=slirp4netns:allow_host_loopback=true \
    # --dns=192.168.2.2 \
    # --volume /home/beheer/git/lektrix/bin:/app/scripts:rw \
    # --volume /srv/containers/lektrix/data:/app/data:rw \
    # --volume /srv/containers/lektrix/config:/app/config:rw \
    # --volume /srv/containers/lektrix/www:/app/www:rw \

podman run -it --rm  \
    --name qbt-dev \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /srv/containers/qbt/config:/qbt/config:rw,U \
    --entrypoint="/usr/bin/bash" \
    qbt:latest
podman run -it --rm  \
    --name qbt-dev \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /srv/containers/qbt/config:/qbt/config:rw,U \
    qbt:latest
