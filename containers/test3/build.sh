#!/bin/sh

set -eu

cd "$(dirname "$0")"

podman build \
  --tag helheim/test3:latest \
  --file Containerfile \
  .
