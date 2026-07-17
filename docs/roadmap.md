# Roadmap

## Phase 1: Proxmox and VM Repeatability

- Confirm storage, bridge, CPU, memory, and DHCP exclusions.
- Build an Ubuntu Server 24.04 cloud-init template.
- Provision Kubernetes VMs with Terraform.
- Practice `terraform apply` and `terraform destroy`.

## Phase 2: Node Preparation and Bootstrap

- Configure base OS with Ansible.
- Install containerd and kubeadm components.
- Bootstrap the first control plane with kubeadm.
- Join workers.
- Install Cilium.

## Phase 3: GitOps and Cluster Add-ons

- Install Argo CD manually once.
- Create a root app/app-of-apps.
- Move add-ons to GitOps.
- Add MetalLB, ingress or Gateway API, cert-manager, and observability.

## Phase 4: Operations Practice

- Alerts, logs, backups, restore drills, node drains, bad rollouts, DNS failures, network policy failures, and incident reports.

## Phase 5: Advanced Topologies

- HA control plane.
- kube-vip or HAProxy/keepalived.
- etcd backup and restore.
- Physical nodes, VLANs, and improved switching.

