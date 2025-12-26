#!/bin/sh

set -eu

cd "$(dirname "$0")"

podman build \
  --tag helheim/test1:latest \
  --file Containerfile \
  .

printf "\nYou can now enable/start the container-test1.service to run this container.\n\n"
