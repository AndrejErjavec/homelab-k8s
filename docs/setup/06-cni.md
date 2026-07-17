# Kubernetes CNI

## Purpose

Install the Kubernetes container network interface so pods can communicate across nodes.

## Current State

Cilium is the planned initial CNI.

## Configuration

The planned pod CIDR is `10.244.0.0/16`.

## Procedure

Document the exact Cilium installation method and values here once selected.

## Verification

CNI installation is complete when:

- Cilium pods are running.
- All Kubernetes nodes report `Ready`.
- Pods can communicate across nodes.
- Cluster DNS works from a test pod.

## Operations Notes

Network policy behavior, Cilium upgrades, and troubleshooting notes should be linked from `docs/operations/troubleshooting.md` when implemented.

## Dependencies

- kubeadm control plane initialized.
- Worker nodes joined.
- Pod CIDR does not overlap with the LAN or other routed networks.

## Related Files

- `docs/setup/05-kubernetes-bootstrap.md`
- `docs/reference/network.md`
- `docs/ip-plan.md`
