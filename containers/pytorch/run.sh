#!/usr/bin/env bash
set -eu

CONTAINER_NAME="pytorch"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

PORT=11434

# Stop and remove any existing test container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Starting ${CONTAINER_NAME}..."

podman run -d --rm \
  --name "${CONTAINER_NAME}" \
  --publish "${PORT}:${PORT}" \
  --volume /etc/localtime:/etc/localtime:ro \
  --volume /srv/containers/pytorch:/home/ollama/.ollama:rw,U \
  --device=/dev/kfd \
  --device=/dev/dri/renderD128 \
  --group-add=render \
  "${IMAGE_TAG}"

echo "${CONTAINER_NAME} is starting on http://127.0.0.1:${PORT}"
