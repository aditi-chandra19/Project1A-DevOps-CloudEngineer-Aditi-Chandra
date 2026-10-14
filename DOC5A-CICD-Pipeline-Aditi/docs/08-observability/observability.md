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

The assessment requires at least 15 pipeline metrics and three audience-specific dashboard views. The catalog below defines 24 proposed metric families across build, compliance, deployment, and DORA. Only the local simulator request counter is currently emitted; the remaining metrics require workflow, policy, registry, deployment, or incident exporters. No dashboard shows fabricated measurements.

| Category | Metric | Type and labels | Meaning |
| --- | --- | --- | --- |
| Build | `novapay_ci_runs_total` | Counter: `result` | Completed CI runs by outcome |
| Build | `novapay_ci_duration_seconds` | Histogram: `workflow` | End-to-end and per-job runtime |
| Build | `novapay_ci_queue_wait_seconds` | Histogram: `runner_class` | Time waiting for a runner |
| Build | `novapay_test_cases_total` | Counter: `result`, `suite` | Unit, integration, and contract test outcomes |
| Build | `novapay_line_coverage_ratio` | Gauge: `module` | Measured line coverage from a verified report |
| Build | `novapay_build_cache_hit_ratio` | Gauge: `workflow` | Build cache hit fraction |
| Compliance | `novapay_gate_evaluations_total` | Counter: `gate`, `result` | Required gate decisions by outcome |
| Compliance | `novapay_security_findings` | Gauge: `scanner`, `severity` | Open findings by scanner and severity |
| Compliance | `novapay_sbom_generated_total` | Counter: `format`, `result` | SBOM generation outcomes by format |
| Compliance | `novapay_signature_verifications_total` | Counter: `result` | Artifact signature verification outcomes |
| Compliance | `novapay_policy_decisions_total` | Counter: `policy`, `result` | OPA/Kyverno allow and deny decisions |
| Compliance | `novapay_release_approval_events_total` | Counter: `environment`, `result`, `role` | Independent approval events by role |
| Compliance | `novapay_evidence_completeness_ratio` | Gauge: `environment` | Required release evidence present fraction |
| Compliance | `novapay_active_exceptions` | Gauge: `environment`, `severity` | Current, unexpired policy exceptions |
| Deployment | `novapay_deployments_total` | Counter: `environment`, `strategy`, `result` | Deployment attempts and outcomes |
| Deployment | `novapay_deployment_duration_seconds` | Histogram: `environment`, `strategy` | Apply-to-verified-ready duration |
| Deployment | `novapay_canary_traffic_percent` | Gauge: `environment`, `deployment_color` | Candidate traffic share |
| Deployment | `novapay_canary_error_ratio` | Gauge: `environment`, `deployment_color` | Candidate HTTP error fraction |
| Deployment | `novapay_canary_p99_seconds` | Gauge: `environment`, `deployment_color` | Candidate p99 request latency |
| Deployment | `novapay_health_checks_total` | Counter: `environment`, `result` | Post-deployment health and synthetic checks |
| Deployment | `novapay_rollbacks_total` | Counter: `environment`, `category`, `reason` | Rollback events by trigger |
| DORA | `novapay_dora_deployment_frequency` | Gauge: `environment`, `window` | Verified production promotions per window |
| DORA | `novapay_dora_lead_time_seconds` | Gauge: `environment`, `window` | Median commit-to-verified-production time |
| DORA | `novapay_dora_change_failure_ratio` | Gauge: `environment`, `window` | Failed production changes / all production changes |
| DORA | `novapay_dora_time_to_restore_seconds` | Gauge: `environment`, `window` | Median incident-to-verified-stable duration |

The engineering dashboard also uses these service-level metrics: `novapay_demo_http_requests_total` is emitted by the local demo; request-duration histogram buckets, active database pool connections, oldest queue-message age, and synthetic-check status remain planned instrumentation.

Use bounded labels only; never add release digests, commit SHAs, customer identifiers, or payment references as metric labels. Keep those values in the access-controlled audit records.

| Audience | Grafana export | Wireframe | Primary questions |
| --- | --- | --- | --- |
| Engineering | `dashboards/grafana/novapay-overview.json` | `dashboards/mockups/novapay-overview.svg` | Is the service healthy? What is the canary weight? Should rollout hold or roll back? |
| Management | `dashboards/grafana/novapay-management.json` | `dashboards/mockups/novapay-management.svg` | How often do verified changes ship? What are lead time, failure rate, and restore time? |
| Regulatory | `dashboards/grafana/novapay-regulatory.json` | `dashboards/mockups/novapay-regulatory.svg` | Which controls passed, which findings remain, and where is retained evidence? |

All exports use a Prometheus datasource input. DORA panels show `N/A` until verified production and incident records are connected. `pipeline/observability/prometheus-alerts.yml` contains example rules. Metric names must be supplied by actual instrumentation before the dashboards can be considered live.

Suggested labels are `environment`, `service`, `release_id`, and `deployment_color`. Never label a metric with account numbers, payment identifiers, email addresses, tokens, or other sensitive/high-cardinality values. Logs should include a correlation ID that is synthetic and non-sensitive.

## Operational review cadence

- During a canary, inspect error rate, p99, database pool, queue age, and synthetic transaction after every phase.
- At release completion, retain the final gate record, metrics window, deployment identity, digest, and stable/rollback decision.
- Weekly, review DORA numerator/denominator, alert noise, and unowned actions. Do not score a metric when evidence or sample size is missing.
- After an incident, attach the timeline and verified recovery time before updating the DORA view.

## Current evidence and limitations

The repository includes canary decision scripts that consume operator-supplied values, but they do not query Prometheus or calculate Welch's t-test/chi-squared statistics. The local Java demo emits only its request counter; no Grafana, Prometheus, pipeline-metric exporter, or production release history is configured. The dashboard exports and alert rules are design artifacts until wired to a running stack.

## AI attribution

Draft created with generative AI assistance; owner review is pending.
