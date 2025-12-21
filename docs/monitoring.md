`podman ps`
List running containers.

`podman ps -a`
List all containers, including stopped or failed ones.

`podman inspect <name>`
Show full container details.

`podman inspect -f '{{.State.Status}}' <name>`
Show container status only.

`podman inspect -f '{{.State.ExitCode}}' <name>`
Show container exit code.

`podman inspect -f '{{.State.Pid}}' <name>`
Show PID of the container’s init process.

`podman logs <name>`
Show container logs.

`podman logs -f <name>`
Follow logs live.

`podman top <name>`
Show processes running inside a container.

`podman top <name> aux`
Detailed process list inside a container.

`podman exec -it <name> sh`
Open a shell inside a running container.

`podman exec -it <name> bash`
Open a bash shell if available.

`podman pod ps`
List pods.

`podman pod inspect <podname>`
Inspect pod details.

`podman pod top <podname>`
Show processes inside a pod.

`podman images`
List images.

`podman system df`
Show storage usage.

`podman system prune`
Remove unused containers and images.



`systemctl --user status container-test3.service`
Check status of the test3 systemd-managed container.

`systemctl --user status pod-test12.service`
Check status of the test12 pod.

`journalctl --user -u container-test3.service`
View logs for test3.

`journalctl --user -u pod-test12.service`
View logs for test12.

`systemctl --user daemon-reload`
Reload systemd user units after editing service files.

systemctl --user enable <unit>
Enable a user service so it starts automatically.

systemctl --user disable <unit>
Disable a user service.

systemctl --user start <unit>
Start a user service immediately.

systemctl --user stop <unit>
Stop a running user service.

systemctl --user restart <unit>
Restart a user service.

systemctl --user reload <unit>
Send a reload signal to a service (if supported).

systemctl --user status <unit>
Show detailed status, last logs, and exit codes.

journalctl --user -u <unit>
Show logs for a specific user service.

journalctl --user -u <unit> -f
Follow logs live.

journalctl --user --since "1 hour ago"
Show all user-service logs from the last hour.

systemctl --user list-units
List active user units.

systemctl --user list-unit-files
List installed user unit files and their enablement state.

systemctl --user show <unit>
Show all properties of a unit.

systemctl --user reset-failed <unit>
Clear the “failed” state of a unit.

loginctl enable-linger <username>
Allow user services to run without an active login session.

systemctl --user is-active <unit>
Check if a unit is active.

systemctl --user is-enabled <unit>
Check if a unit is enabled.

systemctl --user is-failed <unit>
Check if a unit is in a failed state.


podman ps
List running containers.

podman ps -a
List all containers, including failed or exited ones.

podman pod ps
List running pods.

podman pod inspect <podname>
Show full pod details, including container states.

podman inspect <name>
Show full container details, including cgroup paths and systemd integration.

podman inspect -f '{{.State.Status}}' <name>
Show container status only.

podman inspect -f '{{.State.Pid}}' <name>
Show the PID of the container’s init process.

podman top <name>
Show processes running inside a container.

podman pod top <podname>
Show processes running inside all containers in a pod.

podman logs <name>
Show container logs.

podman logs -f <name>
Follow logs live.

systemctl --user status <unit>
Show systemd’s view of the container or pod service.

systemctl --user restart <unit>
Restart a systemd-managed container or pod.

systemctl --user stop <unit>
Stop a systemd-managed container or pod.

systemctl --user start <unit>
Start a systemd-managed container or pod.

journalctl --user -u <unit>
Show logs for a systemd-managed container or pod.

journalctl --user -u <unit> -f
Follow logs live.

journalctl --user -u <unit> --since "10 min ago"
Show recent logs for a unit.

loginctl enable-linger <username>
Allow user services to run without an active login session.

podman system service --time=0
Check if Podman’s systemd API service is running (rootless).

podman system info
Show environment details, cgroup version, and systemd integration status.

podman events
Stream Podman events (container start, stop, die, oom, etc).

podman healthcheck run <name>
Manually trigger a container health check if defined.

podman generate systemd --new --files --name <container or pod>
Generate systemd unit files for a container or pod.

podman unshare cat /proc/self/cgroup
Inspect cgroup paths from Podman’s user namespace.
