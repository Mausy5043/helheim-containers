#!/usr/bin/env bash
set -eu

CONTAINER_NAME="wireguard"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Stopping ${CONTAINER_NAME}..."

systemctl --user stop wireguard_pod

echo "${CONTAINER_NAME} is stopped"
