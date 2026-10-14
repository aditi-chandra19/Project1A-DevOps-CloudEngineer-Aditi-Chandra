# ERRATA

Updated 2026-10-14.

| Item | Assessment expectation | Current project state | Action or evidence needed |
| --- | --- | --- | --- |
| Project/repository naming | PDF p.47 naming convention | Existing GitHub repository is `Project1A-DevOps-CloudEngineer-Aditi-Chandra`; the assessment convention includes `&` | Use the required exact name for the final hand-in package if the assessor requires it. The existing remote repository has not been renamed. |
| Submission folder structure | PDF pp.33-34 `DOC5A-CICD-Pipeline-[Name]` layout | Assessment artifacts are in `DOC5A-CICD-Pipeline-Aditi` | Confirm the assessor's expected name format against the exact template before packaging; do not rename the remote repository without authorization. |
| GitHub Actions discovery | GitHub reads workflows from repository-root `.github/workflows/` | The original workflow was nested under the assessment directory | Active workflow is placed at the actual Git root and uses the nested project as its working directory. |
| Signed commits and branch rules | Signed commits, protected branch, and independent reviews | Local commit history was unsigned; remote branch protection cannot be verified here | Configure repository rules and signed commits with the account owner; preserve review evidence. |
| 15-day assessment schedule | PDF lists a 15-day assessment schedule | User requested Project 1A completion in 10 days and deferred Project 1C | The 10-day target is followed; this does not alter the assessment's printed schedule. |
| Dependency threshold | PDF Stage 4 and gate table give different High/CVSS and remediation wording | Design blocks Critical and High CVSS >8.0; 72 hours is remediation SLA only for lower, non-blocking findings | Retain the stricter release-blocking rule unless the assessor clarifies the conflict. |
| Local container/Kubernetes proof | Working image, deployment, and zero-downtime demonstration | No working local container engine or Kubernetes cluster is configured | A real cluster/registry or approved local runtime and evidence are still required for executed deployment claims. |
| Database migration | Safe migration demonstration | Java demo has no database or migration framework | Database design is complete; execution evidence remains pending. |
| DAST and observability | DAST scan, metrics, dashboards, and DORA evidence | No live target, Prometheus/Grafana instance, production releases, or incident history | Treat dashboards and DORA targets as design artifacts; publish measurements only after instrumentation and verified events exist. |
| TRC and reflection | Review presentation and five reflection answers | Drafts are prepared for owner review | Aditi must review/personalize the reflection and approve the TRC presentation before hand-in. |
| External transfer | PDF's transfer/email instructions | User asked not to transfer ownership or send email | No ownership transfer or email has been performed. |

This list records known deviations and evidence limits so the project does not present design intent as an executed control.
