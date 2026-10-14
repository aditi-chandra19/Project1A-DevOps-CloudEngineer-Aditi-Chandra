# Deployment Runbook

## Purpose and scope

Use this runbook to prepare, deploy, verify, or stop a NovaPay demo release. It supports the repository's local Helm blue-green model and documents the production process. No Kubernetes cluster, registry, traffic router, or production credentials are currently configured; production steps are reference instructions and have not been executed.

## Roles

- **Release Operator:** executes the approved deployment and records evidence.
- **Service Owner:** accepts service health and synthetic-check results.
- **Approver:** independently approves production promotion and cannot be the requester.
- **On-call SRE:** owns health signals and rollback execution.
- **DBA:** approves migration sequencing and data recovery decisions.

## Before deployment

1. Confirm change window, release ID, reviewed source SHA, and required approver.
2. Confirm a single immutable image digest, SBOM digest, provenance, and all required gate records. Missing evidence means stop.
3. Confirm destination environment and configuration revision. Verify secret references without printing secret values.
4. Confirm database compatibility, migration checksum, backup/restore evidence for destructive changes, and the prior application rollback target.
5. Confirm dashboards, alerts, synthetic checks, on-call coverage, and the independent traffic rollback path are available.
6. Confirm non-production data is synthetic and no real card/customer data is present.

## Local demonstration

Run commands from the project directory in PowerShell. These scripts validate inputs and print decisions/plans; they do not deploy to a cluster or change live traffic.

```powershell
Set-Location .\DOC5A-CICD-Pipeline-Aditi
.\pipeline\scripts\inventory-java-modules.ps1
.\pipeline\scripts\check-source-policy.ps1
```

For the existing blue-green plan, provide a fresh candidate health report and run `pipeline/scripts/check-blue-green-candidate.ps1` followed by `pipeline/scripts/prepare-blue-green-promotion.ps1` with the required parameters. Review the generated plan before using it. Do not treat plan output as a successful deployment.

## Production deployment sequence

1. Obtain the recorded production approval and confirm requester/approver separation.
2. Verify the idle blue/green slot, current stable route, candidate digest, chart revision, and compatible database schema.
3. Deploy the candidate to the inactive slot and wait for readiness, liveness, resource policy, and digest checks.
4. Run smoke and synthetic transaction checks through the preview route. Confirm the candidate reports the expected release ID and SHA.
5. Apply canary phases from Deliverable 2. Record weights, observation windows, sample counts, error/latency results, alerts, and decision at each phase.
6. At 100%, begin the 24-hour bake. Keep the prior slot available and do not run a contract migration during the rollback window.
7. Mark stable only after the full bake and all evidence are complete; then remove the prior slot under the approved retention policy.

## Stop and rollback

Stop on a missing approval, missing/stale metric, digest mismatch, failed compliance gate, migration incompatibility, failed smoke test, or Category A/B/C signal defined in the rollback specification. For Category A, freeze advancement and switch to the last known-good target immediately. Follow the eight-step rollback procedure and incident playbook. Do not retry traffic switches blindly.

## Post-deployment record

Attach source/image/SBOM digests, gate results, environment/configuration revision, migration record, approvals, route changes, canary metrics, smoke/synthetic results, final decision, timestamps, and any incident/rollback evidence. Never include secret values or real payment data.

## Local demo status

The Java simulator, Helm templates, and plan-oriented scripts are present. The local environment does not currently have a working container engine or Kubernetes cluster. Do not mark this runbook's production flow executed until actual deployment evidence is captured.

## AI attribution

Draft created with generative AI assistance; owner review is pending.
