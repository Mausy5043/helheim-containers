#!/bin/sh

set -eu

podman build \
  --tag helheim/test3:latest \
  --file Containerfile \
  .
