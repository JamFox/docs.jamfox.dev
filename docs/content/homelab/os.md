---
title: "Operating System (Debian)"
---

For the OS I decided to go with the tried and true homelab hypervisor [Proxmox Virtual Environment](https://www.proxmox.com/en/proxmox-ve) as it is basically the only option when it comes to complete, free and open source Platform-as-a-Service OS choices.

One of the advantages with using Proxmox is that it is a Debian based OS which makes it easy to set up a single Ansible configuration management system for Proxmox hosts together with Raspberry Pi hosts which usually run Debian based distros as well.

## Steps

1. Download the latest iso from [Proxmox VE Downloads](https://www.proxmox.com/en/downloads/category/iso-images-pve).
2. Flash it onto USB and boot the server from it.
3. Follow the prompts to configure the volume, locale and install the OS.

Since I run hardware RAID I went with xfs instead of zfs with software RAID for the filesystem.

## Bootstrap the lab

To bootstrap the lab, I use [jamlab-ansible](https://github.com/JamFox/jamlab-ansible): Homelab bootstrap and pull-mode configuration management with Ansible and bash.

Bootstrapping is almost as easy as cloning the repo and running the bootstrap script. Exact steps detailed in the repository README and in the Configuration Management chapter.
