# Deliverable 8: Observability and DORA Metrics

## Observability goals

Give the release operator enough evidence to detect regressions, decide whether to hold or roll back, and explain the outcome later. The demo uses synthetic traffic and must not expose customer data, credentials, or cardholder information in logs or labels.

## Service indicators and alert thresholds

| Signal | Measurement | Alert/decision threshold | Action |
| --- | --- | --- | --- |
| Availability | Successful synthetic health and transaction checks | Any missing telemetry is HOLD; failed production synthetic check twice in 2 minutes is Category B | Freeze promotion, inspect route and dependency health |
| HTTP error rate | HTTP 5xx / total HTTP requests, by release and environment | ≥1% for 5 minutes: Category B; ≥5% for 2 minutes: Category A rollback | Freeze traffic; rollback at Category A |
| Request latency | p50/p95/p99 from request histogram | p99 ≥200 ms or ≥2× rolling baseline for 5 minutes: Category B | Hold; inspect dependency latency and candidate comparison |
| Database | Connection pool use, acquisition wait, query errors, migration duration | Exhausted pool is Category A; utilization >80% for 5 minutes is a warning | Roll back for exhaustion; investigate warning before expansion |
| Queue | Pending count and oldest message age | Oldest age beyond service limit for 5 minutes: Category B | Stop expansion; check consumers and reconcile before replay |
| Canary comparison | Candidate versus rolling 7-day baseline, sample count, confidence interval, test result | Inconclusive or insufficient sample is HOLD; phase thresholds in Deliverable 2 must also pass | Do not advance on missing or statistically inconclusive data |
| Security/audit | Gate outcome, approval identity, digest, policy version, deployment event | Missing approval, digest mismatch, or missing evidence blocks promotion | Preserve record and repair evidence before retry |

The proposed SLO values must be calibrated from representative synthetic traffic before production use. Low-volume demo data can produce unstable percentiles and significance tests; show the sample count and classify insufficient samples as inconclusive.

## DORA indicators

Collect the four DORA metrics from verified release and incident records. Report the reporting window and sample size with every chart.

| Metric | Definition for this project | Initial demo target | Source |
| --- | --- | --- | --- |
| Deployment frequency | Successful production promotions per rolling 7 days | At least 1 per week once production promotion is operational | Release evidence records |
| Lead time for changes | Median time from first commit in a change to verified production promotion | Under 1 day after the production path exists | Git timestamps and release records |
| Change failure rate | Production deployments requiring rollback, hotfix, or incident response ÷ all production deployments | Under 15% over a rolling 30-day window; show numerator and denominator | Deployment and incident records |
| Time to restore service | Median time from incident trigger to verified stable recovery | Under 60 minutes; report sample count and severity | Incident timeline and recovery evidence |

These targets are project goals, not current measurements. No production deployments or live incident telemetry exist, so current DORA values are `N/A`, not zero and not inferred from the fictional simulation.

## Dashboard and alert definitions

`dashboards/grafana/novapay-overview.json` is an importable starting dashboard with templated Prometheus datasource selection. `dashboards/mockups/novapay-overview.svg` is a static design mockup. `pipeline/observability/prometheus-alerts.yml` contains example rules. Metric names must be supplied by actual instrumentation before these views can be considered live.

Suggested labels are `environment`, `service`, `release_id`, and `deployment_color`. Never label a metric with account numbers, payment identifiers, email addresses, tokens, or other sensitive/high-cardinality values. Logs should include a correlation ID that is synthetic and non-sensitive.

## Operational review cadence

- During a canary, inspect error rate, p99, database pool, queue age, and synthetic transaction after every phase.
- At release completion, retain the final gate record, metrics window, deployment identity, digest, and stable/rollback decision.
- Weekly, review DORA numerator/denominator, alert noise, and unowned actions. Do not score a metric when evidence or sample size is missing.
- After an incident, attach the timeline and verified recovery time before updating the DORA view.

## Current evidence and limitations

The repository includes canary decision scripts that consume operator-supplied values, but they do not query Prometheus or calculate Welch's t-test/chi-squared statistics. No Grafana, Prometheus, live service metrics, or production release history is configured. The dashboard and alert rules are design artifacts until wired to a running stack.

## AI attribution

Draft created with generative AI assistance; owner review is pending.
