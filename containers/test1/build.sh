#!/bin/sh

set -eu

podman build \
  --tag helheim/test1:latest \
  --file Containerfile \
  .
