#!/bin/sh

set -eu

cd "$(dirname "$0")"

podman build \
  --tag helheim/test2:latest \
  --file Containerfile \
  .

echo "You can now enable the helheim-test2.timer to run this container."
