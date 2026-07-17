# Terraform VM Provisioning

## Purpose

Provision the Kubernetes virtual machines on Proxmox.

## Current State

The initial target is one control-plane VM and two worker VMs:

| Name | Role | IP |
| --- | --- | --- |
| `k8s-cp-01` | control plane | `192.168.10.70` |
| `k8s-worker-01` | worker | `192.168.10.71` |
| `k8s-worker-02` | worker | `192.168.10.72` |

## Configuration

Terraform configuration lives under `infra/terraform/`.

The IP plan lives in `docs/ip-plan.md`.

## Procedure

Document the exact Terraform initialization, plan, apply, and output commands here once the Proxmox provider configuration is finalized.

## Verification

VM provisioning is complete when:

- All planned VMs exist in Proxmox.
- Each VM has the expected static IP address.
- Each VM accepts SSH access.
- Terraform state reflects the created resources.

## Operations Notes

Terraform owns VM lifecycle and selected external infrastructure. It should not manage normal Kubernetes add-ons or applications after Argo CD is introduced.

## Dependencies

- Proxmox host prepared.
- Ubuntu cloud-init template available.
- Terraform variables configured.
- Static IP reservations confirmed.

## Related Files

- `infra/terraform/README.md`
- `infra/terraform/proxmox/README.md`
- `docs/ip-plan.md`
- `docs/architecture.md`
