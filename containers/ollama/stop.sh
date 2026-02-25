#!/usr/bin/env bash
set -eu

IMAGE_TAG="ollama"
CONTAINER_NAME="ollama"
PORT=11434

echo "Stopping ${CONTAINER_NAME}..."
podman stop "${CONTAINER_NAME}" 2>/dev/null || true
# Stop and remove any existing test container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Ollama is stopped"
