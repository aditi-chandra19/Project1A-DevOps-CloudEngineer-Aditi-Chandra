# Project Reflections

Draft for Aditi Chandra to review and personalize before submission. Each response is based on work and limits recorded in this repository. Replace any sentence that does not reflect the owner's experience.

## 1. What was the most difficult engineering decision?

The most difficult decision was deciding how to demonstrate a zero-downtime banking pipeline when the application is a small local simulator and there is no configured Kubernetes cluster, database, registry, or production traffic. It would have been easy to draw a successful deployment path and let the diagrams imply that it was already running. I kept the design and the implementation status separate instead. The architecture describes blue-green deployment, four canary phases, compliance gates, and rollback, while the self-assessment identifies which of those pieces exist only as documents or plan-oriented scripts.

That decision shaped the scope. I used the local Java simulator, Helm chart, PowerShell scripts, OPA policies, Trivy, and Syft where those tools were already available. I documented a PostgreSQL migration approach without claiming to have migrated data, and designed Prometheus and Grafana artifacts without inventing metrics. This makes the submission less dramatic than a production screenshot, but it is easier to explain and defend. A reviewer can see the target design, the local evidence, and the exact missing proof.

I would improve this by obtaining an approved disposable runtime early in the project schedule. That would let me demonstrate a local container and cluster path while keeping all banking behavior synthetic. I would still keep the production design separate from that local demonstration. The local environment can prove that a workflow or policy behaves in a controlled scenario; it cannot establish the availability, security certification, or operating discipline of a real bank deployment.

## 2. How did the assessment requirements affect the architecture?

The assessment asks for more than a build script. It connects source review, static and dynamic analysis, dependency evidence, compliance approvals, deployment strategies, database migration, environment promotion, rollback, runbooks, and operational metrics. I used those requirements to create eight named pipeline stages and separate supporting deliverables so a reviewer can trace a requirement to a design and, where available, a local artifact.

The clearest example is the release path. A single immutable image digest is intended to move through dev, staging, pre-production, and production. Each transition has evidence and an approval boundary. Production uses blue-green deployment and a staged canary, while a separate rollback specification describes what happens when the measurements breach a threshold. The database design uses expand, migrate, and contract so an application rollback does not assume that schema changes can simply be undone. These pieces depend on each other, so documenting them separately but linking the controls made the design easier to review.

The PDF contains a dependency severity difference between one stage and its gate table. I documented the stricter release-blocking interpretation and kept the 72-hour period as a remediation deadline for findings below that threshold. This avoids allowing a remediation window to be mistaken for permission to deploy a known blocking issue. I would ask the assessor to confirm that interpretation before treating it as final policy. The remaining architecture work is to replace proposed thresholds with values supported by actual service objectives and a real workload.

## 3. What security and operational risks did you prioritize?

I prioritized risks that could cause a release to proceed without reliable evidence or could make rollback unsafe. The pipeline is designed to fail closed when a required result is missing, stale, or tied to a different artifact digest. Gate records include the source SHA, image digest, tool and policy versions, approvals, findings, and evidence references. An exception is limited to a specific finding and artifact, has independent approval and an expiry, and cannot authorize a production release for critical vulnerabilities, privileged containers, missing approvals, or missing audit records.

For deployment safety, I documented canary thresholds and an immediate rollback trigger at a five percent HTTP 5xx rate, matching the assessment scenario. The incident plan also treats an exhausted database pool, suspected data corruption, duplicate processing, and severe gateway timeouts as urgent. I included a rule not to replay payment-like requests until idempotency and reconciliation have been checked. The project uses synthetic data, and the docs warn against placing secret values or sensitive identifiers in logs and metric labels.

These are proposed controls, not evidence that a secure production system exists. The current local policy checks cover only a subset of Kubernetes concerns, and there is no built container image or live DAST target. The next security improvement should be to connect each design gate to a reproducible command, store the actual reports, and demonstrate that a failed gate blocks promotion. I would then review alert thresholds with a service owner and security reviewer rather than assume that demo numbers are suitable for a bank.

## 4. What did the incident simulation teach you about rollback?

The Friday incident simulation is useful because it forces the response to be ordered. The scenario starts with a twelve percent HTTP 500 rate, an exhausted PostgreSQL connection pool, and a thirty-five percent gateway timeout rate. The first action is to freeze canary advancement and restore the previous traffic target. The team verifies the prior revision and service dependencies, records pending operations, and avoids replaying payment-like work until duplicate processing has been ruled out. This is more reliable than treating rollback as only a command that changes a deployment revision.

The simulation also distinguishes service recovery from release closure. Routing back to the previous version may restore availability, but the incident still needs an impact estimate, reconciliation, evidence preservation, corrective owners, and a review before the failed change can re-enter the pipeline. A database schema may have changed, so an application rollback is safe only if compatibility was preserved. That is why the migration strategy keeps destructive contract changes separate from the application rollout and rollback window.

The scenario is fictional and the script prints a timeline rather than changing traffic. It cannot prove that an on-call team can meet the stated times or that the proposed rollback mechanism works under a real failure. A stronger demonstration would inject a controlled failure into a disposable local service, record the measured recovery, and verify data invariants afterward. Any real payment or customer incident would require the organization's authorized process; this student simulation does not authorize communication or regulatory reporting.

## 5. What would you change or build next?

I would first establish a small, reproducible local execution path with approval for any required runtime installation. The priority would be a container build, a disposable local Kubernetes target if the machine supports it, and a CI workflow that runs against a pull request or a manually dispatched build. I would keep the implementation narrow: compile the existing Java simulator, run the source policy, build the image, scan it, generate an SBOM, and evaluate the existing OPA rules against rendered Helm resources. Each step should save machine-readable evidence with the source SHA and tool version.

After that, I would add one safe demonstration at a time. The next release feature would be a controlled blue-green candidate check, followed by a simulated canary evaluation using representative synthetic traffic. I would not add a real database until the application needs one; for the assessment, the database migration design can remain separate from the current in-memory simulator. Similarly, I would connect Prometheus and Grafana only after the service exposes useful metrics, so the dashboard displays observed values rather than empty panels or invented DORA results.

I would also review the repository naming and workflow placement against the assessment instructions. The active GitHub workflow must be in the repository-root `.github/workflows` directory, and the final hand-in package must follow the assessor's required name. Before submission, I would confirm the branch rules and signed-commit evidence with the repository owner, capture successful workflow and demonstration outputs, complete the self-assessment from those artifacts, and ask a reviewer to check that every claim is supported. Project 1C remains outside this Project 1A schedule.

## AI attribution

Generative AI assisted with drafting these responses. The project owner must edit them to reflect personal experience and approve them before submission.
