#!/usr/bin/env bash
set -eu

IMAGE_TAG="ollama:testing"
CONTAINER_NAME="ollama-test"
PORT=11434

echo "Boarding ${CONTAINER_NAME}..."
podman exec -it "${CONTAINER_NAME}" /bin/bash 2>/dev/null || true

echo "Ollama is deboarded"
