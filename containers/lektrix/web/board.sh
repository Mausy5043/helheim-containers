#!/usr/bin/env bash
set -eu

CONTAINER_NAME="lektrix_web"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Boarding ${CONTAINER_NAME}..."

podman exec -it "${CONTAINER_NAME}" /bin/bash 2>/dev/null || true

echo "${CONTAINER_NAME} is deboarded"
