#!/bin/sh

set -eu

cd "$(dirname "$0")"

podman build \
  --tag helheim/test2:latest \
  --file Containerfile \
  .
