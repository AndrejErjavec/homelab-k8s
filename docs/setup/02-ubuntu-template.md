# Ubuntu Cloud-Init Template

## Purpose

Create a reusable Ubuntu Server 24.04 cloud-init template in Proxmox.

Terraform will clone this template to create the Kubernetes control-plane and worker VMs. The template should be generic: it should boot reliably, support cloud-init, run the QEMU guest agent, and accept per-VM network and SSH configuration from Terraform.

This step creates the base machine image only. Kubernetes packages, containerd, kernel modules, sysctl settings, and kubeadm configuration belong to Ansible in the next steps.

## Concepts

### VM Template

A Proxmox VM template is a VM that is not meant to run directly. It is a source for clones.

Instead of installing Ubuntu manually three times, you build one clean template and let Terraform clone it into:

```text
k8s-cp-01
k8s-worker-01
k8s-worker-02
```

This gives you repeatability. If the cluster is broken during learning, you can destroy and recreate the VMs instead of hand-repairing unknown drift.

### Golden Image

A template is a form of golden image. A golden image contains the common base state every VM should start from.

For this lab, the image should include only baseline boot requirements:

- Ubuntu Server 24.04 LTS cloud image
- QEMU guest agent
- cloud-init support
- serial console support
- virtual disk and NIC configuration suitable for Proxmox

It should not include Kubernetes-specific state. Do not install kubeadm, kubelet, Cilium, Argo CD, or app dependencies into the template. Those belong to later layers.

### Ubuntu Cloud Image

Ubuntu publishes cloud images that are already designed for automated provisioning. They are different from the normal ISO installer:

- no interactive install process
- cloud-init enabled
- small base image
- designed to receive user, SSH, hostname, and network configuration at first boot

For Ubuntu 24.04 LTS, the release codename is:

```text
noble
```

The image used here is:

```text
noble-server-cloudimg-amd64.img
```

### Cloud-Init

cloud-init is the first-boot configuration system commonly used by cloud VMs. In this lab, Proxmox provides cloud-init data to each cloned VM.

Terraform will later set values such as:

- hostname
- username
- SSH authorized key
- static IP address
- default gateway
- DNS server

The template itself should support cloud-init, but the final node-specific values should be supplied when each VM is cloned.

### QEMU Guest Agent

The QEMU guest agent runs inside the VM and lets Proxmox communicate with the guest OS.

It is useful for:

- cleaner shutdowns
- better VM status reporting
- IP address reporting
- Terraform waiting for VM readiness
- operational visibility from Proxmox

Install it into the template so every cloned VM has it.

### libguestfs and virt-customize

`virt-customize` is part of `libguestfs-tools`. It modifies a VM disk image before the VM boots.

Here it is used to install and enable `qemu-guest-agent` inside the Ubuntu cloud image before importing the disk into Proxmox.

This is cleaner than booting a temporary VM, logging in, installing a package, shutting it down, and converting it into a template.

### Proxmox `qm`

`qm` is the Proxmox command-line tool for managing QEMU/KVM VMs.

This guide uses `qm` because it is explicit and repeatable:

- `qm create` creates the VM definition.
- `qm importdisk` imports the Ubuntu cloud image into Proxmox storage.
- `qm set` configures disks, boot order, cloud-init, console, and guest agent.
- `qm template` converts the VM into a clone source.

### Disk Controller and Cloud-Init Drive

The template uses SCSI with the VirtIO SCSI controller:

```text
virtio-scsi-pci
```

This is a good default for Linux VMs on Proxmox.

The template also gets a cloud-init drive:

```text
ide2: cloudinit
```

That drive is how Proxmox presents first-boot metadata to the guest.

### Serial Console

Cloud images often work best with a serial console configured:

```text
serial0 socket
vga serial0
```

This makes boot logs and console access more reliable for headless server images.

### Template Immutability

After you convert the VM to a template, treat it as immutable. If you need to change the base image, rebuild it intentionally or create a new template ID.

Avoid booting and modifying the template by hand. Manual changes make the source of truth unclear.

## Current State

The repository expects this Proxmox template:

| Item | Value |
| --- | --- |
| Proxmox node | `pve` |
| Template VM ID | `9000` |
| Template name | `ubuntu-2404-cloudinit` |
| Ubuntu release | `24.04 LTS`, codename `noble` |
| Cloud-init user | `ubuntu` |
| Bridge | `vmbr0` |
| VM disk datastore | `local-lvm` |
| Cloud-init datastore | `local-lvm` |

Terraform references this value:

```hcl
template_vm_id = 9000
```

## Configuration

The template should be generic. Terraform will configure the real Kubernetes nodes later.

Template-level values:

```text
VM ID:        9000
Name:         ubuntu-2404-cloudinit
CPU:          2 cores
Memory:       2048 MB
Network:      virtio on vmbr0
Disk bus:     scsi0
Cloud-init:   ide2
Default user: ubuntu
IP config:    dhcp placeholder
```

Terraform clone-level values:

```text
k8s-cp-01      192.168.10.91/24
k8s-worker-01  192.168.10.92/24
k8s-worker-02  192.168.10.93/24
Gateway         192.168.10.1
DNS             192.168.10.12
Domain          home.arpa
```

## Procedure

Run these commands on the Proxmox host, not on your workstation.

### 1. Confirm Prerequisites

SSH into Proxmox:

```sh
ssh root@192.168.10.10
```

Confirm the bridge exists:

```sh
ip address show vmbr0
```

Confirm storage names:

```sh
pvesm status
```

Expected result:

- `vmbr0` exists.
- `local` exists for image storage.
- `local-lvm` exists and supports VM disks.

If your VM disk storage is not `local-lvm`, replace `local-lvm` in the commands below with the correct datastore.

### 2. Install Image Customization Tools

Run:

```sh
apt update
apt install -y libguestfs-tools wget
```

What this does:

- `wget` downloads the Ubuntu cloud image.
- `libguestfs-tools` provides `virt-customize`.

If Proxmox cannot reach the internet, download the image on another machine and upload it to the Proxmox host manually.

### 3. Download the Ubuntu 24.04 Cloud Image

Run:

```sh
cd /var/lib/vz/template/iso
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

Optional but recommended: record the file details.

```sh
ls -lh noble-server-cloudimg-amd64.img
sha256sum noble-server-cloudimg-amd64.img
```

Why this matters:

The image is the base OS for every Kubernetes VM. Recording the checksum gives you a useful audit trail if you rebuild the template later.

### 4. Install QEMU Guest Agent into the Image

Run:

```sh
virt-customize -a noble-server-cloudimg-amd64.img \
  --install qemu-guest-agent \
  --run-command 'systemctl enable qemu-guest-agent'
```

Expected result:

- The command completes without errors.
- The cloud image now contains `qemu-guest-agent`.
- The guest agent will start automatically when cloned VMs boot.

If this command fails, do not continue. Fix image customization first. A template without a guest agent can still boot, but Terraform and Proxmox operations are less reliable.

### 5. Create the Template VM Shell

Run:

```sh
qm create 9000 \
  --name ubuntu-2404-cloudinit \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0 \
  --ostype l26 \
  --agent enabled=1
```

This creates the VM configuration but does not yet attach the Ubuntu disk.

Explanation:

- `9000` is the template VM ID.
- `--name` identifies the template in the Proxmox UI.
- `--memory 2048` and `--cores 2` are template defaults, not final Kubernetes VM sizing.
- `--net0 virtio,bridge=vmbr0` attaches the VM to the LAN bridge.
- `--ostype l26` tells Proxmox this is a Linux 2.6+ guest.
- `--agent enabled=1` enables Proxmox-side support for the QEMU guest agent.

### 6. Import the Cloud Image Disk

Run:

```sh
qm importdisk 9000 noble-server-cloudimg-amd64.img local-lvm
```

Expected result:

- Proxmox imports the image as an unused disk on VM `9000`.
- The imported disk is usually named similar to `local-lvm:vm-9000-disk-0`.

Confirm the disk name:

```sh
qm config 9000
```

Look for an `unused0` entry similar to:

```text
unused0: local-lvm:vm-9000-disk-0
```

### 7. Attach the Imported Disk

If the imported disk is `local-lvm:vm-9000-disk-0`, run:

```sh
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
```

If your `qm config 9000` output shows a different disk volume, use that value instead.

Why this matters:

`qm importdisk` imports the disk but does not automatically make it the boot disk. Attaching it as `scsi0` makes it the VM's main disk.

### 8. Add the Cloud-Init Drive

Run:

```sh
qm set 9000 --ide2 local-lvm:cloudinit
```

This attaches the Proxmox cloud-init drive.

Terraform will later populate cloud-init data for cloned VMs. Without this drive, the clones will not receive their expected static IPs, user config, or SSH keys.

### 9. Set Boot Order and Console

Run:

```sh
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
```

Explanation:

- `--bootdisk scsi0` boots from the imported Ubuntu disk.
- `--serial0 socket --vga serial0` exposes a serial console suitable for cloud images.

### 10. Set Baseline Cloud-Init Defaults

Run:

```sh
qm set 9000 --ciuser ubuntu
qm set 9000 --ipconfig0 ip=dhcp
```

The DHCP setting is only a placeholder for the template. Terraform will override VM-specific network configuration during cloning.

Do not set production Kubernetes node IPs directly on the template. The template should remain generic.

### 11. Review the Template VM Configuration

Run:

```sh
qm config 9000
```

Expected important lines:

```text
agent: enabled=1
boot: order=scsi0
ciuser: ubuntu
ide2: local-lvm:vm-9000-cloudinit
name: ubuntu-2404-cloudinit
net0: virtio=...,bridge=vmbr0
scsi0: local-lvm:vm-9000-disk-0
scsihw: virtio-scsi-pci
serial0: socket
vga: serial0
```

Exact disk names may differ. The important part is that `scsi0`, `ide2`, `net0`, the guest agent, and the serial console are present.

### 12. Convert the VM to a Template

Run:

```sh
qm template 9000
```

Expected result:

- VM `9000` becomes a Proxmox template.
- It appears as `ubuntu-2404-cloudinit` in the Proxmox UI.
- Terraform can clone it later.

## Optional Test Clone

This is recommended before moving to Terraform. It proves the template boots and accepts cloud-init.

Use a temporary VM ID and a free temporary IP. This example uses:

```text
VM ID: 9010
Name: ubuntu-template-test
IP: 192.168.10.79
```

Only use `192.168.10.79` if it is free.

### 1. Create a Test Clone

Run on Proxmox:

```sh
qm clone 9000 9010 --name ubuntu-template-test --full true
qm set 9010 --ipconfig0 ip=192.168.10.79/24,gw=192.168.10.1
qm set 9010 --nameserver 192.168.10.12
qm set 9010 --searchdomain home.arpa
```

Add your SSH key. Replace the path if needed:

```sh
qm set 9010 --sshkeys ~/.ssh/id_ed25519.pub
```

Start it:

```sh
qm start 9010
```

### 2. Verify Boot and SSH

From your workstation:

```sh
ping -c 4 192.168.10.79
ssh ubuntu@192.168.10.79
```

Inside the test VM:

```sh
cloud-init status --long
systemctl status qemu-guest-agent --no-pager
ip address
ip route
resolvectl status
```

Expected result:

- cloud-init is done.
- `qemu-guest-agent` is active.
- IP address is `192.168.10.79/24`.
- default route points to `192.168.10.1`.
- DNS includes `192.168.10.12`.

### 3. Verify Guest Agent from Proxmox

Run on Proxmox:

```sh
qm agent 9010 ping
```

Expected result:

- The command returns successfully.

You can also inspect network interfaces through the agent:

```sh
qm agent 9010 network-get-interfaces
```

### 4. Clean Up the Test Clone

After verification:

```sh
qm shutdown 9010
```

Wait until stopped:

```sh
qm status 9010
```

Then destroy only the test clone:

```sh
qm destroy 9010 --purge
```

Do not destroy VM `9000`; that is the template Terraform needs.

## Verification

This step is complete when all of the following are true:

- Template VM `9000` exists.
- Template name is `ubuntu-2404-cloudinit`.
- The template has a bootable `scsi0` disk.
- The template has a cloud-init drive attached.
- The template is connected to `vmbr0`.
- QEMU guest agent is installed in the image and enabled in Proxmox.
- The VM has been converted to a Proxmox template.
- A test clone can boot, receive cloud-init networking, and accept SSH.
- `qm agent <test-vm-id> ping` succeeds for a running test clone.

Useful commands:

```sh
qm config 9000
qm list
pvesm status
```

## Operations Notes

Keep the template small and generic. The more software you bake into the image, the harder it is to understand which layer owns which behavior.

Rebuild the template intentionally when you need a new base image. For example, you might later create:

```text
9000 ubuntu-2404-cloudinit
9001 ubuntu-2404-cloudinit-2026-07
```

Then update Terraform's `template_vm_id` only after testing the new template.

Do not store application secrets, Kubernetes tokens, SSH private keys, or cluster-specific config in the template.

## Dependencies

- Step 1 complete: Proxmox networking, storage, and DHCP exclusions confirmed.
- Proxmox host reachable at `192.168.10.10`.
- Working bridge `vmbr0`.
- VM disk storage, assumed `local-lvm`.
- Image storage, assumed `/var/lib/vz/template/iso`.
- Operator SSH public key available for test clone verification.

## Related Files

- `docs/setup/01-proxmox.md`
- `docs/ip-plan.md`
- `infra/terraform/proxmox/cloud-init-template.md`
- `infra/terraform/proxmox/README.md`
- `infra/terraform/proxmox/terraform.tfvars.example`
