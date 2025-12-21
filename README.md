# helheim-containers
Definitions of podman containers and pods running on helheim

# Helheim Container Build Repository

This repository contains the build instructions, configuration, and maintenance
scripts for all rootless Podman containers running on helheim. It provides a
clean, reproducible workflow for building, updating, and maintaining containers
after system updates.

## Overview

The repository is structured around three core ideas:

1. **Declarative container definitions**  
   Each container has its own directory under `containers/`, and the directory
   name matches the container name used in the `sysupdate` worklist.

2. **Reproducible builds**  
   Every container directory contains a `Dockerfile` and a `build.sh` script.
   These define exactly how the container is built and how it should be run.

3. **Automated update workflow**  
   After a system update that requires a reboot, a worklist is created under  
   `/var/lib/sysupdate/containers-to-build.conf`.  
   A user-level systemd service (`container-update.service`) runs on boot and
   processes this worklist using the scripts in `bin/`.

## Directory Structure
```
bin/                     # Global scripts for orchestrating builds
update-containers.sh      # Processes the worklist and rebuilds containers
build-container.sh          # Wrapper to build a single container
common.sh                            # Shared helper functions
helpers/               # Optional utilities

containers/              # One directory per container
<name>/                # Directory name = container name
Dockerfile           # Build instructions
build.sh                          # Container-specific build logic
config/              # Optional configuration files
README.md                        # Notes for this container

docs/                    # Documentation for the workflow
architecture.md
workflow.md
container-guidelines.md

VERSION                  # Version of this repository
README.md                                # This file
```


## Workflow Summary

1. **System update**  
   `chkreboot.sh` detects a kernel update and schedules a container rebuild by
   copying the managed container list into `/var/lib/sysupdate/`.

2. **Reboot**  
   A human performs the reboot.

3. **Automatic rebuild**  
   On boot, `container-update.service` runs as the `beheer` user and executes
   `bin/update-containers.sh`.

4. **Worklist processing**  
   Each container is rebuilt in order. Successful builds are removed from the
   worklist. When the file becomes empty, the cycle is complete.

## Adding a New Container

1. Create a new directory under `containers/<name>/`.
2. Add a `Dockerfile` and a `build.sh`.
3. Add the container name to `~/.config/sysupdate/managed-containers.conf`.
4. Commit and push the changes.

## Requirements

- Rootless Podman
- User-level systemd with lingering enabled
- A working Git environment

## License

This repository is intended for personal use on helheim. The MIT license is applied.
