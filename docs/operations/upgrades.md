# Upgrades

## Purpose

Document upgrade procedures for Kubernetes, nodes, and cluster add-ons.

## Current State

Upgrade procedures will be documented after the first working cluster is built.

## Configuration

Track versions for:

- Kubernetes.
- containerd.
- kubeadm, kubelet, and kubectl.
- Cilium.
- Argo CD.
- Cluster add-ons.

## Procedure

Document exact upgrade steps here when versions and tooling are selected.

## Verification

An upgrade is complete when:

- All nodes are healthy.
- System pods are running.
- GitOps sync is healthy.
- Application smoke tests pass.

## Operations Notes

Drain worker nodes before disruptive maintenance when possible. Treat control-plane upgrades separately from worker upgrades.

## Dependencies

- Working backup procedure for important state.
- Known current and target versions.
- Maintenance window if services are user-facing.

## Related Files

- `docs/operations/backups.md`
- `docs/operations/node-maintenance.md`
