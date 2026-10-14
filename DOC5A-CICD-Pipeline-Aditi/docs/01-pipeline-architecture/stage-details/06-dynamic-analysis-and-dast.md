# Stage 6: Dynamic Analysis and DAST

**Tool and version:** OWASP ZAP 2.17.0, pinned in the workflow. Use passive scanning on every isolated test deployment; use active/API scanning against the OpenAPI definition in a disposable local environment.

**Input:** Deployed candidate URL, OpenAPI document, synthetic account, and short-lived test credential. **Output:** ZAP report, scan configuration/version, target artifact digest, and false-positive/exception record.

**Quality gates:** Zero Critical or High findings, including applicable OWASP Top 10/API risks. Credentials are injected from an approved secret store and are never saved in reports or source.

**Failure and remediation:** A real finding blocks promotion until fixed and rescanned. A false positive needs technical evidence, a named security approver, compensating controls, and an expiry.

**Retry and skip:** Retry one transient target/runner failure. An unreachable or unavailable target is a failed/incomplete gate, not a pass. No active scan against a live banking target from this project.

**Service target:** Complete within 10 minutes for the bounded demo scan. Record longer scan profiles separately.

**Current state:** No ZAP scan is configured. The local service can provide a safe synthetic target after a container/local runtime and test script are ready.

**AI attribution:** Draft created with generative AI assistance; owner review is pending.
