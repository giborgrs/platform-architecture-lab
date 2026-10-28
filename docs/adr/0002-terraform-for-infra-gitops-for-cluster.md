# ADR-0002: Terraform provisions infrastructure; GitOps manages in-cluster workloads

- **Status:** Proposed
- **Date:** 2026-10-27
- **Related:** RFC-001

## Context

Both projects run on Kubernetes. Something must create the cloud resources (network, cluster,
databases, IAM) and something must deploy what runs inside the cluster (Istio, Kafka, Debezium,
Vault, the apps). Using one tool for both couples slow, risky infrastructure changes to fast,
frequent application changes.

## Options considered

1. **Terraform for everything** (including Helm releases): one tool, but every app change runs
   through a Terraform plan against cluster state, and drift detection is weak.
2. **Terraform up to the cluster, GitOps (ArgoCD) inside it:** clear ownership boundary,
   continuous reconciliation, easy rollback by reverting a commit.
3. **Scripts and kubectl in CI:** simple, but no drift correction and no declarative audit trail.

## Decision

Option 2. Terraform owns network, cluster, managed data services, IAM and the one-time install of
ArgoCD. ArgoCD owns everything else via an app-of-apps in `gitops/`.

## Consequences

- Good: each tool does what it's best at; app deploys don't need cloud credentials.
- Bad: two workflows to learn; the hand-off (Terraform installs ArgoCD, ArgoCD takes over) needs
  care so the two never manage the same object.
- Follow-up: Terraform outputs (cluster endpoint, IAM role ARNs for service accounts) must be
  consumable by the gitops values.
