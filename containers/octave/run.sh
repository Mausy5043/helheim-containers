#!/usr/bin/env bash
set -eu

CONTAINER_NAME="octave"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

PORT=11434

# Stop and remove any existing test container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Starting ${CONTAINER_NAME}..."

podman run -d --rm \
  --name "${CONTAINER_NAME}" \
  --volume /etc/localtime:/etc/localtime:ro \
  "${IMAGE_TAG}"

echo "${CONTAINER_NAME} is running."
