# ADR-0004: AWS is primary for Project 1; Azure is the second implementation

- **Status:** Accepted
- **Date:** 2026-10-27
- **Related:** RFC-001, RFC-002

## Context

The owner has AWS and Azure accounts available (GCP is not used). Full duplication of both
projects on both clouds would roughly double cost and effort without doubling learning.

## Options considered

1. **Everything on both clouds:** maximum coverage, highest cost and maintenance.
2. **One cloud per project:** cheap, but nothing learned about multi-cloud design.
3. **AWS primary, Azure implements the same module contracts for selected layers:** shows where
   the clouds really differ while keeping cost bounded.

## Decision

Option 3.

- **Project 1 (transaction platform):** AWS is primary (EKS, RDS PostgreSQL, DynamoDB,
  ElastiCache, Secrets Manager). Azure implements network, cluster (AKS), PostgreSQL and secrets
  behind the same `modules/<name>` interface.
- **Project 2 (RAG engine):** GPU node pool and external-LLM access are evaluated on Azure
  (AKS + Azure OpenAI); the rest follows the Project 1 patterns.

## Consequences

- Good: forces a cloud-neutral module interface and surfaces real differences (IAM models,
  networking, managed-service features).
- Bad: some features (DynamoDB, MSK) have no one-to-one Azure equivalent; each gap needs a
  note in `docs/learning/`.
