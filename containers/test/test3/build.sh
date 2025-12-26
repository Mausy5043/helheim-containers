#!/bin/sh

set -eu

cd "$(dirname "$0")"

podman build \
  --tag helheim/test3:latest \
  --file Containerfile \
  .


printf "\nYou can now enable/start the container-test3.service to run this container.\n\n"
