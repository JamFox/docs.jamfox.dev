---
title: "Podman Rootless for Homelab"
---

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
