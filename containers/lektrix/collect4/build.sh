#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

IMAGE_TAG="lektrix/collect4:latest"

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
       lektrix/collect4:latest \
       python3 -c "import pyarrow;
print('PyArrow version:', pyarrow.__version__);
import pandas;
print('Pandas version:', pandas.__version__);
import numpy;
print('Numpy version:', numpy.__version__)"

printf "\nYou can now enable/start the lektrix-collect4.service to run this container.\n\n"
