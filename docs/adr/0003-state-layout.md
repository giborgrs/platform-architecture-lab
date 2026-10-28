# ADR-0003: One Terraform state per layer, per cloud, per environment

- **Status:** Proposed
- **Date:** 2026-10-27

## Context

A single state file for everything means every plan touches every resource, a mistake can affect
the whole stack, and a lock blocks all work. Layers change at very different speeds: networks
rarely, clusters occasionally, apps constantly.

## Options considered

1. **One state per environment:** simple, but large blast radius and slow plans.
2. **One state per layer** (`10-network`, `20-cluster`, `30-data`, `40-platform-bootstrap`) under
   `live/<project>/<cloud>/<env>/`: small blast radius, fast plans, explicit dependencies.
3. **Terragrunt or Terraform workspaces:** less duplication, but extra tooling to learn first.

## Decision

Option 2. Layers read each other's outputs via `terraform_remote_state` (revisit if this becomes
painful). State lives in S3 (`use_lockfile = true`) for AWS and in an Azure Storage container for
Azure. CI authenticates with OIDC; no long-lived keys.

## Consequences

- Good: a bad change to `30-data` can't touch the network.
- Bad: apply order matters; some duplication between environments.
- Follow-ups: replace `AdministratorAccess` on the CI role with a scoped policy; consider
  Terragrunt later if duplication hurts (new ADR).
