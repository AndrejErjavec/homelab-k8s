# Backups

## Purpose

Document backup and restore procedures for the cluster and supporting infrastructure.

## Current State

Backup procedures are not yet implemented.

## Configuration

Backup scope should eventually include:

- Terraform state.
- Ansible inventory and configuration.
- Kubernetes manifests.
- etcd.
- Persistent volumes.
- Application data.

## Procedure

Document backup and restore commands here as each backup mechanism is implemented.

## Verification

A backup is not complete until a restore test or validation command proves the backup can be used.

## Operations Notes

Prefer documented restore drills over backup-only procedures.

## Dependencies

- Running cluster for Kubernetes-level backups.
- Backup destination selected.
- Credential handling documented.

## Related Files

- `docs/operations/node-maintenance.md`
- `docs/reference/storage.md`
- `docs/reference/credentials.md`
