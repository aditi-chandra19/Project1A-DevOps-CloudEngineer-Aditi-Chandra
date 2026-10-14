# Incident Playbook

## Incident purpose

Restore safe service behavior, protect payment-like demo operations, and preserve a clear audit trail. All NovaPay examples are fictional. This playbook does not authorize external, customer, or regulatory notifications; those follow the responsible organization's approved process.

## Severity and activation

| Severity | Example | Response |
| --- | --- | --- |
| SEV-1 | HTTP 5xx ≥5% for 2 minutes, database pool exhausted, suspected data corruption/duplicate processing, confirmed compromise, or gateway timeout ≥35% | Declare incident, freeze release traffic, restore last known-good target, assign incident commander and technical leads |
| SEV-2 | Error rate ≥1% for 5 minutes, p99 ≥200 ms or 2× baseline for 5 minutes, persistent readiness failures, or queue delay beyond the service limit | Freeze promotion, investigate immediately, roll back if persistent/worsening or customer impact is suspected |
| SEV-3 | Isolated noncritical alert, inconclusive canary, missing telemetry, or one failed synthetic check with no impact | Hold rollout, verify evidence and signal, document an authorized resume/rollback decision |

## Roles and first actions

1. The first responder records the alert, time, environment, affected release, and measured values.
2. The Incident Commander owns severity, coordination, decision log, and internal updates.
3. The Release Operator freezes promotion and restores the last known-good traffic target when required.
4. The SRE validates service/cluster signals; the Service Owner validates the user journey; the DBA owns database decisions; Payment Operations owns reconciliation and replay approval.
5. Security and Compliance join for suspected compromise, sensitive-data exposure, or control failure.

## Response timeline

| Target time | Action |
| --- | --- |
| T+0 | Acknowledge alert, classify, capture metric window and release digest, freeze advancement for SEV-1/2 |
| T+30 seconds for SEV-1 | Set canary to 0% or switch to last known-good blue/green target; record route action |
| T+2 minutes | Verify prior digest health, database pool, gateway errors, queue depth, and synthetic transaction |
| T+5 minutes | Keep rollback in place; identify pending operations; prohibit replay until duplicates are ruled out |
| T+15 minutes | Record verified impact estimate and recovery state; continue internal update cadence set by the Incident Commander |
| T+30 minutes | Preserve failed-release freeze, assign corrective owners/dates, and plan a review before release re-entry |

These are response targets for the educational scenario, not guarantees for a production organization.

## Safe payment-like operation handling

- Do not retry or replay an authorization-like operation until idempotency keys and current state are checked.
- Do not purge queues or alter ledger-like records to make metrics look healthy.
- Record affected synthetic operation IDs, duplicate checks, reconciliation result, and the named owner approving any replay.
- Use only synthetic data in this project. If a real system is involved, follow the organization's data-handling and incident procedures.

## Recovery criteria

The Incident Commander may move from response to monitoring after the last-known-good digest is serving, readiness and synthetic checks pass, HTTP 5xx is below 1% for 15 minutes, p99 is within the approved SLO, database pool and queue have recovered, and data reconciliation has an owner and recorded outcome. Keep the release frozen until corrective actions and gate reruns are approved.

## Evidence and review

Preserve alert/metric windows, logs, source and artifact digests, gate and approval events, route/configuration changes, migration records, decision timestamps, impact estimate, reconciliation result, and corrective actions. Conduct a blameless review with named owners and dates. Do not alter original gate or incident records; append later corrections with references.

## Local incident simulation

Run `pipeline/scripts/simulate-friday-incident.ps1` from the project directory to evaluate the fictional Friday 5:07 PM IST SEV-1 signals. It writes a timestamped JSON decision record under `evidence/test-results/`. The canary evaluator should choose immediate rollback and reduce proposed candidate traffic from 10% to 0%. The recorded timeline is simulated; the script does not send communications, alter traffic, or verify recovery.

## AI attribution

Draft created with generative AI assistance; owner review is pending.
