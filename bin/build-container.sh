#!/usr/bin/env bash

# Usage: build-container.sh <container-name>
# Given a container name, runs the build instructions inside containers/<name>/

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <container-name>" >&2
    exit 1
fi

NAME="$1"
REPO_ROOT="${HOME}/git/helheim-containers"
CONTAINER_DIR="${REPO_ROOT}/containers/${NAME}"
BUILD_SCRIPT="${CONTAINER_DIR}/build.sh"

pushd "${REPO_ROOT}" || exit 1
# Validate container directory
if [ ! -d "${CONTAINER_DIR}" ]; then
    echo "ERROR: Container directory not found: ${CONTAINER_DIR}" >&2
    popd && exit 1
fi

# Validate build script
if [ ! -x "${BUILD_SCRIPT}" ]; then
    echo "ERROR: Build script not found or not executable: ${BUILD_SCRIPT}" >&2
    popd && exit 1
fi

echo "=== Building container '${NAME}' ==="

# Execute the container-specific build script
if "${BUILD_SCRIPT}"; then
    echo "=== Build succeeded: ${NAME} ==="
    popd || exit 1
    exit 0
else
    echo "=== Build FAILED: ${NAME} ===" >&2
    popd && exit 1
fi
