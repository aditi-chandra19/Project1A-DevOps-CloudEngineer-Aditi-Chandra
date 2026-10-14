# Deliverable 4: Database Migration Strategy

## Goal and current boundary

This plan supports safe schema changes while NovaPay continues serving requests. The current Java demo has no database, ORM, migration framework, or database credentials. The plan therefore describes an implementable PostgreSQL path; it does not claim a database migration has run. For the local demonstration, migration ordering and compatibility are shown with sample SQL and a disposable local database only after a database runtime is available.

## Selected approach

Use PostgreSQL with versioned, immutable Flyway migrations packaged with the application release. The migration job uses the exact release image digest and a separate database identity. Application identities do not receive schema-owner privileges. A migration ledger records version, checksum, execution time, and result.

The selected pattern is expand, migrate, contract:

1. **Expand:** Add nullable columns, tables, or indexes in a backward-compatible migration. Avoid renaming or dropping fields used by the current release. Prefer concurrent index creation for large tables, with the operational limitations recorded.
2. **Deploy compatible code:** Deploy code that can read the old and new representation and writes the new representation safely. Keep the previous application version compatible with the expanded schema.
3. **Backfill:** Run a throttled, restartable job in bounded batches. Record progress, use idempotent updates, and stop when replication lag, lock time, or database load crosses its limit.
4. **Verify:** Check row counts, null rates, constraints, application health, and sampled business invariants before changing reads or writes.
5. **Switch and contract:** After the compatibility window and rollback period, deploy code that uses only the new representation. Drop old columns or constraints in a later release after approval and backup verification.

## Release gates and thresholds

| Check | Pass condition | Failure action |
| --- | --- | --- |
| Migration review | SQL reviewed by an application owner and database owner; migration ID and checksum are recorded | Block release and request review |
| Compatibility | Expand migration succeeds while the previous application version remains healthy; no destructive operation in the expand phase | Block promotion; redesign as expand/migrate/contract |
| Lock and duration | No table lock exceeds 5 seconds; migration step completes within 10 minutes in the representative demo dataset | Stop or cancel safely; split, batch, or schedule the operation |
| Backfill | Restartable batches; error rate 0%; database CPU below 70%; replication lag below 5 seconds where replicas exist | Pause worker and resume after load falls below limits |
| Data integrity | Required constraints and business invariants pass; unexplained row-count delta is 0 | Hold traffic change; reconcile from a verified backup or approved repair |
| Backup and restore | A recent backup exists and restore verification is documented before destructive contract changes | Do not run contract migration |
| Audit | Source SHA, artifact digest, migration checksum, approvers, start/end time, environment, result, and evidence URI are present | Block promotion |

Thresholds are proposed assessment targets for this demo. A real database owner must validate them against the database service and workload before production use.

## Failure, retry, and rollback

- A failed migration blocks application promotion. Preserve the database migration ledger and logs; do not edit an already-applied migration file.
- Retry only after confirming the migration is safe to resume. Each migration must be transactional where PostgreSQL permits it; non-transactional operations must have a documented checkpoint and recovery path.
- Application rollback is allowed only while the current schema remains backward-compatible with the previous release.
- Do not treat a down migration as the default rollback. Destructive or lossy schema changes require a forward repair or a tested restore plan approved by the database owner.
- Before a destructive contract step, verify backup age (≤24 hours for this demo target), restore evidence, and named approval. Stop writes only under the documented incident procedure.

## Example migration pair

Example only; these statements are not connected to the current demo application. The expand release adds a nullable field and leaves the old field intact. A later contract release may remove the old field after all application versions and data have migrated.

```sql
ALTER TABLE payment ADD COLUMN currency_code CHAR(3);
```

The backfill should run separately in bounded, restartable batches, with a recorded count and verification query. Do not put an unbounded full-table update into the application startup path.

## Demonstration and evidence plan

When a local PostgreSQL runtime is available, demonstrate a disposable schema with two application compatibility versions, an expand migration, an idempotent backfill, a failed-check hold, and a later contract migration. Capture migration logs, checksums, verification output, and rollback decision in `evidence/test-results/`. Until then, submit this as a design deliverable and identify the database execution proof as pending.

## AI attribution

Draft created with generative AI assistance; owner review is pending.
