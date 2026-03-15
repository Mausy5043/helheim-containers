#!/usr/bin/env bash
set -eu

CONTAINER_NAME="octave"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Boarding ${CONTAINER_NAME}..."

podman exec -it "${CONTAINER_NAME}" /bin/bash

echo "${CONTAINER_NAME} is deboarded"
