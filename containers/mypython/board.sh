#!/usr/bin/env bash
set -eu

CONTAINER_NAME="mypython13"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Boarding ${CONTAINER_NAME}..."

# Stop and remove any existing container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

podman run -it --rm \
  --name "${CONTAINER_NAME}" \
  --volume /etc/localtime:/etc/localtime:ro \
  "${IMAGE_TAG}"

echo "${CONTAINER_NAME} is deboarded"
