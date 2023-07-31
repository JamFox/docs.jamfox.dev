---
title: "Hashicorp Packer"
---

!!! info
    [Packer Homepage](https://www.packer.io/) |
    [Packer Documentation](https://www.packer.io/docs) |
    [Packer QEMU Builder](https://www.packer.io/plugins/builders/qemu) |
    [Proxmox Builder (ISO)](https://www.packer.io/plugins/builders/proxmox/iso) |
    [jamlab-packer](https://github.com/JamFox/jamlab-packer)

Packer is an open source tool for creating identical machine images for multiple platforms from a single source configuration. Packer is lightweight, runs on every major operating system, and is highly performant, creating machine images for multiple platforms in parallel. Packer does not replace configuration management like Chef, Puppet or Ansible. In fact, when building images, Packer is able to use tools like Chef, Puppet or Ansible to install software onto the image.

A machine image is a single static unit that contains a pre-configured operating system and installed software which is used to quickly create new running machines. Machine image formats change for each platform.

[jamlab-packer](https://github.com/JamFox/jamlab-packer): Packer configurations for building homelab images. This repository contains my configurations for images.

## Usage

With the [Proxmox Builder (ISO)](https://www.packer.io/plugins/builders/proxmox/iso) it is possible to use a remote or local ISO file to create and configure a VM which can be converted into a template that can be used for super fast provisioning of VMs.

### Commands

Install dependencies and modules:

```bash
packer init -upgrade .
```

After configuring everything, building images is as easy as running a single command. `PACKER_LOG=1` is used to print detailed messages while building for easier debugging:

```bash
PACKER_LOG=1 packer build debian11.pkr.hcl
```

With log output to a file:

```bash
PACKER_LOG_PATH="packerlog.txt" PACKER_LOG=1 packer build debian11.pkr.hcl
```

Where `debian11.pkr.hcl` is the configuration file that defines how to build the image. 

### Variables

Defining variables in [HCL](https://github.com/hashicorp/hcl):

```hcl
variable "iso_checksum" {
  type    = string
  default = "e307d0e583b4a8f7e5b436f8413d4707dd4242b70aea61eb08591dc0378522f3"
}
```

Defined variables can be used like so:

```hcl
iso_checksum = var.iso_checksum
```

Or also substituted into other strings:

```hcl
iso_full_url = "https://${var.iso_url}${var.iso_checksum}"
```

### Preseed

Preseeding provides a way to answer questions asked during the installation process without having to manually enter the answers while the installation is running. Read more about this method in the [preseed documentation](https://wiki.debian.org/DebianInstaller/Preseed).

With preseed I configure the bare minimum for the installation to work before the cloud-init takes over.

### Cloud-init

Cloud-init is used for initial machine configuration like creating users, installing packages, custom scripts or preseeding `authorized_keys` file for SSH authentication. Read more about this in [cloud-init documentation](https://cloudinit.readthedocs.io/en/latest/).

With cloud-init I reset the root password to something randomized, install necessary packages for Ansible to take over the configuration and initialize the script that checks if Ansible management is bootstrapped.
