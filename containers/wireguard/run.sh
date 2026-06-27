#!/usr/bin/env bash
set -eu

CONTAINER_NAME="wireguard"
TAG="helheim"
HOST_TAG="${CONTAINER_NAME}.${TAG}"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

# Stop and remove any existing test container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Starting ${CONTAINER_NAME}..."

systemctl --user start pihole_pod

echo "${CONTAINER_NAME} is starting on http://127.0.0.1"
