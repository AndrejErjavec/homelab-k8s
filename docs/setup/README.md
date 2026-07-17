# Setup Guide

Follow these documents in order to build the homelab from the virtualization layer through Kubernetes add-ons.

| Step | Document | Purpose |
| ---: | --- | --- |
| 1 | `01-proxmox.md` | Prepare Proxmox host assumptions and network prerequisites. |
| 2 | `02-ubuntu-template.md` | Build the Ubuntu Server cloud-init template used by Terraform. |
| 3 | `03-terraform-vms.md` | Provision Kubernetes virtual machines. |
| 4 | `04-ansible-node-prep.md` | Configure operating system and Kubernetes prerequisites. |
| 5 | `05-kubernetes-bootstrap.md` | Bootstrap the cluster with kubeadm and join workers. |
| 6 | `06-cni.md` | Install and verify the Kubernetes CNI. |
| 7 | `07-gitops.md` | Install Argo CD and connect the cluster to GitOps. |
| 8 | `08-addons.md` | Install cluster add-ons such as ingress, certificates, observability, and load balancing. |
