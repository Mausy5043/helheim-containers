#!/usr/bin/env bash
set -eu

CONTAINER_NAME="lektrix_collect4"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Boarding ${CONTAINER_NAME}..."

# Stop and remove any existing container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

# Error: slirp4netns support has been removed, use --network=pasta instead;
# --network=slirp4netns:allow_host_loopback=true \
podman run -it --rm  \
    --name "${CONTAINER_NAME}" \
    --network=host \
    --dns=192.168.2.3 \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /home/beheer/git/lektrix/bin:/app/scripts:rw \
    --volume /srv/containers/lektrix/data:/app/data:rw \
    --volume /srv/containers/lektrix/config:/app/config:rw \
    --volume /srv/containers/lektrix/www:/app/www:rw \
    "${IMAGE_TAG}" \
    /bin/bash


echo "${CONTAINER_NAME} is deboarded"
