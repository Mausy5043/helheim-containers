#!/usr/bin/env bash

git reset --hard origin/master
git pull

pushd "$(dirname "$0")" || exit 1

cp "./systemd/user/*" "${HOME}/.config/systemd/user/"
systemctl --user daemon-reload
