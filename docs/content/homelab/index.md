---
title: "HomeLab"
---

Anything directly related to the homelab infrastructure is documented in this section.

!!! info
    A [homelab](https://old.reddit.com/r/homelab/) is self-hosted infrastructure at home for:

    - experimenting in a safe environment and learning technologies.
    - running personal "production" services (like game servers, file cloud etc).

## Architecture

This section describes the JamLab architecture and the reasoning behind it.

### Abstract overview

JamLab is a hardware installed at JamFox's home, the lab is behind a second router that is connected to the NAT gateway router with a dynamic IP and is managed by one or more [Proxmox Virtual Environment](https://www.proxmox.com/en/proxmox-ve) bare metal hypervisor hosts with a heap memory and CPU resources for running virtual machines. Internal DNS is provided by another low-power always-on bare metal host, in this case a Raspberry Pi 3B+. All bare metal hosts are configured using [Red Hat Ansible](https://www.ansible.com/). Secrets are handled by [Ansible Vault](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html) and [Mozilla SOPS](https://github.com/mozilla/sops). Hypervisor hosts run virtual machines. Configured virtual machine templates are built with [Hashicorp Packer](https://www.packer.io/) using Ansible and provisioned also with Ansible using [Hashicorp Terraform](https://www.terraform.io/) and configured by Ansible post-provision. Virtual machines fall into two groups: base infrastructure nodes (called `vb` nodes) and service infrastructure nodes (called `vs` nodes). Base infrastructure nodes run [Hashicorp Consul service discovery](https://www.consul.io/), [Hashicorp Nomad orchestration servers](https://www.hashicorp.com/products/nomad). Service infrastructure nodes use Nomad orchestration clients to run any services.

Features:

- Dynamically parsed hosts list: adding a new `vs` and `vb` nodes is as easy as adding a new entry to their respective host groups.
- Automatic VM provisioning: Packer creates VM template and Terraform provisions VMs.
- Internal DNS: reach nodes via subdomain instead of trying to remember IPs.
- External DNS: internet-exposed services available with DDNS pointing to router.
- Load balancing and reverse proxy: HAProxy terminates SSL connection and forwards traffic to appropriate services.  
- Nomad orchestration: host any service and orchestrate it.
- Scalable Nomad service load balancing: each `vs` node has a Fabio load balancer.
- Consul service discovery: services with multiple instances discoverable from `<service name>.service.consul` address.
- Consul Connect service mesh: Nomad services are able to securely communicate with each other with no plumbing configuration.

JamLab repositories:

- [jamlab-ansible](https://github.com/JamFox/jamlab-ansible): Homelab bootstrap and pull-mode configuration management with Ansible and bash.
- [jamlab-packer](https://github.com/JamFox/jamlab-packer): Packer configurations for building homelab images.
- [jamlab-terraform](https://github.com/JamFox/jamlab-terraform): Terraform configurations for provisioning homelab VMs.

### Overview diagram

![jamlab-overview diagram](attachments/jamlab-overview.png)

## Accessing services

Easiest way to explain what goes on in the JamLab is to look at the flow when a client wishes to access a service. Let's say that the client wishes to access a web server from the address `web.jamfox.dev`.

If the client queries `web.jamfox.dev`:

- from outside the JamLab internal network they get back a response from external DNS (eg Namecheap DNS, Cloudflare DNS or other) pointing to a dynamic IP of the JamLab ISP router. The JamLab ISP router forwards ports to the bastion host running HAProxy.
- from inside the JamLab internal network then they get back a response pointing to the bastion host running HAProxy from the ISP router using bastion host as the primary DNS.

HAProxy establishes connection and terminates SSL if used. By default, HAProxy balances and directs the traffic to Fabio load balancers on `vs` nodes. If Fabio finds any Nomad services that have been tagged with the address `web.jamfox.dev` it will balance and direct the traffic to the service node(s).

```
                      +- HTTP(S) -> Fabio LB -+-> web-0 (vs0)
                      |                       |
HTTPS --> HAProxy LB -+- HTTP(S) -> Fabio LB -+-> web-1 (vs1)
                      |                       |
                      +- HTTP(S) -> Fabio LB -+-> web-n (vsn)
```
