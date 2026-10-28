# RFC-001: Project 1 reference architecture, event-driven transaction platform

- **Status:** Draft
- **Date:** 2026-10-27
- **Resulting ADRs:** ADR-0002, ADR-0003, ADR-0004, ADR-0005

## Summary

A CQRS and event-sourced transaction platform on multi-AZ Kubernetes: writes go to PostgreSQL,
domain events flow through Kafka, reads are served from DynamoDB behind Redis, and CDC feeds a
Databricks lakehouse. Zero-trust networking with Istio mTLS; GitOps delivery.

## Goals / non-goals

- Goals: learn the full platform stack end to end; keep every choice documented; keep cost bounded.
- Non-goals: production-grade traffic, real payments, full feature parity on Azure.

## Proposal

See [diagrams/project1-context.md](../diagrams/project1-context.md).

| Concern | Choice | Notes |
|---|---|---|
| Compute | EKS (primary), AKS (second impl.) | Multi-AZ; spot node group for stateless pods |
| Write store | PostgreSQL (RDS / Azure DB) | Source of truth, CDC source |
| Read store | DynamoDB + Redis | Azure gap: Cosmos DB as nearest equivalent |
| Messaging | Kafka via Strimzi | ADR-0005 |
| CDC | Debezium on Kafka Connect | Postgres logical replication |
| Analytics | Databricks + Delta Lake | Cost-gate; may be a late phase |
| Edge | API gateway (Kong) | Frontends: Angular, Flutter |
| Security | Istio mTLS, OIDC, Vault or Secrets Manager | Decide secret injection in a later ADR |
| Delivery | GitHub Actions + ArgoCD, Helm canaries | ADR-0002 |

## Alternatives considered

Covered per decision in the ADRs.

## Risks, cost and security

- Cost: EKS control plane, NAT gateways, RDS, MSK-style services and Databricks bill by the hour.
  Mitigation: budgets and alerts first, dev only, destroy nightly.
- Complexity: Istio plus Kafka plus CDC is a lot at once. Mitigation: phased rollout below.

## Open questions

- Event store: Postgres append-only table or a dedicated store?
- Vault versus cloud-native secrets for runtime injection?

## Rollout plan

1. Bootstrap state and OIDC. 2. Network. 3. Cluster. 4. Postgres, Redis, DynamoDB.
5. ArgoCD and platform add-ons (Istio, Strimzi). 6. Sample .NET service. 7. CDC and lakehouse.
