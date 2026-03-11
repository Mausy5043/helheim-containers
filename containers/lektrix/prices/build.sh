#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

CONTAINER_NAME="lektrix_prices"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

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
print('PYARROW version:', pyarrow.__version__);
import pandas;
print('PANDAS version:', pandas.__version__);
import numpy;
print('NUMPY version:', numpy.__version__)"

printf "\nYou can now enable/start the lektrix-prices.service to run this container.\n\n"
