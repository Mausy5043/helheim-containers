#!/bin/sh

set -eu

podman build \
  --tag helheim/test2:latest \
  --file Containerfile \
  .
