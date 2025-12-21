#!/bin/sh

set -eu

cd "$(dirname "$0")"

podman build \
  --tag helheim/test1:latest \
  --file Containerfile \
  .
