---
title: "DevOps"
---

General technical system administration and devops documentation.

## Linux

General Linux tidbits.

### APT upgrades without automatic restarts

On modern apt based systems if you wish to control the restarts better then you can [export these vars before upgrade](https://manpages.debian.org/bullseye/needrestart/needrestart.1.en.html):

```
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=l # l - list only, a - auto restart, i - interactive restart
```

### Sudo and root

You may see `sudo su -` used instead of `sudo -i` but there are some subtle differences between them.
The `sudo su -` command sets up the root environment exactly like a normal login because the `su -` command ignores the settings made by sudo and sets up the environment from scratch.
The default configuration of the `sudo -i` command actually sets up some details of the root user's environment differently than a normal login.
For example, it sets the PATH environment variable slightly differently. This affects where the shell will look to find commands.
You can make `sudo -i` behave more like `su -` by editing `/etc/sudoers` with `visudo`. Find the line

```
Defaults secure_path = /sbin:/bin:/usr/sbin:/usr/bin
```

and replace it with the following two lines:

```
Defaults secure_path = /usr/local/bin:/usr/bin
Defaults>root secure_path = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
```

For most purposes, this is not a major difference. However, for consistency of PATH settings on systems with the default `/etc/sudoers file`, it must be considered.

### SSH

#### Fix SSH permissions

```bash
find .ssh/ -type f -exec chmod 600 {} \;; find .ssh/ -type d -exec chmod 700 {} \;; find .ssh/ -type f -name "*.pub" -exec chmod 644 {} \;
```

### Virtualization

#### Check nested virtualization support

Intel: 

- `cat /sys/module/kvm_intel/parameters/nested`
- `modinfo kvm_intel | grep -i nested`

AMD: 

- `cat /sys/module/kvm_amd/parameters/nested`
- `modinfo kvm_amd | grep -i nested` 

### Disk

#### Check if disk is SSD or HDD

```
lsblk -d -o name,rota
```

### CPU sockets and cores

Only use first CPU socket for a task:

```bash
numactl --cpubind=0 --membind=0 <COMMAND>
```

Check which cores are E-cores (efficiency cores) and run task only on P-cores (performance cores):

```bash
cat /sys/devices/cpu_atom/cpus
12-19

taskset -c 0-11 <COMMAND>
```
