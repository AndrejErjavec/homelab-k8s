# Access

## Purpose

Document how operators access Proxmox, Kubernetes nodes, the Kubernetes API, and cluster services.

## Current State

Cluster access procedures will be completed as the infrastructure is built.

## Configuration

Planned access points:

| Target | Address |
| --- | --- |
| Proxmox | `192.168.10.10` |
| Kubernetes API | `k8s-api.home.arpa` |
| Initial control plane | `192.168.10.70` |

## Procedure

Document SSH, kubeconfig, and service access steps here as they are configured.

## Verification

Access is verified when the operator can:

- SSH to each node.
- Run `kubectl get nodes`.
- Reach configured service DNS names after services exist.

## Operations Notes

Keep credentials and secret material out of this file. Document where they are stored and how to retrieve them safely.

## Dependencies

- DNS or local host resolution.
- SSH keys configured.
- kubeconfig generated after cluster bootstrap.

## Related Files

- `docs/ip-plan.md`
- `docs/reference/credentials.md`
