#!/usr/bin/env bash
set -eu

CONTAINER_NAME="systemd-qbt-r"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

echo "Boarding ${CONTAINER_NAME}..."

# shellcheck disable=SC2034

podman exec -it "${CONTAINER_NAME}" /bin/bash

echo "${CONTAINER_NAME} is deboarded"
