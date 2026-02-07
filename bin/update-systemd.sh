#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="${HOME}/git/helheim-containers"

# install new services/timers
cp -rv "${REPO_ROOT}/systemd/user/"*.service "${HOME}/.config/systemd/user/" || exit 1
cp -rv "${REPO_ROOT}/systemd/user/"*.timer "${HOME}/.config/systemd/user/" || exit 1
cp -rv "${REPO_ROOT}/systemd/"*.container "${HOME}/.config/containers/systemd/" || exit 1
systemctl --user daemon-reload

echo "Update of user services/timers completed."
exit 0
