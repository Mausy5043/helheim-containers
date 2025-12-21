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
