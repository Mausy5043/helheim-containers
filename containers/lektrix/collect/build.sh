#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

CONTAINER_NAME="lektrix_collect"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}" \
    --pull=newer \
    --build-context lektrix=/home/beheer/git/lektrix \
    --file Containerfile \
    .

echo
podman run \
       --rm \
       --name "${CONTAINER_NAME}" \
       "${IMAGE_TAG}" \
       python3 -c "import pyarrow;
print('PYARROW version:', pyarrow.__version__);
import pandas;
print('PANDAS version:', pandas.__version__);
import numpy;
print('NUMPY version:', numpy.__version__)"

printf "\nYou can now enable/start the lektrix-collect.service to run this container.\n\n"

exit 0
# shellcheck disable=SC2034
podman run -it --rm  \
    --name lektrix-collect-dev \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /home/beheer/git/lektrix/bin:/app/scripts:rw \
    --volume /srv/containers/lektrix/data:/app/data:rw \
    --volume /srv/containers/lektrix/config:/app/config:rw \
    --volume /srv/containers/lektrix/www:/app/www:rw \
    lektrix/collect:latest \
    bash

#    --network=slirp4netns:allow_host_loopback=true \
#    --dns=192.168.2.2 \
