#!/usr/bin/env bash
set -eu

IMAGE_TAG="lektrix/collect6:latest"
CONTAINER_NAME="lektrix_collect6"

echo "Boarding ${CONTAINER_NAME}..."
podman run -it --rm  \
    --name "${CONTAINER_NAME}" \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /home/beheer/git/lektrix/bin:/app/scripts:rw \
    --volume /srv/containers/lektrix/data:/app/data:rw \
    --volume /srv/containers/lektrix/config:/app/config:rw \
    --volume /srv/containers/lektrix/www:/app/www:rw \
    "${IMAGE_TAG}" \
    bash

#    --network=slirp4netns:allow_host_loopback=true \
#    --dns=192.168.2.2 \


echo "${CONTAINER_NAME} is deboarded"
