#!/usr/bin/env bash
set -eu

CONTAINER_NAME="octave"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Boarding ${CONTAINER_NAME}..."

podman run --rm -it --name "${CONTAINER_NAME}" "${IMAGE_TAG}"

echo "${CONTAINER_NAME} is deboarded"
