---
title: "Hashicorp Packer"
---

!!! info
    [Packer Homepage](https://www.packer.io/) |
    [Packer Documentation](https://www.packer.io/docs) |
    [Packer QEMU Builder](https://www.packer.io/plugins/builders/qemu) |
    [jamlab-packer](https://github.com/JamFox/jamlab-packer)

Packer is an open source tool for creating identical machine images for multiple platforms from a single source configuration. Packer is lightweight, runs on every major operating system, and is highly performant, creating machine images for multiple platforms in parallel. Packer does not replace configuration management like Chef, Puppet or Ansible. In fact, when building images, Packer is able to use tools like Chef, Puppet or Ansible to install software onto the image.

A machine image is a single static unit that contains a pre-configured operating system and installed software which is used to quickly create new running machines. Machine image formats change for each platform.

[jamlab-packer](https://github.com/JamFox/jamlab-packer): Packer configurations for building homelab images. This repository contains my configurations for images.

## Usage

After configuring everything, building images is as easy as running a single command:

```bash
PACKER_LOG=1 packer build debian11.pkr.hcl
```

Where `debian11.pkr.hcl` is the configuration file that defines how to build the image. `PACKER_LOG=1` is used to print detailed messages while building for easier debugging.

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
