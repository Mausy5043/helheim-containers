#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

IMAGE_TAG="mypython"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}" \
    --pull=newer \
    --build-context app=. \
    --file Containerfile \
    .
