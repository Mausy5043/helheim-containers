#!/usr/bin/env bash
set -eu

IMAGE_TAG="mypython"
CONTAINER_NAME="mypython"

# Stop and remove any existing container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Boarding ${CONTAINER_NAME}..."

podman run -it --rm \
  --name "${CONTAINER_NAME}" \
  --volume /etc/localtime:/etc/localtime:ro \
  "${IMAGE_TAG}"

echo "${CONTAINER_NAME} is deboarded"
