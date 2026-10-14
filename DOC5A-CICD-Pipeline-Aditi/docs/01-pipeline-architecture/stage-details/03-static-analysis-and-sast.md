# Stage 3: Static Analysis and SAST

**Tool and version:** Semgrep Community Edition 1.180.0 with a pinned Java ruleset. The current custom PowerShell check is supplemental only. The selected release is published at [Semgrep v1.180.0](https://github.com/semgrep/semgrep/releases/tag/v1.180.0).

**Input:** Source revision and approved banking rule profile. **Output:** SARIF/JSON findings, coverage summary, scanner version, and audit record.

**Quality gates:** Zero Critical findings; at most two High findings; new-code technical debt ratio at most 5%; coverage thresholds are enforced by Stage 2. Rules cover PII handling, secret exposure, injection, unsafe deserialization, encryption, and logging.

**Failure and remediation:** Threshold breach blocks merge and creates an actionable finding with file, line, rule, severity, and repair guidance. False positives require a time-limited exception with a named security approver.

**Retry and skip:** Retry one transient scanner/runner outage. A scanner outage is not a pass. No bypass for hotfixes; an emergency exception records approvers and expires within 24 hours.

**Service target:** Complete within 5 minutes after source is available.

**Current state:** `check-source-policy.ps1` checks a small set of text patterns. It is not a full SAST engine and does not prove that these thresholds are met.

**AI attribution:** Draft created with generative AI assistance; owner review is pending.
