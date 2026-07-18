#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

CONTAINER_NAME="pihole"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

# Support Docker-specific features like HEALTHCHECK:
export BUILDAH_FORMAT=docker

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}" \
    --no-cache \
    --pull=newer \
    --file Containerfile \
    .
