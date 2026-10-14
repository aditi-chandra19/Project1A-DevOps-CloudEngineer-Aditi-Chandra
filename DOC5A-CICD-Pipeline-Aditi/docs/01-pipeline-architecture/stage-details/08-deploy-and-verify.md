# Stage 8: Deploy and Verify

**Tool and version:** Helm 3.22.0 and Kubernetes API 1.29+ per the assessment scenario; Argo CD 2.x and Istio 1.x are target integrations and neither is currently configured. Pin exact cluster/add-on patches together after choosing a local cluster. The local demonstration uses the Helm blue-green chart and candidate/promotion scripts.

**Input:** Signed immutable image, passing gates, approved environment configuration, and named promotion approvals. **Output:** Deployment revision, traffic state, health/synthetic results, approval/audit events, and stable-or-rollback decision.

**Quality gates:** Promote the same digest through dev, staging, pre-production, production. Blue-green switching is a controlled five-step operation: validate idle slot, deploy candidate, verify health/synthetic traffic, approve and switch traffic atomically, monitor and retain rollback target. Canary phases are 1–2% for 15 minutes (error rate <0.1%, p99 <200 ms), 5–10% for 30 minutes (error rate <0.05%, no Critical alerts), 25–50% for 60 minutes (all SLOs met), then 100% with a 24-hour bake. Compare latency with Welch's t-test, error proportions with chi-squared, use a 95% confidence interval for automated promotion, and compare with a rolling 7-day baseline. Include session handling and graceful payment-request draining before a traffic switch.

**Failure and remediation:** Hold on missing evidence or inconclusive statistics. Roll back immediately for an active Category A trigger; escalate and hold or roll back within 15 minutes for Category B; require an operator decision for Category C. Verify health, image digest consistency, configuration, and customer impact after rollback.

**Retry and skip:** Retry only an idempotent deploy operation after confirming its state. Do not repeat traffic switches blindly. No stage or approval skip; failed production verification triggers the independent rollback path.

**Service target:** 20 minutes per non-production rollout; canary bake windows and the 24-hour final observation are explicit, not hidden inside a build SLA.

**Current state:** Helm chart defines blue/green deployments and services. Scripts produce health/canary decisions and a promotion plan. There is no local cluster/image yet, no traffic router, no statistical canary test, and no live deployment.

**AI attribution:** Draft created with generative AI assistance; owner review is pending.
