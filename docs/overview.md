# Overview

## Purpose

This homelab is a production-style Kubernetes environment for learning infrastructure automation, cluster operations, GitOps, observability, security, backups, and failure recovery.

## Current State

The repository is organized around a staged Kubernetes build:

1. Proxmox provides the virtualization platform.
2. Terraform provisions Ubuntu Server virtual machines.
3. Ansible prepares the operating system and Kubernetes prerequisites.
4. kubeadm bootstraps the Kubernetes cluster.
5. Argo CD manages in-cluster add-ons and applications through GitOps.

The first cluster target is one control-plane node and two worker nodes.

## Configuration

Core planning values are documented in:

- `docs/ip-plan.md`
- `docs/architecture.md`
- `docs/roadmap.md`

## Procedure

Build the homelab in this order:

1. Prepare Proxmox and validate the network plan.
2. Create the Ubuntu cloud-init template.
3. Provision Kubernetes VMs with Terraform.
4. Prepare nodes with Ansible.
5. Bootstrap Kubernetes with kubeadm.
6. Install the CNI.
7. Install Argo CD.
8. Move add-ons and applications into GitOps.

## Verification

At a high level, the cluster is considered usable when:

- The Kubernetes nodes are reachable over SSH.
- `kubectl get nodes` shows all nodes as `Ready`.
- Core system pods are running.
- Argo CD is installed and can reconcile the GitOps root application.

## Operations Notes

Use `docs/operations/` for day-to-day cluster access, maintenance, backups, upgrades, and troubleshooting.

## Dependencies

- Proxmox host with a working bridge network.
- LAN IP reservations that do not overlap with DHCP.
- Ubuntu Server cloud-init template.
- Terraform and Ansible installed on the operator workstation.
- SSH access from the operator workstation to provisioned VMs.

## Related Files

- `README.md`
- `docs/architecture.md`
- `docs/ip-plan.md`
- `docs/roadmap.md`
- `infra/terraform/README.md`
- `infra/ansible/README.md`
