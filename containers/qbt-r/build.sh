#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CONTAINER_NAME="qbt_r"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}" \
    --pull=newer \
    --file Containerfile \
    .

printf "\nYou can now enable/start the qbt-r.service to run this container.\n\n"
