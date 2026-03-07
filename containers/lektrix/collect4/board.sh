#!/usr/bin/env bash
set -eu

IMAGE_TAG="lektrix/collect4:latest"
CONTAINER_NAME="lektrix_collect4"


echo "Boarding ${CONTAINER_NAME}..."
podman exec -it "${CONTAINER_NAME}" /bin/bash 2>/dev/null || true
podman run -it --rm  \
    --name ${CONTAINER_NAME} \
    --network=slirp4netns:allow_host_loopback=true \
    --dns=192.168.2.2 \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /home/beheer/git/lektrix/bin:/app/scripts:rw \
    --volume /srv/containers/lektrix/data:/app/data:rw \
    --volume /srv/containers/lektrix/config:/app/config:rw \
    --volume /srv/containers/lektrix/www:/app/www:rw \
    "${IMAGE_TAG}" \
    bash


echo "${CONTAINER_NAME} is deboarded"
