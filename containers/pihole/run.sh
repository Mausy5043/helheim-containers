#!/usr/bin/env bash
set -eu

CONTAINER_NAME="pihole"
TAG="helheim"
IMAGE_TAG="${CONTAINER_NAME}:${TAG}"

# Stop and remove any existing test container
podman rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Starting ${CONTAINER_NAME}..."

podman run -d --rm \
  --name "${CONTAINER_NAME}" \
  --cap-add=NET_ADMIN \
  --publish "28080:80" \
  --publish "28081:443" \
  --volume /etc/localtime:/etc/localtime:ro \
  --volume /srv/containers/pihole/etc:/etc/pihole:rw,U \
  --volume /srv/containers/pihole/dnsmasq:/etc/dnsmasq.d:rw,U \
  "${IMAGE_TAG}"
# Add these options later:
#  --publish "53:53" \

echo "${CONTAINER_NAME} is starting on http://127.0.0.1"
