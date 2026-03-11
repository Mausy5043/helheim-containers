#!/usr/bin/env bash
set -eu

CONTAINER_NAME="lektrix_collect6"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Boarding ${CONTAINER_NAME}..."

# Stop and remove any existing container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

podman run -it --rm  \
    --name "${CONTAINER_NAME}" \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /home/beheer/git/lektrix/bin:/app/scripts:rw \
    --volume /srv/containers/lektrix/data:/app/data:rw \
    --volume /srv/containers/lektrix/config:/app/config:rw \
    --volume /srv/containers/lektrix/www:/app/www:rw \
    "${IMAGE_TAG}" \
    /bin/bash

#    --network=slirp4netns:allow_host_loopback=true \
#    --dns=192.168.2.2 \


echo "${CONTAINER_NAME} is deboarded"
