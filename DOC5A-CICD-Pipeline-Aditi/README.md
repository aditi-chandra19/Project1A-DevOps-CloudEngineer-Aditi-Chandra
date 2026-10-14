# NovaPay Zero-Downtime CI/CD Pipeline

**Project:** DevOps & Cloud Engineer assessment  
**Owner:** Aditi Chandra  
**Status:** Assessment work in progress; live cloud demonstration pending

This project designs and demonstrates a controlled CI/CD pipeline for a fictional banking service. The Java application is a local simulator; it does not process real payments or connect to bank systems. The target design follows the assessment's eight canonical pipeline stages and separates controls that are demonstrated locally from controls that need a configured registry or Kubernetes environment.

## Deliverables

| Deliverable | Location | Status |
| --- | --- | --- |
| 1. Pipeline architecture | [Architecture](docs/01-pipeline-architecture/architecture.md) | Designed; local tools and cloud gates are distinguished |
| 2. Deployment strategies | [Blue-green and canary](docs/02-deployment-strategies/deployment-strategies.md) | Designed; traffic routing and statistical analysis are not live |
| 3. Compliance gates | [Gate specifications](docs/03-compliance-gates/compliance-gates.md) | Designed; local source/OPA checks exist; hosted image and DAST gates are configured, with run evidence pending |
| 4. Database migration | [Migration strategy](docs/04-database-migration/database-migration.md) | Designed; application has no database |
| 5. Environment promotion | [Promotion strategy](docs/05-environment-promotion/environment-promotion.md) | Designed; no four-environment deployment exists |
| 6. Rollback | [Rollback specification](docs/06-rollback-specification/rollback-specification.md) | Designed; incident timeline can be simulated locally |
| 7. Runbooks | [Deployment runbook](runbooks/deployment-runbook.md), [incident playbook](runbooks/incident-playbook.md) | Written; production steps remain unexecuted |
| 8. Observability and DORA | [Observability](docs/08-observability/observability.md), [Grafana JSON](dashboards/grafana/novapay-overview.json), [mockup](dashboards/mockups/novapay-overview.svg) | Designed; no live metrics or DORA values |

## Current demo

- Local Java service: `src/main/java/com/novapay/demo/NovaPayDemo.java`
- GitHub Actions workflow: [repository-root workflow](../.github/workflows/novapay-demo-build.yml)
- Kubernetes chart: `pipeline/helm/novapay/`
- OPA policies: `pipeline/policies/`
- Local scripts: `pipeline/scripts/`
- Container build definition: `Dockerfile`
- Terraform modules and dev example: `pipeline/terraform/` (not applied; no Terraform validation run yet)
- Assessment coverage and known gaps: [self-assessment](evidence/self-assessment.md) and [ERRATA](ERRATA.md)
- TRC review materials: `evidence/trc-presentation.pdf` (draft; owner review required)
- Reflections: `evidence/reflections.md` (draft; personalize before submission)

## Scope and safety

All payment behavior and failure injection are simulated. No live credentials, customer records, payment networks, or production infrastructure are used. The compliance thresholds in the design are assessment controls, not legal advice or a claim of regulatory certification.

## Build and run locally

Use the installed Java 21 JDK and PowerShell. No external Java dependencies are required. From this project directory:

```powershell
.\pipeline\scripts\run-local.ps1
```

The demo prints a local simulator URL; it does not process real payments. The project does not require Docker or a Kubernetes installation for its source/build and documentation demonstration.

To recreate the dated local build and scan evidence with the tools already installed, run:

```powershell
.\pipeline\scripts\run-assessment-checks.ps1
```

The script does not install tools or run unit tests. Review [the captured run summary](evidence/test-results/local-2026-10-14/scan-summary.md) before presenting the outputs.

To compile and start the simulator briefly, request its liveness/readiness/version/metrics endpoints, then stop it and save the responses, run:

```powershell
.\pipeline\scripts\capture-local-demo.ps1
```

## Submission status

This package contains the assessment design deliverables, local demo evidence, and hosted CI jobs for container build, image scanning, SBOM generation, and DAST. The hosted workflow results are not yet recorded in the repository. It is not a completed zero-downtime cloud deployment: a registry, Kubernetes cluster, Istio, Argo CD, database, Prometheus/Grafana service, branch protections, approval identities, and production evidence are not configured. See the self-assessment before claiming completion.

## AI attribution

Generative AI assisted with drafting and code review. Aditi Chandra is responsible for reviewing, adapting, and presenting this work.
