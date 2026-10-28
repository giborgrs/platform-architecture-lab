# ADR-0006: Network design, three tiers and a shared NAT in dev

- **Status:** Proposed
- **Date:** 2026-10-27
- **Related:** RFC-001, ADR-0003, ADR-0004

## Context

Kubernetes, databases and load balancers need a network that is multi-AZ, keeps data stores off
the internet, and can later host private connectivity (peering, private endpoints). AWS and
Azure model this differently, and NAT gateways are a notable hourly cost.

## Options considered

1. **Flat network, one subnet tier:** simplest, but databases share routing and rules with pods.
2. **Three tiers (public / private / data) per AZ:** clear blast-radius and routing boundaries.
3. **Per-service VPCs with Transit Gateway:** strong isolation, far too heavy for this lab.

## Decision

Option 2.

| | AWS (10.10.0.0/16) | Azure (10.20.0.0/16) |
|---|---|---|
| Edge | public /24 per AZ (LBs, NAT) | managed by AKS load balancer |
| Compute | private /20 per AZ (nodes and pods) | `snet-aks` /20 |
| Data | data /24 per AZ, no internet route | `snet-data` /24, NSG allows only AKS CIDR |
| Egress | NAT gateway (**one shared in dev**, one per AZ in prod) | NAT gateway |
| Cloud services | free S3 gateway endpoint | private endpoints (later layers) |

CIDRs are non-overlapping across clouds so they can be connected later without renumbering.

## Consequences

- Good: databases are unreachable from the internet by construction; per-AZ tiers survive an AZ loss.
- Bad: a shared NAT is a single point of failure for egress in dev; `single_nat_gateway = false` for prod.
- Cost: each NAT gateway is about US$33/month before data charges: destroy dev when idle.
- Follow-ups: VPC flow logs, interface endpoints (ECR, STS, Secrets Manager) to cut NAT traffic.
