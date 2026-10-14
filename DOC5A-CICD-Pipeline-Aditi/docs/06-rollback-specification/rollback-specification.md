# Deliverable 6: Rollback Specification

## Rollback objectives

Stop customer impact quickly, restore the last known-good application digest and traffic route, preserve evidence, and verify the service before another release. Rollback is an operational decision with an audit record. It does not automatically reverse a database migration or replay payment-like work.

The thresholds below use the assessment's explicit 5% HTTP 5xx rollback threshold. Other values are proposed demo targets and must be calibrated against an approved service SLO before production use.

## Trigger taxonomy

| Category | Trigger | Required action | Decision owner |
| --- | --- | --- | --- |
| A: immediate rollback | HTTP 5xx rate ≥5% for 2 consecutive minutes; database connection pool exhausted; suspected data corruption/duplicate processing; confirmed security compromise; or payment gateway timeout rate ≥35% | Freeze traffic expansion immediately; set canary to 0% or switch to last known-good slot; declare critical incident; verify recovery | Incident Commander with Release Operator; DBA for data conditions |
| B: urgent hold or rollback | Error rate ≥1% for 5 minutes; p99 latency ≥200 ms or ≥2× baseline for 5 minutes; SLO burn rate >2× for 10 minutes; repeated readiness failures in >10% of candidate pods; or queue age exceeds the service limit for 5 minutes | Freeze promotion; investigate for up to 15 minutes; rollback if the trigger persists, worsens, or has customer impact | On-call SRE and Service Owner |
| C: controlled hold | A noncritical alert, inconclusive statistical canary result, missing telemetry, drift, or one failed synthetic check without customer impact | Hold traffic at current weight; verify signal and evidence; resume only after an authorized decision | Release Operator and Service Owner |

Never delay Category A rollback to collect more canary samples. Missing or stale telemetry is a hold and cannot be interpreted as a passing result.

## Eight-step rollback procedure

1. **Declare and capture.** Create the incident/change record; capture trigger, UTC time, affected environment, release ID, current and prior digests, traffic weight, and metric windows.
2. **Freeze.** Stop canary advancement and all new deployments. Keep security gates enabled for any later hotfix.
3. **Protect in-flight work.** Stop accepting new long-running jobs on the candidate, drain or safely requeue work, and record pending operations. Do not replay payment-like operations until idempotency and reconciliation are confirmed.
4. **Select the safe revision.** Confirm the previous image digest, configuration revision, chart revision, and traffic target from the last-known-good release record.
5. **Restore traffic.** Set canary traffic to 0% or atomically route traffic to the previous blue/green slot. If the deployment control plane is unavailable, use the independently documented operator path and record each action.
6. **Verify recovery.** Check readiness, HTTP 5xx, p99 latency, database pool, gateway timeout rate, queue depth, and synthetic transaction. Confirm the serving image digest matches the rollback record.
7. **Reconcile and communicate internally.** Estimate impact, reconcile pending/duplicate work with the service and payment-operations owners, and update the internal incident record through the approved channel. External or regulatory communication follows the organization's authorized process.
8. **Preserve and review.** Retain logs, metrics, gate results, approvals, route events, and timestamps. Keep the failed release frozen until root cause, corrective owner, and re-entry gates are recorded.

## Database and state rules

- Application rollback is allowed only while the schema remains compatible with the previous application version.
- Do not automatically run a down migration. For lossy schema changes, stop writes only under the incident plan and use an approved forward repair or verified restore procedure.
- Do not clear queues, sessions, or ledger-like records as a rollback shortcut. Reconcile them with the owning service.
- Any replay must use idempotency keys and be approved by the responsible operations owner.

## Evidence record

Record incident ID, trigger category and measured values, metric query/window, release and digest identifiers, prior target, operator and approver identities, every route/configuration action and timestamp, recovery checks, data reconciliation decision, evidence URIs, and follow-up actions. The record links to the failed gate-audit records; it does not overwrite them.

## Recovery and re-entry

The incident commander closes the immediate rollback only after health remains stable for 15 minutes, synthetic checks pass, and the last-known-good digest is confirmed. A failed change may re-enter delivery only after the owning team records root cause, fixes the issue, regenerates the artifact, and reruns all required gates. No stage or security gate is skipped for a hotfix.

## Current implementation boundary

`pipeline/scripts/simulate-friday-incident.ps1` evaluates the fictional SEV-1 incident through the canary decision script and writes a timestamped JSON record. The record shows the expected immediate rollback decision for 12% HTTP 5xx, database pool exhaustion, and a 35% payment gateway timeout rate. The timeline is simulated; Helm and promotion/candidate scripts remain plan-oriented. The repository does not currently route live traffic or execute a production rollback.

## AI attribution

Draft created with generative AI assistance; owner review is pending.
