# Homelab Kubernetes Documentation

This directory is the living documentation for the Kubernetes homelab. It should explain the cluster well enough to rebuild it, operate it, and understand why each layer exists.

## Documentation Structure

| Area | Purpose |
| --- | --- |
| `overview.md` | High-level explanation of the homelab and how the pieces fit together. |
| `architecture.md` | Responsibility boundaries, topology, and design decisions. |
| `ip-plan.md` | LAN, node, Kubernetes, MetalLB, and DNS addressing plan. |
| `setup/` | Ordered build instructions from Proxmox through GitOps and add-ons. |
| `operations/` | Day-to-day access, maintenance, backups, upgrades, and troubleshooting. |
| `reference/` | Stable technical reference for networking, storage, security, and credentials handling. |
| `runbooks/` | Narrow command-focused procedures when a standalone runbook is useful. |
| `incidents/` | Incident reports and postmortems. |

## Standard Page Format

Use this section layout for setup, operations, and reference pages unless a page has a clear reason to differ.

```md
# Topic Name

## Purpose

What this component or procedure is for.

## Current State

What exists now in the homelab.

## Configuration

Important settings, paths, IPs, versions, manifests, Terraform variables, Ansible inventory, or Kubernetes objects.

## Procedure

Step-by-step instructions to build, configure, or repeat the work.

## Verification

Commands that prove the setup works.

## Operations Notes

How to use, maintain, restart, upgrade, or troubleshoot it.

## Dependencies

What must exist before this step works.

## Related Files

Repository files that define or support this part of the system.
```

## Documentation Rules

- Keep documentation as the final, reusable source of truth, not as a chronological change log.
- Update the permanent page that matches the system area being changed.
- Prefer exact commands, expected results, file paths, IP addresses, and object names.
- Keep setup steps ordered and repeatable.
- Put troubleshooting and maintenance guidance under `operations/`.
- Put stable values and design reference under `reference/`.
