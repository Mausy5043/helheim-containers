#!/usr/bin/env bash

REPO_ROOT="${HOME}/git/helheim-containers"

pushd "${REPO_ROOT}" || exit 1
    git reset --hard origin/master
    git pull
popd || exit 1

# repo_root="$(cd "$(dirname "$0")/" && pwd)"

# cp -rv "${repo_root}/systemd/user/"* "${HOME}/.config/systemd/user/"
# systemctl --user daemon-reload
