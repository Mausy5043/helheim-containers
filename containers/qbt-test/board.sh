#!/usr/bin/env bash
set -eu

CONTAINER_NAME="qbt_test"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

PORT=1340

echo "Boarding ${CONTAINER_NAME}..."

# shellcheck disable=SC2034
podman run -it --rm  \
    --name "${CONTAINER_NAME}" \
    --network=pasta \
    --dns=192.168.2.2 \
    --publish "${PORT}:${PORT}/tcp" \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /srv/containers/qbt-test/config:/qbt-test/config:rw \
    --volume /srv/containers/qbt-test/downloads:/qbt-test/downloads:rw \
    --volume /srv/containers/qbt-test/incomplete:/qbt-test/incomplete:rw \
    --volume /srv/containers/qbt-test/monitor:/qbt-test/monitor:rw \
    "${IMAGE_TAG}"

echo "${CONTAINER_NAME} is deboarded"
