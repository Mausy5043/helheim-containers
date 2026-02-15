#!/usr/bin/env bash
set -eu

IMAGE_TAG="mypython"
CONTAINER_NAME="mypython"

echo "Boarding ${CONTAINER_NAME}..."
podman exec --rm -it "${CONTAINER_NAME}" /bin/bash 2>/dev/null || true

echo "${CONTAINER_NAME} is deboarded"
