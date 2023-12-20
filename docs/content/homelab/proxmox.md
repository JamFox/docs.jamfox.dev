---
title: "Proxmox VE"
---

!!! info
    [Proxmox Scripts](https://tteck.github.io/Proxmox/) |
    [Proxmox Homepage](https://www.proxmox.com/en/) |
    [Proxmox VE Downloads](https://www.proxmox.com/en/downloads/category/iso-images-pve)

Proxmox VE is a complete, open-source server management platform for enterprise virtualization. It tightly integrates the KVM hypervisor and Linux Containers (LXC), software-defined storage and networking functionality, on a single platform. With the integrated web-based user interface you can manage VMs and containers, high availability for clusters, or the integrated disaster recovery tools with ease.

## Setup

### Proxmox VE No-Subscription Repository

Without an enterprise PVE license, the default apt repo will error. Remove the enterprise apt list `/etc/apt/sources.list.d/pve-enterprise.list` and add the `pve-no-subscription` repo instead. This is done in [Ansible management proxmox role](https://gitlab.hpc.taltech.ee/hpc/ansible/ansible-mono/-/tree/master/roles/proxmox). Adding `pve-no-subscription` repo is done using `soft_apt` group variables.

We recommend to configure this repository in /etc/apt/sources.list.

File /etc/apt/sources.list
```
deb http://ftp.debian.org/debian bookworm main contrib
deb http://ftp.debian.org/debian bookworm-updates main contrib

# Proxmox VE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

# security updates
deb http://security.debian.org/debian-security bookworm-security main contrib
```

### Networking

#### Using Linux networking

To set up VLANs and required networks from the table above follow the steps from [Proxmox Networking docs](https://pve.proxmox.com/wiki/Network_Configuration):

1. Copy `/etc/network/interfaces` to `/etc/network/interfaces.new`: `cp /etc/network/interfaces /etc/network/interfaces.new`
2. Edit `/etc/network/interfaces.new` with changes.

3. Now you have three choices:
  - `cp /etc/network/interfaces.new /etc/network/interfaces` and run `ifreload -a` 
  - Go to `<PVE HOST> > System > Network` in the UI and press `Apply Configuration`. This will move changes from the staging interfaces.new file to /etc/network/interfaces and apply them live.
  - (or reboot PVE node, but this is not recommended if not needed)

NOTE: **NEVER reboot networking services manually**, use the tools/methods mentioned in [Proxmox Networking docs](https://pve.proxmox.com/wiki/Network_Configuration)! Manual restarts WILL break VM networking!

#### Using netplan

Using netplan is possible, but not recommended as every tap interface attached to a VM has to be added here in order to be persistent. They will not be added dynamically.

The corresponding configuration in /etc/netplan/00-main-conf.yaml might look like this:

```
network:
  version: 2
  ethernets:
    tap113i0: {}
    tap114i0: {}
    tap115i0: {}  
    enp129s0f1: {}
    enp5s0f0: {}
  vlans:
    vlan.3701:
      id: 3701
      link: enp129s0f1
  bridges:
    vmbr0:
      addresses: [172.21.5.87/24]
      gateway4: 172.21.5.254
      interfaces: [enp5s0f0]
      parameters:  
        forward-delay: 0
        stp: false
    vmbr1:
      interfaces: 
        - tap114i0
        - tap113i0
        - tap115i0
        - enp129s0f1
      parameters: 
        forward-delay: 0
        stp: false
```

### User creation

For management purposes, users should be created.

To use Packer with a `packer` user instead of using the root admin privileges for Packer builds (according to [packer-plugin-proxmox issue](https://github.com/hashicorp/packer-plugin-proxmox/issues/184#issuecomment-1505716258)):

- Add user: `pveum useradd packer@pve`
- Set user password: `pveum passwd packer@pve`
- Add role with set privileges: `pveum roleadd Packer -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Sys.Audit VM.Console SDN.Allocate SDN.Audit SDN.Use"`
   - GUI: for role privs: navigate to the Permissions → Roles tab from Datacenter and click on the Create button. There you can set a role name and select any desired privileges from the Privileges drop-down menu.
- Add role to user: `pveum aclmod / -user packer@pve -role Packer`

To use Terraform with `terraform` user (according to [Telmate provider doc](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-proxmox-user-and-role-for-terraform)):

- Add user: `pveum useradd terraform@pve`
- Set user password: `pveum passwd terraform@pve`
- Add role with set privileges: `pveum roleadd Terraform -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Allocate SDN.Audit SDN.Use"`
   - GUI: for role privs: navigate to the Permissions → Roles tab from Datacenter and click on the Create button. There you can set a role name and select any desired privileges from the Privileges drop-down menu.
- Add role to user: `pveum aclmod / -user terraform@pve -role Terraform`

API token can be generated in the UI from `Datacenter` tab from `Permissions > API Tokens` menu and then from the button `Add`.

[User Management](https://pve.proxmox.com/wiki/User_Management)

### Disk pools

Root storage is created on installation using with ZFS and RAID by default.

LVM-thin storage for VMs was created on 15K SAS disks:

1. Wipe disks that you wish to use: `wipefs -a /dev/sda /dev/sdb /dev/sdc /dev/sdd`
2. Create physical volumes: `pvcreate /dev/sda /dev/sdb /dev/sdc /dev/sdd`
3. Create volume group: `vgcreate vgrp /dev/sda /dev/sdb /dev/sdc /dev/sdd`
4. Create thin-pool on the volume group: `lvcreate -L 2T --thinpool thpl vgrp`
5. From `Datacenter -> Storage`, add an `LVM-Thin` storage

Directory storage for backups was created on 4TB HDDs:

1. Wipe disks that you wish to use: `wipefs -a /dev/sde /dev/sdf`
2. Create mirrored pool with disks: `zpool create tank mirror /dev/sde /dev/sdf`
   - Disk mount points are bound to change after reboots or hardware changes, resulting in ZPOOL degradation. Hence we will make the zpool use block device identifiers (/dev/disk/by-id) instead of mount-points.
3. Export pool: `zpool export tank`
4. `zpool import -d /dev/disk/by-id tank`
   - Importing back with /dev/disk/by-id immediately will seal the disk references.
5. Add it to PVE for storage: `pvesm add zfspool tank -pool tank`
6. Create mountpoint on the zpool: `zfs create tank/bkup  -o mountpoint=/bkup`
7. From the GUI via `Datacenter -> Storage -> Add -> Directory` add a Directory storage with the above `mountpoint` as the mount.

Mirrored ZFS pool for VMs was created with new 4TB SSDs from the UI `Datacenter -> <node> -> Storage -> ZFS -> Create` with following parameters:
- Name: ssdpool
- RAID: RAID10
- Compression: lz4 (recommended by [Proxmox documentation](https://pve.proxmox.com/wiki/ZFS_on_Linux#zfs_compression))
- ashift: 12 ([Ashift tells ZFS what the underlying physical block size your disks use is.](https://jrs-s.net/2018/08/17/zfs-tuning-cheat-sheet/) It's in bits, so ashift=9 means 512B sectors (used by all ancient drives), ashift=12 means 4K sectors (used by most modern hard drives), and ashift=13 means 8K sectors (used by some modern SSDs). CT4000MX500 has sector size as follows - logical/physical: 512 bytes / 4096 bytes.)
- Devices: `/dev/sdi /dev/sdj /dev/sdk /dev/sdl`

### Clustering

Proxmox supports clustering. For that to be useful, the modes have to have mostly mirroring setups. This applies especially for networking and storage. Migration between nodes is not possible if the network hardware is set to bridges that do not exist on the other machine.

## VM creation

Main method for creating VMs in Proxmox is via cloning existing VM templates that were built using Packer.

To create a clone of a VM template manually from UI:

- Use a FQDN for the VM name, e.g. `vm-ubuntu-20-04-1.hpc.taltech.ee` as this will be used as the hostname for the VM, but `vm-ubuntu-20-04-1` would not be used as the hostname, instead the template's hostname would be used.
- Create as a Full Clone not a Linked Clone
- Change the VM ID to a unique ID, default PVE suggestion should already be fine.
- Use Cloud Init for the VM configuration; to change IP, DNS, gateway, SSH keys.

To create a clone of a VM template manually from the CLI:

- Read Proxmox [Cloud-Init Support docs](https://pve.proxmox.com/wiki/Cloud-Init_Support) and [Cloud-Init FAQ](https://pve.proxmox.com/wiki/Cloud-Init_FAQ)

### ISO Upload

ISO images can be uploaded to Proxmox in two ways:

1. Via CMD and placed in `/var/lib/vz/template/iso`
   - `cd /var/lib/vz/template/iso && wget <iso_url>`
2. Via the Proxmox UI from `local (Storage Pool) -> ISO Images -> Upload / Download from URL`.

### VM Template Builds (and ISO Upload) with Packer

VM templates from ISO images for Proxmox VMs are built using the [jamlab-packer](https://github.com/JamFox/jamlab-packer) repository using Hashicorp Packer.

### VM Provisioning with Terraform

VMs are provisioned using Packer VM templates from the [jamlab-terraform](https://github.com/JamFox/jamlab-terraform) repository using Hashicorp Terraform.

## VM procedures

### Disk increase

On the PVE host follow the [official documentation procedure](https://pve.proxmox.com/wiki/Resize_disks) to increase the disk size of the VM you wish.

Then inside the VM:

```bash
# Check which partition to resize
sudo fdisk -l
# Grow partition (notice the space!)
sudo growpart /dev/sda X
# Resize to fill partition (notice the missing space this time!)
sudo resize2fs /dev/sdaX
```

### VM Disk Migration

#### VM live storage move migration (no downtime)

First, just in case, a backup snapshot was taken: `<VM> -> Backup -> Backup Now`

Then the VM migration was started from `<VM> -> Hardware -> Select Disk (verify the right one is highlighted and active) -> Disk Action -> Move Storage` (VM was not shut down, migration was done live, while the VM was running)

Note: cloud-init drive can not be moved similarly, for that the backup restore method must be used.

#### VM backup restore migration (with downtime)

A backup must exist, if it does not, then follow: `<VM> -> Backup -> Backup Now`

To restore, follow: `<VM> -> Backup -> Restore` 

Then select storage to restore to, check `Unique` if you wish to destroy the current one (if it exists), check `Start after restore` if you wish to immediately start it.

Note: the restore process creates a new cloud-init drive that is also on the same storage as the restore storage that was selected.

Downtime for the test VM with a fairly empty and small disk was less than 30 seconds, results may vary depending on the disk size.

### VM Migration To Another Node

Both servers have to be exact same versions. This includes packages and kernel.

Upgrade, reboot if necessary, check versions on all nodes with: `pveversion -v`

Note: if interfaces differ on nodes, you must temporarily replace them with something that exists on both nodes.

### Foreign QEMU/KVM migration to Proxmox

To migrate a foreign VM disk to Proxmox: 

1. Copy the foreign VM disk image somewhere on the Proxmox host you wish to migrate to
2. Use the following example to migrate:

```bash
VM_ID=666 #CHANGE ME!
VM_IMAGE=/root/migr-disks/myimage.qcow2 #CHANGE ME!

qm create ${VM_ID}
qm disk import ${VM_ID} ${VM_IMAGE} local-zfs
qm set ${VM_ID} --scsi0 local-zfs:vm-${VM_ID}-disk-0
qm set ${VM_ID} --boot order=scsi0
```
