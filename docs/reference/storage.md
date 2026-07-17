# Storage Reference

## Purpose

Document storage choices for Proxmox VMs, Kubernetes persistent volumes, application data, and backups.

## Current State

Storage implementation details are not yet finalized.

## Configuration

Document these values when selected:

- Proxmox storage pool names.
- VM disk sizes.
- Kubernetes storage classes.
- Persistent volume backup location.
- Retention policies.

## Procedure

Update this page when adding or changing storage backends.

## Verification

Storage is ready when a test workload can create, write to, restart with, and delete a persistent volume claim as expected.

## Operations Notes

Treat application data and etcd data as recoverability concerns, not only capacity concerns.

## Dependencies

- Proxmox storage available.
- Kubernetes cluster running.
- Storage class or CSI driver selected for persistent workloads.

## Related Files

- `docs/operations/backups.md`
- `docs/setup/08-addons.md`
