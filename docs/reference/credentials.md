# Credentials Reference

## Purpose

Document where credentials are stored, how they are retrieved, and how they are rotated without storing secret values in plaintext documentation.

## Current State

Credential storage and secrets management are not yet finalized.

## Configuration

Document credential locations for:

- Proxmox access.
- SSH keys.
- Terraform provider credentials.
- Kubernetes kubeconfig.
- Argo CD bootstrap credentials.
- Application credentials.

## Procedure

When adding a credential:

1. Document what the credential is used for.
2. Document where it is stored.
3. Document who or what needs access.
4. Document how to rotate it.
5. Do not include the secret value.

## Verification

Credential documentation is complete when another operator can identify where to retrieve or rotate the credential without the value being exposed in Git.

## Operations Notes

Prefer a single documented secrets workflow over one-off credential handling per component.

## Dependencies

- Chosen password manager, secret store, or encrypted Git workflow.
- Access policy for the operator workstation and cluster.

## Related Files

- `docs/reference/security.md`
- `docs/operations/access.md`
