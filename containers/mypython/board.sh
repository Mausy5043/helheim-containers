#!/usr/bin/env bash
set -eu

CONTAINER_NAME="mypython"

# Stop and remove any existing container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Boarding ${CONTAINER_NAME}..."

podman run -d -it --rm \
  --name "${CONTAINER_NAME}" \
  --volume /etc/localtime:/etc/localtime:ro \
  "${CONTAINER_NAME}"

echo "${CONTAINER_NAME} is deboarded"
