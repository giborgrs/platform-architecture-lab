# ADR-0005: Kafka on Strimzi (in-cluster) versus managed (MSK / Event Hubs)

- **Status:** Proposed
- **Date:** 2026-10-27
- **Related:** RFC-001

## Context

Kafka is the backbone of Project 1 (domain events, Debezium CDC). Project 1 also wants to
demonstrate Kubernetes Operators for stateful workloads.

## Options considered

1. **Amazon MSK:** managed, less operational work, but costs more to leave running and hides the
   internals.
2. **Strimzi operator on Kubernetes:** portable between EKS and AKS, shows the operator pattern,
   cheaper on small nodes, but you operate it.
3. **Azure Event Hubs (Kafka API):** managed on Azure, but not full Kafka (Kafka Connect and
   Debezium have limits).

## Decision

Option 2 for learning and portability. Revisit with a new ADR if operating it becomes the
bottleneck. Record in the ADR the day-2 tasks encountered (upgrades, storage, rebalancing).

## Consequences

- Good: same manifests on both clouds; direct experience with operators and persistent volumes.
- Bad: we own upgrades, storage sizing and broker failure handling.
