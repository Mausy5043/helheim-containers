#!/usr/bin/env bash
set -eu

CONTAINER_NAME="octave"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Stopping ${CONTAINER_NAME}..."
podman stop "${CONTAINER_NAME}" 2>/dev/null || true
# Stop and remove any existing test container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "${CONTAINER_NAME} is stopped"
