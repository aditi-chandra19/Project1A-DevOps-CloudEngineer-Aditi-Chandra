# Stage 7: Policy and Compliance Gates

**Tool and version:** OPA 1.21.1 for Rego policy evaluation; Helm 3.22.0 to render the chart; Terraform 1.7+ and Kyverno 1.x per the assessment stack. Pin exact Terraform/Kyverno patches before implementation.

**Input:** Rendered Kubernetes manifests, signed image digest, scan/test results, approval identities, and change metadata. **Output:** Machine-readable allow/deny decisions and an audit record with policy version and input digest.

**Quality gates:** At least six documented gates cover SAST, DAST, vulnerabilities/SBOM, license, Kubernetes policy, and infrastructure policy. Require trusted registry plus immutable digest; deny privileged containers; require CPU/memory limits; require all mandatory evidence and separation of duties. Each gate maps to the relevant RBI/PCI-DSS clause in the compliance deliverable.

**Failure and remediation:** Deny deployment, identify the failing policy and field, and link remediation. Exceptions use a structured request with named owner/approvers, risk statement, compensating control, start/expiry times, and closure evidence. Expired or malformed exceptions are denied.

**Retry and skip:** Retry policy service failure once; unavailable policy evaluation is fail-closed. No automated or hotfix bypass.

**Service target:** Complete within 3 minutes for the rendered demo chart.

**Current state:** Three Rego policies check image digests/registry, resource limits, and privileged containers. Syntax and sample decisions were checked locally; six mapped gate specifications and exception workflow remain to be completed.

**AI attribution:** Draft created with generative AI assistance; owner review is pending.
