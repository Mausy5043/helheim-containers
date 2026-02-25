#!/usr/bin/env bash
set -eu

cd "$(dirname "$0")"

IMAGE_TAG="ollama:latest"

echo "Building ${IMAGE_TAG}..."
podman build \
    --tag "${IMAGE_TAG}" \
    --pull=true \
    --file Containerfile \
    .
