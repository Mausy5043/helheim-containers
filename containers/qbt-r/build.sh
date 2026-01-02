#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

IMAGE_TAG="qbt-r:latest"

podman build \
    --tag "${IMAGE_TAG}" \
    --file Containerfile \
    .

# not used for testing
    # --pull=always \
    # --no-cache \

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
    --name qbt-r-dev \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /srv/containers/qbt-r/config:/qbt-r/config:rw,U \
    --volume /srv/containers/qbt-r/downloads:/qbt-r/downloads:rw,U \
    --volume /srv/containers/qbt-r/incomplete:/qbt-r/incomplete:rw,U \
    --volume /srv/containers/qbt-r/monitor:/qbt-r/monitor:rw,U \
    --entrypoint="/usr/bin/bash" \
    qbt-r:latest

# shellcheck disable=SC2034
podman run -it --rm  \
    --name qbt-r-dev \
    --network=pasta \
    --dns=192.168.2.2 \
    --publish 1340:1340/tcp \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /srv/containers/qbt-r/config:/qbt-r/config:rw \
    --volume /srv/containers/qbt-r/downloads:/qbt-r/downloads:rw \
    --volume /srv/containers/qbt-r/incomplete:/qbt-r/incomplete:rw \
    --volume /srv/containers/qbt-r/monitor:/qbt-r/monitor:rw \
    qbt-r:latest
