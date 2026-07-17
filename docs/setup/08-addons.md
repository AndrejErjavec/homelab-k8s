# Cluster Add-ons

## Purpose

Install and document supporting Kubernetes services such as load balancing, ingress, certificates, observability, policy, and application dependencies.

## Current State

Planned add-ons include MetalLB, ingress or Gateway API, cert-manager, and observability.

## Configuration

The planned MetalLB address pool is `192.168.10.200-192.168.10.220`.

## Procedure

Document add-on installation steps here as each add-on is introduced. Prefer GitOps-managed manifests once Argo CD is available.

## Verification

Each add-on should include its own verification commands and expected behavior.

## Operations Notes

Add operational notes for upgrades, restarts, data retention, alerting, and failure recovery as add-ons are implemented.

## Dependencies

- Working Kubernetes cluster.
- CNI installed.
- Argo CD installed for GitOps-managed add-ons.
- LAN IP reservations for load balancer services.

## Related Files

- `docs/setup/07-gitops.md`
- `docs/reference/network.md`
- `docs/ip-plan.md`
