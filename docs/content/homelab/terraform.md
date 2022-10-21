---
title: "Hashicorp Terraform"
---

!!! info
    [Terraform Homepage](https://www.terraform.io/) |
    [Terraform Documentation](https://www.terraform.io/docs) |
    [Terraform Proxmox provider](https://github.com/Telmate/terraform-provider-proxmox) |
    [jamlab-terraform](https://github.com/JamFox/jamlab-terraform)

Terraform is an infrastructure as code tool that lets you build, change, and version infrastructure safely and efficiently. This includes low-level components like compute instances, storage, and networking, as well as high-level components like DNS entries and SaaS features.

[jamlab-terraform](https://github.com/JamFox/jamlab-terraform): Terraform configurations for provisioning homelab VMs.

## Usage

With existing VM template(s) built with [Proxmox Builder (ISO)](https://www.packer.io/plugins/builders/proxmox/iso) it is possible to provision VMs with Terraform extra fast using [Terraform Proxmox provider](https://github.com/Telmate/terraform-provider-proxmox).

### Initializing and verifying configuration

Initialize the configuration directory to download and install the providers defined in the configuration:

```bash
terraform init
```

Format your configurations. Terraform will print out the names of the files it modified, if any:

```bash
terraform fmt
```

Make sure your configuration is syntactically valid and internally consistent

```bash
terraform validate
```

### Provisioning

Execute a dry run to verify configuration and see what would be done before executing apply:

```bash
terraform plan
```

Apply the plan and provision infrastructure as declared in configurations:

```bash
terraform apply
```

Unprovision infrastructure as declared in configurations:

```bash
terraform destroy
```

Using `-compact-warnings` flag will compact output, but still outputs errors in full.

#### Targeting specific resources

Any resources defined in `main.tf` can be targeted by using `-target="<RESOURCE>.<RESOURCE NAME>"`.

For example, target `base-infra` module:

```bash
terraform apply -target=module.base-infra
```

## Structure

```
main.tf                      # Main file used by Terraform commands
variables.tf                 # Global variables

modules/                     # Reusable modules
    pve-vm/                  # Proxmox VE VM provisioning template module

envs/                        # Environments dir
    prod/                    # Production infra definitions
        base-infra/          # Base infrastructure needed for services
            vars.tf          # Input variables
            outputs.tf       # Output variables
            main.tf          # Resources to be provisioned using modules
        service-infra/       # Services infrastructure
    dev/                     # Development infra definitions
       dev-vm/               # Development VM
```

### Creating multiple of similar resource

Create variable to be looped over with the values that will be used for each loop:

```
variable "vms" {
  description = "Base Infrastructure Virtual Machines"
  type = map
  default = {
  vm0 = {
        name = "vb0"
        ip   = "192.168.0.120"
    }
  vm1 = {
        name = "vb1"
        ip   = "192.168.0.121"
  }
 }
}
```

And then use `for_each` to use the variable to be looped over using the values with keyword `each.value.<VALUE INSIDE LOOPED VARIABLE>`:

```
module "vm" {
  for_each = var.vms
  source = "../../../modules/pve-vm" 

  target_node = local.default_target_node
  clone = local.default_clone
  vm_name = each.value.name
  desc = local.desc
  ipconfig0 = "ip=${each.value.ip}${local.cidr},gw=${local.gateway}"
  ip_address = "${each.value.ip}"
...
```