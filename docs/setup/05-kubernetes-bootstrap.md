# Kubernetes Bootstrap

## Purpose

Bootstrap the Kubernetes control plane with kubeadm and join worker nodes.

## Current State

The first milestone uses a single control-plane node and two worker nodes.

## Configuration

Initial planned cluster networks:

| Network | Value |
| --- | --- |
| Pod CIDR | `10.244.0.0/16` |
| Service CIDR | `10.96.0.0/12` |
| Initial API endpoint | `192.168.10.70` |
| Future API VIP | `192.168.10.69` |

## Procedure

Document the exact kubeadm init, kubeconfig setup, and worker join commands here once bootstrap is performed.

## Verification

Bootstrap is complete when:

- The control-plane node is visible through `kubectl get nodes`.
- Worker nodes have joined the cluster.
- Nodes become `Ready` after the CNI is installed.

## Operations Notes

The initial control plane is not highly available. The future HA design should use the reserved API VIP.

## Dependencies

- Nodes prepared by Ansible.
- Pod and service CIDRs selected.
- CNI installation plan selected.

## Related Files

- `docs/setup/04-ansible-node-prep.md`
- `docs/setup/06-cni.md`
- `docs/ip-plan.md`
- `docs/architecture.md`
