# Proxmox Kubernetes Homelab

Production-style Kubernetes homelab for learning DevOps, Kubernetes operations, IaC, GitOps, observability, security, CI/CD, backups, and failure recovery.

## Current Direction

- Proxmox provisions Ubuntu Server VMs.
- Terraform owns VM lifecycle and selected external infrastructure later.
- Ansible owns base OS and Kubernetes node preparation.
- kubeadm bootstraps upstream Kubernetes.
- Argo CD owns normal in-cluster add-ons and applications.

## Documentation

The living documentation starts in `docs/README.md`.

Use it as the source of truth for understanding, building, operating, and troubleshooting the homelab. Setup instructions live under `docs/setup/`, operational procedures under `docs/operations/`, and stable technical reference under `docs/reference/`.

## First Milestone

1. Finalize the IP plan in `docs/ip-plan.md`.
2. Build the Ubuntu cloud-init template in Proxmox.
3. Provision the first three Kubernetes VMs with Terraform.
4. Prepare nodes with Ansible.
5. Bootstrap Kubernetes with kubeadm.
