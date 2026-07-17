# GitOps

## Purpose

Install Argo CD and define how Kubernetes add-ons and applications are reconciled from Git.

## Current State

Argo CD is the planned owner for normal in-cluster desired state after the initial cluster bootstrap.

## Configuration

GitOps manifests are expected under `kubernetes/gitops/`.

## Procedure

Document the exact Argo CD installation, access, and root application setup here once implemented.

## Verification

GitOps is ready when:

- Argo CD is running in the cluster.
- The operator can access the Argo CD UI or CLI.
- The root application syncs successfully.
- Managed add-ons are reconciled from the repository.

## Operations Notes

After Argo CD is installed, avoid applying long-lived add-ons manually. Put desired state in GitOps and let Argo CD reconcile it.

## Dependencies

- Working Kubernetes cluster.
- CNI installed.
- Repository path for GitOps manifests.

## Related Files

- `kubernetes/gitops/README.md`
- `docs/architecture.md`
- `docs/setup/08-addons.md`
