# Proxmox Preparation

## Purpose

Prepare the Proxmox host and LAN assumptions before creating Kubernetes virtual machines.

This step does not create Kubernetes yet. The goal is to make sure the virtualization layer, storage, network, DNS assumptions, and IP reservations are clear enough that Terraform can later create and destroy VMs repeatably without colliding with existing homelab services.

## Concepts

### Proxmox VE

Proxmox VE is the virtualization platform that will run the Kubernetes nodes as virtual machines. In this lab, Proxmox is the infrastructure layer. It owns VM execution, virtual disks, virtual NICs, snapshots, and host-level storage.

Kubernetes will run inside VMs, not directly on the Proxmox host. That separation is important:

- Proxmox manages machines.
- Terraform asks Proxmox to create machines.
- Ansible prepares the guest OS inside those machines.
- kubeadm turns those machines into Kubernetes nodes.
- Argo CD manages software inside Kubernetes after bootstrap.

Keeping those boundaries clear is production-relevant. In real environments, the cloud or virtualization layer is usually separate from cluster configuration and application delivery.

### Proxmox Node

A Proxmox node is a physical server running Proxmox VE. Your first node is a single-server Proxmox host at:

```text
192.168.10.10
```

Later, the extra mini PCs could become additional Proxmox nodes or bare-metal Kubernetes nodes. For now, assume a single Proxmox node and design for repeatability rather than high availability.

### Linux Bridge

Proxmox normally connects VMs to the LAN through a Linux bridge such as `vmbr0`.

A bridge acts like a virtual switch inside the Proxmox host:

- The physical NIC connects the host to the LAN.
- `vmbr0` connects VMs to that same LAN.
- Each VM gets a virtual NIC attached to the bridge.
- From the router's point of view, the VMs appear as normal LAN hosts.

For this lab, Terraform will attach Kubernetes VMs to:

```text
vmbr0
```

This keeps the first build simple. VLANs can come later after the managed switch upgrade.

### Static IPs and DHCP Exclusions

Kubernetes nodes should have stable IP addresses. The control plane endpoint, kubelet registration, Ansible inventory, DNS names, and operational documentation all become easier when node IPs do not change.

This lab reserves:

```text
192.168.10.70-192.168.10.79
```

for Kubernetes nodes and related future addresses.

The router or DHCP server must not hand out these addresses dynamically. If DHCP assigns one of these IPs to another device, Terraform may later create a VM with a duplicate IP, causing intermittent and difficult network failures.

### DNS

DNS maps names to IP addresses. For local-only services, this lab uses:

```text
home.arpa
```

`home.arpa` is appropriate for internal home networks and avoids mixing private lab DNS with public DNS for `erjaveclab.com`.

At this stage, the most important DNS name is:

```text
k8s-api.home.arpa -> 192.168.10.70
```

In the first non-HA cluster, this points directly at `k8s-cp-01`. Later, when you rebuild as a highly available control plane, the same name can point to the API virtual IP.

### MetalLB Reservation

Kubernetes `LoadBalancer` services need LAN IPs when running outside a cloud provider. MetalLB provides those IPs on bare metal or homelab networks.

This lab reserves:

```text
192.168.10.200-192.168.10.220
```

for future MetalLB services. Do not use this range for DHCP clients, Proxmox hosts, or fixed infrastructure.

### ZFS and ARC

Your Proxmox host uses ZFS. ZFS uses memory for the Adaptive Replacement Cache, usually called ARC. This is normal: Linux may show high memory usage even when the system is healthy, because ZFS is using RAM as a cache to improve disk performance.

Do not cap ARC just because memory looks high. Consider capping ARC only if you see real memory pressure, such as:

- swap usage growing under normal load
- VMs being killed or failing to allocate memory
- host responsiveness problems
- sustained low available memory while workloads are active

For your 32 GB RAM host, an ARC cap around 8-12 GB can be reasonable later if Kubernetes VMs and existing services compete for memory. It is not required before evidence of pressure.

### Storage Names

Proxmox storage names are local to the host. Terraform needs the correct datastore name when it creates VM disks.

Common names include:

- `local`: usually directory storage, often used for ISO files, snippets, and backups.
- `local-lvm`: LVM-thin storage, commonly used for VM disks.
- ZFS-backed storage names: depend on how the host was installed and configured.

The Terraform defaults currently assume:

```text
target_datastore_id     = local-lvm
cloud_init_datastore_id = local-lvm
```

Confirm these exist before applying Terraform.

## Current State

Planned values are maintained in `docs/ip-plan.md`.

| Item | Value |
| --- | --- |
| LAN CIDR | `192.168.10.0/24` |
| Gateway | `192.168.10.1` |
| DNS server | `192.168.10.12` |
| Proxmox host | `192.168.10.10` |
| Proxmox bridge | `vmbr0` |
| Kubernetes node reservation | `192.168.10.70-192.168.10.79` |
| MetalLB reservation | `192.168.10.200-192.168.10.220` |
| Local domain | `home.arpa` |

## Configuration

Before continuing, confirm or update these files:

- `docs/ip-plan.md`
- `infra/terraform/proxmox/terraform.tfvars.example`
- future local `infra/terraform/proxmox/terraform.tfvars`

The active assumptions for Terraform are:

```hcl
proxmox_endpoint = "https://192.168.10.10:8006/"
network_bridge   = "vmbr0"
gateway_ipv4     = "192.168.10.1"
dns_servers      = ["192.168.10.12"]
dns_domain       = "home.arpa"
```

## Procedure

### 1. Confirm Proxmox Web Access

From your workstation, open:

```text
https://192.168.10.10:8006/
```

Expected result:

- The Proxmox login page loads.
- Browser warns about a self-signed certificate unless you installed a trusted cert.
- You can log in with your Proxmox user.

Why this matters:

Terraform will later use the same Proxmox API endpoint. If the web UI is unreachable, Terraform will not be able to provision VMs.

### 2. Confirm SSH Access to Proxmox

From your workstation:

```sh
ssh root@192.168.10.10
```

or, if you use a non-root admin user:

```sh
ssh <your-admin-user>@192.168.10.10
```

Expected result:

- SSH login succeeds.
- You can run Proxmox inspection commands.

Why this matters:

Even if Terraform uses the API, you still need SSH for host inspection, troubleshooting, template creation, and emergency recovery.

### 3. Confirm the Proxmox Host IP and Bridge

Run on the Proxmox host:

```sh
ip address show vmbr0
```

Expected result:

- `vmbr0` exists.
- It has `192.168.10.10/24`, or the Proxmox host is otherwise reachable through the expected management path.

Also inspect the Proxmox network configuration:

```sh
cat /etc/network/interfaces
```

Look for a bridge similar to:

```text
auto vmbr0
iface vmbr0 inet static
    address 192.168.10.10/24
    gateway 192.168.10.1
    bridge-ports <physical-nic>
    bridge-stp off
    bridge-fd 0
```

Do not blindly edit this file on a remote host unless you have console access or a rollback plan. A bad bridge change can disconnect the Proxmox server from the LAN.

### 4. Confirm LAN Connectivity from Proxmox

Run on the Proxmox host:

```sh
ping -c 4 192.168.10.1
```

Then test DNS:

```sh
getent hosts debian.org
```

Expected result:

- Gateway ping succeeds.
- DNS lookup returns one or more IP addresses.

Why this matters:

The Proxmox host will need outbound access to download the Ubuntu cloud image in the next step unless you download and upload it manually.

### 5. Confirm DHCP Exclusions

In your router, DHCP server, Pi-hole, AdGuard Home, or whichever service controls DHCP, make sure these addresses are not inside the dynamic DHCP pool:

```text
192.168.10.10
192.168.10.69-192.168.10.79
192.168.10.200-192.168.10.220
```

If your router supports reservations but not exclusions, set the DHCP range to avoid the static ranges. For example:

```text
Dynamic DHCP: 192.168.10.100-192.168.10.199
```

This is only an example. Keep any existing static devices in mind.

Why this matters:

The lab depends on predictable addressing. Duplicate IPs are especially painful in Kubernetes because symptoms can appear as API timeouts, broken DNS, failed image pulls, random node disconnects, or services pointing at the wrong machine.

### 6. Confirm Local DNS Control

Decide where local DNS records will live. Common choices:

- router local DNS
- Pi-hole
- AdGuard Home
- Unbound
- dnsmasq

Create or plan this record:

```text
k8s-api.home.arpa -> 192.168.10.70
```

You may wait to create app records such as `argocd.home.arpa` and `grafana.home.arpa` until ingress or MetalLB exists.

From your workstation, after creating the record:

```sh
nslookup k8s-api.home.arpa
```

Expected result:

```text
192.168.10.70
```

If the record does not resolve yet, do not block the Proxmox preparation step. Just document where DNS will be managed and create the record before kubeadm bootstrap.

### 7. Confirm Proxmox Storage Names

Run on the Proxmox host:

```sh
pvesm status
```

Expected result:

- A storage named `local` exists for images or ISO files.
- A VM-capable datastore exists for VM disks, currently assumed to be `local-lvm`.

Look at the `Content` column. VM disk storage should support `images`. ISO/template storage should support `iso` or file content depending on how you use it.

If your VM disk datastore is not `local-lvm`, update Terraform later:

```hcl
target_datastore_id     = "<your-vm-disk-storage>"
cloud_init_datastore_id = "<your-cloudinit-storage>"
```

### 8. Check Available CPU and Memory

Run on the Proxmox host:

```sh
free -h
```

```sh
uptime
```

If ZFS tools are available:

```sh
arc_summary | head -n 40
```

If `arc_summary` is unavailable:

```sh
cat /proc/spl/kstat/zfs/arcstats | head
```

Expected interpretation:

- High used memory is not automatically bad on a ZFS host.
- Swap should not be growing heavily during normal activity.
- The first Kubernetes VM layout needs roughly 14-16 GB RAM depending on worker sizing.

Initial VM plan:

| VM | RAM |
| --- | ---: |
| `k8s-cp-01` | 4 GB |
| `k8s-worker-01` | 6 GB |
| `k8s-worker-02` | 6 GB |

If the host is already memory constrained, reduce workers to 4 GB temporarily and increase later.

### 9. Check Disk Capacity

Run on the Proxmox host:

```sh
pvesm status
```

If using ZFS:

```sh
zpool list
```

```sh
zfs list
```

Expected planning requirement:

- Template image: small, usually a few GB.
- Kubernetes VM disks: `50 + 60 + 60 = 170 GB` provisioned.
- Extra room for package downloads, container images, logs, and future storage experiments.

Thin provisioning can make disks look cheaper than they are. Monitor real pool usage, not just VM disk definitions.

### 10. Confirm Time Synchronization

Run on the Proxmox host:

```sh
timedatectl
```

Expected result:

- Time zone is intentional.
- NTP or system clock synchronization is active.

Why this matters:

Bad time synchronization breaks TLS, certificates, logs, metrics, Kubernetes node health, and GitOps troubleshooting.

### 11. Document Final Decisions

Update `docs/ip-plan.md` if any value changed:

- Proxmox IP
- gateway
- DNS server
- bridge
- Kubernetes node range
- MetalLB range
- local domain

Then update the Terraform example if needed:

```text
infra/terraform/proxmox/terraform.tfvars.example
```

Do not commit a real `terraform.tfvars` file if it contains credentials.

## Verification

This step is complete when all of the following are true:

- Proxmox web UI loads at `https://192.168.10.10:8006/`.
- SSH access to the Proxmox host works.
- `vmbr0` exists and is the intended VM bridge.
- DHCP will not allocate Kubernetes node, future API VIP, or MetalLB addresses.
- DNS management location is known.
- `k8s-api.home.arpa` is either created or explicitly planned.
- Proxmox storage names for VM disks and cloud-init disks are known.
- Host memory and disk capacity are sufficient for the initial three VMs.
- `docs/ip-plan.md` matches the real environment.

Useful verification commands:

```sh
ip address show vmbr0
pvesm status
free -h
timedatectl
```

## Operations Notes

Keep Proxmox host configuration outside Kubernetes GitOps ownership. Terraform may provision VMs, but Proxmox host lifecycle, networking, ZFS, package updates, and hardware maintenance remain separate operational responsibilities.

Avoid making multiple major infrastructure changes at once. For example, do not combine first Kubernetes VM provisioning with bridge redesign, VLAN migration, storage migration, and router replacement. Change one layer, verify it, then proceed.

Do not start by exposing Kubernetes publicly. Build internal repeatability, DNS, certificates, observability, policy, and backup practice first.

## Dependencies

- Working Proxmox installation.
- LAN gateway at `192.168.10.1`.
- DNS server at `192.168.10.12`.
- Proxmox reachable at `192.168.10.10`.
- DHCP exclusions configured before static VM addresses are used.
- Storage available for at least the initial VM disks.

## Related Files

- `docs/ip-plan.md`
- `docs/architecture.md`
- `docs/reference/network.md`
- `infra/terraform/proxmox/README.md`
- `infra/terraform/proxmox/terraform.tfvars.example`
