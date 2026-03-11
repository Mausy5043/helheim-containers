#!/usr/bin/env bash
set -eu

CONTAINER_NAME="qbt_r"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Boarding ${CONTAINER_NAME}..."

# shellcheck disable=SC2034

podman exec -it "${CONTAINER_NAME}" /bin/bash 2>/dev/null || true

echo "${CONTAINER_NAME} is deboarded"
