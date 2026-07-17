# Ansible Node Preparation

## Purpose

Prepare Ubuntu VMs for Kubernetes by configuring operating system settings, packages, container runtime, and kubeadm prerequisites.

## Current State

Ansible is the intended owner for base OS and Kubernetes node preparation.

## Configuration

Ansible configuration lives under `infra/ansible/`.

Expected responsibilities include:

- Base packages.
- Kernel modules and sysctl settings.
- Swap configuration.
- containerd.
- kubeadm, kubelet, and kubectl.

## Procedure

Document the exact inventory, playbook, and command sequence here once the Ansible implementation is finalized.

## Verification

Node preparation is complete when each VM has the required container runtime and Kubernetes components installed, and kubelet is ready for kubeadm bootstrap or join.

## Operations Notes

Use Ansible for repeatable node configuration. Avoid manual package changes on individual nodes unless documenting an emergency recovery procedure.

## Dependencies

- Terraform-provisioned VMs.
- SSH access to each node.
- Ansible inventory that matches the Terraform output or static IP plan.

## Related Files

- `infra/ansible/README.md`
- `docs/setup/03-terraform-vms.md`
- `docs/architecture.md`
