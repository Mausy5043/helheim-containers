#!/usr/bin/env bash

# Consumes the worklist '/var/lib/sysupdate/containers-to-build.conf',
# ... iterates through container names,
# ... calls 'build-container.sh',
# ... updates the worklist to remove a successfully built container.

set -euo pipefail

WORKLIST="/var/lib/sysupdate/containers-to-build.conf"
REPO_ROOT="${HOME}/git/helheim-containers"
BUILDER="${REPO_ROOT}/bin/build-container.sh"
SYSTEMD="${REPO_ROOT}/bin/update-systemd.sh"


# Nothing to do if the worklist is missing or empty
if [ ! -s "${WORKLIST}" ]; then
    echo "No containers to build."
    exit 0
fi

pushd "${REPO_ROOT}" || exit 1
    # install new services/timers
    exec "${SYSTEMD}" || exit 1

    # Temporary file for updated worklist
    TMP_WORKLIST="$(mktemp)"

    # Process each container name
    while IFS= read -r container || [ -n "$container" ]; do
        # Skip empty lines or whitespace
        [ -z "${container// }" ] && continue

        echo
        echo "Building container: ${container}"

        if "${BUILDER}" "${container}"; then
            echo "SUCCESS: ${container}"
            # Do NOT add back to TMP_WORKLIST
        else
            echo "FAILED: ${container}"
            # Keep it in the worklist for next run
            echo "${container}" >> "${TMP_WORKLIST}"
        fi
        echo ""
    done < "${WORKLIST}"

    # Replace the original worklist
    sudo mv "${TMP_WORKLIST}" "${WORKLIST}"
    chmod 644 "${WORKLIST}"

    echo "Update pipeline completed."

popd || exit 1
