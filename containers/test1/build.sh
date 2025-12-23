#!/bin/sh

set -eu

cd "$(dirname "$0")"

podman build \
  --tag helheim/test1:latest \
  --file Containerfile \
  .

echo "You can now enable/start the helheim-test1.service to run this container."
