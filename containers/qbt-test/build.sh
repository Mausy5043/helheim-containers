#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CONTAINER_NAME="qbt_test"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}" \
    --pull=newer \
    --file Containerfile \
    .

# not used for testing
    # --pull=always \
    # --no-cache \
