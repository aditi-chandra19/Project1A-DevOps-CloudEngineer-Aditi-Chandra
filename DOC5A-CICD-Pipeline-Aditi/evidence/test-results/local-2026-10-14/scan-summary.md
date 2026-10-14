# Local Build and Security Evidence

**Run date:** 2026-10-14 (Asia/Kolkata)  
**Runner:** `pipeline/scripts/run-assessment-checks.ps1`  
**Git base revision:** recorded in `manifest.json`; working tree contained local edits  
**Java source SHA-256:** `696556E7DE591CD1008C00BD9C19A8EC140CD53AF006A8F9920BC7764C3887F2`

## Results

| Check | Tool/version | Result | Scope and limit |
| --- | --- | --- | --- |
| Java compile | JDK 24.0.1 targeting Java 21 | PASS | Compiled the simulator and created a local JAR; no unit tests were run |
| Source rule | Project PowerShell rule | PASS, 0 findings | Narrow source rule; not a full SAST engine |
| JDK module inventory | `jdeps` from JDK 24.0.1 | PASS | Reports `java.base` and `jdk.httpserver`; not a vulnerability scan or SBOM |
| Helm lint | Helm 3.22.0 | PASS, 0 chart errors | Used an all-zero synthetic digest to satisfy chart schema; this digest is not a real or deployable image |
| Helm rendering | Helm 3.22.0 | PASS | Rendered both blue/green slots with the synthetic digest fixture |
| Rego syntax | OPA 1.21.1, `opa check --strict` | PASS | Checks policy compilation only; did not evaluate admission requests |
| Filesystem vulnerability/secret scan | Trivy 0.74.0 | No findings reported | No Java dependency manifests or language-specific files were detected; no third-party dependency coverage is established |
| Rendered Kubernetes configuration scan | Trivy 0.74.0 | 4 findings | Two Medium untrusted-registry findings and two Low default-namespace findings; these reflect the placeholder registry and chart defaults |
| Source JAR SBOM | Syft 1.54.0, CycloneDX 1.7 | Generated, 2 components | SBOM describes the local JAR/source inventory, not a container image |
| Local simulator endpoints | Java 24.0.1 targeting Java 21 | PASS, HTTP 200 for liveness, readiness, version, and metrics | Short-lived local process only; no payment authorization, blue-green switch, or cloud deployment |

The run used cached Trivy databases and skipped database/check updates. It did not download tools or create an account.

## Not demonstrated

No unit/integration tests, container build or image scan, DAST, policy evaluation against Kubernetes admission inputs, cloud promotion, live traffic shift, rollback, statistical canary, production telemetry, or DORA measurement was executed. The synthetic digest must never be used for deployment. The local endpoint responses are recorded in `simulator-http-results.json`.

Machine-readable reports, rendered chart, dependency inventory, and command transcript are stored beside this summary.
