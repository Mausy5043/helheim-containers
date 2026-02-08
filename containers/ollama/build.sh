#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

IMAGE_TAG="ollama:testing"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}" \
    --pull=true \
    --file Containerfile \
    .

# 
# Uncomment for testing:
# podman run -it --rm  \
#     --name ollama \
#     "${IMAGE_TAG}"
