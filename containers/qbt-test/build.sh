#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

IMAGE_TAG="qbt-test:latest"

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

podman run -it --rm  \
    --name qbt-dev \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /srv/containers/qbt-test/config:/qbt-test/config:rw,U \
    --volume /srv/containers/qbt-test/downloads:/qbt-test/downloads:rw,U \
    --volume /srv/containers/qbt-test/incomplete:/qbt-test/incomplete:rw,U \
    --volume /srv/containers/qbt-test/monitor:/qbt-test/monitor:rw,U \
    --entrypoint="/usr/bin/bash" \
    qbt-test:latest

# shellcheck disable=SC2034
podman run -it --rm  \
    --name qbt-dev \
    --network=pasta \
    --dns=192.168.2.2 \
    --publish 1340:1340/tcp \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /srv/containers/qbt-test/config:/qbt-test/config:rw \
    --volume /srv/containers/qbt-test/downloads:/qbt-test/downloads:rw \
    --volume /srv/containers/qbt-test/incomplete:/qbt-test/incomplete:rw \
    --volume /srv/containers/qbt-test/monitor:/qbt-test/monitor:rw \
    qbt-test:latest
