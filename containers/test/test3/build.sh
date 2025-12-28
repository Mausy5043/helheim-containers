#!/bin/sh

set -eu

cd "$(dirname "$0")"

podman build \
  --tag helheim/test3:latest \
  --file Containerfile \
  .


printf "\nYou can now enable/start the container-test3.service to run this container.\n\n"
exit 0
# shellcheck disable=SC2317
/usr/bin/podman run \
    --rm \
    --network=slirp4netns \
    --detach \
    --name test3 \
    --volume /etc/localtime:/etc/localtime:ro \
      helheim/test3:latest
