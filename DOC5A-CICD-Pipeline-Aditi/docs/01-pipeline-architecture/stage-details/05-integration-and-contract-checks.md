# Stage 5: Integration and Contract Checks

**Tool and version:** Pact JVM 4.7.1 for consumer/provider contracts; JDK 21 for the Java test harness. Use Kubernetes 1.29+ for an ephemeral namespace, as in the assessment scenario. Keep unit/contract checks runnable without a paid service.

**Input:** Candidate artifact, API contract, synthetic data, and compatible PostgreSQL/Redis/RabbitMQ test services when the service adopts them. **Output:** Unit/integration/contract results, backward-compatibility report, and performance baseline.

**Quality gates:** 100% of required tests pass; coverage remains at least 80% line and 70% branch; no breaking API contract; schema changes pass backward-compatibility checks; baseline latency and error-rate data are attached.

**Failure and remediation:** A failed contract or integration blocks promotion. Correct the implementation or publish a reviewed compatible contract/migration plan. Preserve test logs and artifact versions.

**Retry and skip:** Retry a test only when a recorded infrastructure fault caused it; quarantine flaky tests with an owner and expiry, but do not convert a failed required test into a pass. No release gate skip.

**Service target:** Complete within 10 minutes for the demo test set; report provisioning time separately.

**Current state:** No automated unit, consumer-contract, database integration, or performance test suite is present. The current Java simulator has no external database or broker connection.

**AI attribution:** Draft created with generative AI assistance; owner review is pending.
