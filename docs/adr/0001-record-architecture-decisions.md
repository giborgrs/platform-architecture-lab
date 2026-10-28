# ADR-0001: Record architecture decisions

- **Status:** Accepted
- **Date:** 2026-10-27

## Context

Two reference architectures are being built across AWS and Azure. Without a written trail, the
reasoning behind each choice is lost, and the point of the exercise (learning why, not just how)
is lost with it.

## Options considered

1. **No records:** fastest, but nothing to review or defend later.
2. **Wiki pages:** easy to write, but they drift from the code and have no history tied to commits.
3. **ADRs in the repo (MADR-style):** versioned with the code, reviewed in PRs.

## Decision

Use short ADRs in `docs/adr/`, numbered sequentially, using `template.md`. Larger proposals that
need discussion first go through an RFC in `docs/rfc/`; the RFC links to the ADRs it produces.
Accepted ADRs are never edited except for status; a changed decision gets a new ADR that
supersedes the old one.

## Consequences

- Good: every significant choice has a date, alternatives and trade-offs.
- Bad: a small writing overhead per decision.
- Rule of thumb: if you spent more than an hour choosing, write an ADR.
