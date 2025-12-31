#!/usr/bin/env bash

git reset --hard origin/master
git pull

# repo_root="$(cd "$(dirname "$0")/" && pwd)"

# cp -rv "${repo_root}/systemd/user/"* "${HOME}/.config/systemd/user/"
# systemctl --user daemon-reload
