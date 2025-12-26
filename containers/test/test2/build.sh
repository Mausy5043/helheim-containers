#!/bin/sh

set -eu

cd "$(dirname "$0")"

podman build \
  --tag helheim/test2:latest \
  --file Containerfile \
  .

printf "\nYou can now enable the container-test2.timer to run this container.\n\n"
