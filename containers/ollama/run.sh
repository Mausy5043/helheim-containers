#!/usr/bin/env bash
set -eu

IMAGE_TAG="ollama:testing"
CONTAINER_NAME="ollama-test"
PORT=11434

# Stop and remove any existing test container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Starting ${CONTAINER_NAME}..."

podman run -d -rm \
  --name "${CONTAINER_NAME}" \
  --publish "${PORT}:${PORT}" \
  --volume /srv/containers/ollama:/home/ollama/.ollama:rw,U \
  --device=/dev/kfd \
  --device=/dev/dri/renderD128 \
  --group-add=render \
  "${IMAGE_TAG}"

echo "Ollama is starting on http://127.0.0.1:11434"
