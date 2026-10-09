---
title: "Podman Rootless for Homelab"
icon: lucide/box
---

!!! info
    [Podman Installation](https://podman.io/docs/installation) |
    [Rocky Linux 10 Podman](https://docs.rockylinux.org/10/gemstones/containers/podman/) |
    [Use of Podman in a Rootless environment](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md?plain=1) |
    [machinectl manual](https://www.man7.org/linux/man-pages/man1/machinectl.1.html) |
    [podman-docker](https://packages.debian.org/sid/podman-docker) | 
    [unpriviliged user vs `--userns=auto`](https://github.com/podman-container-tools/podman/discussions/13728)

## Usage

From sudo user jump to the shell of rootless podman user: `sudo machinectl shell inside@ /bin/bash`

Inside rootless shell change to compose dir: `cd compose/`

Set stack var: `export COMPOSE_NAME=<NAME>`

Run a stack: `podman compose -f $COMPOSE_NAME.yml up -d`

Show containers of a stack: `podman compose -f $COMPOSE_NAME.yml ps`

Check stack logs:

- `podman compose -f $COMPOSE_NAME.yml logs -f`
- or specific container `podman compose -f $COMPOSE_NAME.yml logs -f <CONTAINER NAME>`

Restart stack:

- `podman compose -f $COMPOSE_NAME.yml restart`
- or specific container `podman compose -f $COMPOSE_NAME.yml restart <CONTAINER NAME>`

Recreate stack:

```bash
podman compose -f $COMPOSE_NAME.yml down
podman compose -f $COMPOSE_NAME.yml up -d
```

```bash
podman compose -f $COMPOSE_NAME.yml pull
podman compose -f $COMPOSE_NAME.yml up -d --build
```

Enter shell of container: `podman exec -it <CONTAINER> /bin/sh`

## SELinux

When attempting to mount a host volume into a Podman container on a system where SELinux is enabled, the container may fail to start, or access to the volume may be denied due to SELinux policy restrictions.

Use `:z` or `:Z` volume mount options (mount argument as `/data/appdata:/appdata:Z`), these flags relabel the host directory for container access:

`:z` – Use when the volume is shared between multiple containers.
`:Z` – Use when the volume is private to a single container.

## Inter container security

If you run two containers as a rootless user, they run in the same user namespace so they can attack each other from a User Namespace point of view.

If you run two containers as root with podman run `--userns=auto`, then they run in unigue user namespace and are isolated. Caveats include ensuring storage and network access to all containers that work together, ie from one compose.

This can also be set in the configuration file:

```
[containers]
userns = "auto"
```
