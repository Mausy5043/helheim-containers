#!/bin/sh

set -eu

cd "$(dirname "$0")"

podman build \
  --tag helheim/test3:latest \
  --file Containerfile \
  .


echo "You can now enable/start the helheim-test3.service to run this container."
