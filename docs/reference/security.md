# Security Reference

## Purpose

Document security boundaries, access rules, secrets handling, certificates, and policy decisions.

## Current State

Security implementation details will be documented as the cluster is built.

## Configuration

Security reference should eventually include:

- SSH access model.
- Kubernetes RBAC model.
- Secrets management approach.
- Certificate management.
- Network policies.
- Image and supply-chain policy.

## Procedure

Update this page when adding or changing security controls.

## Verification

Each security control should include a command or test that proves the intended access is allowed and unintended access is blocked.

## Operations Notes

Do not store secret values in this repository unless they are intentionally encrypted and the encryption workflow is documented.

## Dependencies

- Operator identity and SSH keys.
- Kubernetes API access.
- Secrets management decision.
- Certificate issuer decision.

## Related Files

- `docs/reference/credentials.md`
- `docs/operations/access.md`
