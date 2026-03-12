#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

CONTAINER_NAME="pytorch"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}" \
    --pull=newer \
    --file Containerfile \
    .
