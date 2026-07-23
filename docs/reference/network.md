# Network Reference

## Purpose

Document stable network values and how traffic flows through the homelab.

## Current State

The planned LAN is `192.168.10.0/24`, with Kubernetes nodes in `192.168.10.90-192.168.10.99` and MetalLB services in `192.168.10.200-192.168.10.220`.

## Configuration

Primary network values are maintained in `docs/ip-plan.md`.

## Procedure

When adding a new networked service:

1. Decide whether it needs a DNS name.
2. Decide whether it is exposed through ingress, Gateway API, or a direct load balancer service.
3. Reserve or document any required LAN IP address.
4. Update DNS after the service exists.
5. Add verification commands to the relevant setup or operations document.

## Verification

Use these checks as the network implementation grows:

```sh
kubectl get nodes -o wide
kubectl get svc -A
kubectl get endpoints -A
```

## Operations Notes

Keep Kubernetes node IPs, MetalLB addresses, and future VIPs outside the router DHCP scope.

## Dependencies

- Router or local DNS control.
- Proxmox bridge configuration.
- CNI installed for pod networking.
- MetalLB or equivalent installed for load balancer services.

## Related Files

- `docs/ip-plan.md`
- `docs/setup/06-cni.md`
- `docs/setup/08-addons.md`
