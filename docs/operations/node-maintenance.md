# Node Maintenance

## Purpose

Document procedures for draining, rebooting, replacing, and recovering Kubernetes nodes.

## Current State

Node maintenance procedures will be completed after the cluster exists.

## Configuration

Initial nodes:

| Name | Role | IP |
| --- | --- | --- |
| `k8s-cp-01` | control plane | `192.168.10.91` |
| `k8s-worker-01` | worker | `192.168.10.92` |
| `k8s-worker-02` | worker | `192.168.10.93` |

## Procedure

Document drain, reboot, uncordon, replacement, and recovery procedures here.

## Verification

Node maintenance is complete when:

- The node reports `Ready`.
- Workloads return to the desired replica count.
- System pods are healthy.

## Operations Notes

The initial cluster has a single control-plane node, so control-plane maintenance may interrupt API availability.

## Dependencies

- Working `kubectl` access.
- SSH access to nodes.
- Backup procedure for critical state before destructive recovery work.

## Related Files

- `docs/setup/05-kubernetes-bootstrap.md`
- `docs/operations/backups.md`
