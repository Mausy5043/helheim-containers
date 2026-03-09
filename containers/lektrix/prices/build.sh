#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

IMAGE_TAG="lektrix/prices:latest"
CONTAINER_NAME="lektrix_prices"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}"  \
    --pull=newer \
    --build-context lektrix=/home/beheer/git/lektrix \
    --file Containerfile \
    .

echo
podman run \
       --rm \
       --name $CONTAINER_NAME \
       "${IMAGE_TAG}" \
       python3 -c "import pyarrow;
print('PyArrow version:', pyarrow.__version__);
import pandas;
print('Pandas version:', pandas.__version__);
import numpy;
print('Numpy version:', numpy.__version__)"

printf "\nYou can now enable/start the lektrix-prices.service to run this container.\n\n"

exit 0
# shellcheck disable=SC2034
podman run -it --rm  \
    --name lektrix-prices-dev \
    -v /etc/localtime:/etc/localtime:ro \
    -v /home/beheer/git/lektrix/bin:/app/scripts:rw \
    -v /srv/containers/lektrix/data:/app/data:rw \
    -v /srv/containers/lektrix/config:/app/config:rw \
    lektrix/prices:latest \
    bash
