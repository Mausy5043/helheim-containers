#!/usr/bin/env bash
set -eu

CONTAINER_NAME="ollama"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

PORT=11434

echo "Boarding ${CONTAINER_NAME}..."
# reset the GPU
rocm-smi --gpureset -d 0 >/dev/null || echo "GPU reset failed!"
# reclaim buffered RAM
sync; sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
podman exec -it "${CONTAINER_NAME}" /bin/bash 2>/dev/null || true

echo "${CONTAINER_NAME} is deboarded"
