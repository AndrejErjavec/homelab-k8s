# Troubleshooting

## Purpose

Collect common diagnostics and recovery steps for cluster failures.

## Current State

Troubleshooting procedures will be expanded as the cluster is built and tested.

## Configuration

Important diagnostic areas:

- Proxmox VM state.
- Node networking.
- kubelet.
- containerd.
- CNI.
- CoreDNS.
- Argo CD sync.
- Load balancer and ingress.

## Procedure

Start with broad health checks:

```sh
kubectl get nodes
kubectl get pods -A
kubectl get events -A --sort-by=.lastTimestamp
```

Add targeted diagnostics as each layer is implemented.

## Verification

A troubleshooting procedure is complete when it includes both the diagnostic command and the expected healthy result.

## Operations Notes

Record reusable fixes here. Incident-specific timelines belong under `docs/incidents/`.

## Dependencies

- Working operator access.
- `kubectl` configured.
- SSH access for node-level diagnostics.

## Related Files

- `docs/operations/access.md`
- `docs/incidents/README.md`
