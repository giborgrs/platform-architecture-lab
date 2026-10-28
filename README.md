# Multi-cloud platform lab (AWS + Azure)

Infrastructure as code and architecture records for two reference architectures:

1. **Project 1:** event-driven transaction platform (CQRS, Kafka, Kubernetes, GitOps).
2. **Project 2:** real-time AI knowledge engine (RAG, vector search, MLOps).

AWS is primary for Project 1; Azure is the second implementation. See
[ADR-0004](docs/adr/0004-cloud-roles.md).

## Layout

```
docs/
  adr/            Architecture Decision Records (template.md + numbered ADRs)
  rfc/            Proposals discussed before deciding
  diagrams/       Mermaid diagrams (render on GitHub)
  learning/       Notes per build phase
bootstrap/
  aws/            S3 state bucket + GitHub OIDC role (run manually, local state)
  azure/          Storage account for state (run manually, local state)
modules/          Cloud-neutral module contracts (kubernetes, postgres, secrets, ...) with
                  one implementation per cloud, to be added phase by phase
live/             One root module per layer, cloud and environment:
                  live/<project>/<cloud>/<env>/<NN-layer>/
gitops/           ArgoCD app-of-apps, Helm values (added once a cluster exists)
```

`infra/`, `modules/network`, `modules/container_app` and `environments/` are the original Azure
Container Apps starter. They are kept for reference until the first real layer replaces them.

## No account IDs in the repo

Subscription, tenant and AWS account IDs are not committed. Locally use `az login` and
`aws sso login`; in CI use GitHub environment secrets. Put local-only values in
`*.auto.tfvars` (gitignored). Never commit keys or `*.tfstate`.

## Getting started

1. Read `docs/adr/` (start with 0001 to 0004).
2. Bootstrap AWS state:

   ```powershell
   aws sso login --profile <your-profile>
   cd bootstrap/aws
   terraform init
   terraform apply -var="state_bucket_name=<unique-name>" -var="github_repo=<owner>/<repo>"
   ```

3. Bootstrap Azure state: see `bootstrap/azure` (same pattern; `az login` first).
4. Write the next ADR before each new layer, and a note in `docs/learning/` after it.

## Cost safety

Set a budget alert in both clouds before creating anything. EKS/AKS, NAT gateways, databases and
GPU nodes bill by the hour: destroy dev environments when you stop for the day.
