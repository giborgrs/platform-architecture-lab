# RFC-002: Project 2 reference architecture, real-time AI knowledge engine (RAG and MLOps)

- **Status:** Draft
- **Date:** 2026-10-27
- **Resulting ADRs:** (to be written: vector database, GPU placement, semantic routing)

## Summary

A FastAPI-based retrieval-augmented generation service. Ingestion pipelines chunk and embed
company data into a vector database; queries are routed to the most cost-effective model; access
control is enforced at retrieval time; MLflow gates promotion of new RAG configurations.

## Goals / non-goals

- Goals: understand RAG topology, permission-aware retrieval, and MLOps promotion gates.
- Non-goals: training large models; production data volumes.

## Proposal

See [diagrams/project2-context.md](../diagrams/project2-context.md).

| Concern | Choice | Notes |
|---|---|---|
| Compute | AKS with a GPU node pool; serverless for API routing | GPUs are costly: scale to zero |
| Vector DB | Milvus (self-hosted) vs Pinecone (managed): undecided | ADR needed |
| Ingestion | Delta Live Tables or a lighter alternative | Decide after the cost check |
| Models | External foundation model + a small open-source model | Semantic router picks per query |
| Telemetry | LangSmith or an open-source equivalent | Retrieval precision, answer quality |
| Security | Per-document ACL filter at the vector layer; private networking | No public endpoints for vector DB or LLMs |
| MLOps | MLflow for experiments, prompt versions, eval gates | Separate software and data pipelines |

## Risks, cost and security

- GPU nodes can dominate the bill. Mitigation: scale to zero, spot where possible, time-box runs.
- Permission leaks via embeddings. Mitigation: store ACL metadata with each chunk and filter on it.

## Open questions

- Milvus versus Pinecone, and where each runs.
- Is Databricks justified for a learning budget, or is a lighter pipeline enough?

## Rollout plan

1. Reuse the Project 1 network and cluster modules. 2. Vector DB. 3. Ingestion. 4. RAG API.
5. Semantic routing. 6. Telemetry. 7. MLflow evaluation gate.
