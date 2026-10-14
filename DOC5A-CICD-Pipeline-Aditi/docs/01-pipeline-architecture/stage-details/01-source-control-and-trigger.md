# Stage 1: Source Control and Trigger

**Tool and version:** Git for Windows 2.54.0; GitHub Actions checkout is pinned to commit `1af3b93b6815bc44a9784bd300feb67ff0d1eeb3`. Target trigger events are `pull_request`, protected `push`, and version tag.

**Input:** A commit on a short-lived branch and its pull request metadata. **Output:** An immutable source revision and a gate record linked to the commit SHA.

**Quality gates:** Required peer review; GPG/SSH signed commits; protected `main`; no direct pushes; permitted branch and path filters; dependency/action pin review; hotfix changes still run all required gates.

**Failure and remediation:** Missing signature, approval, or required status blocks merge. The author signs the commit, corrects the change, or obtains a documented reviewer decision. No gate is silently skipped.

**Retry and skip:** Retry only for a transient GitHub runner/API failure, at most twice with backoff. Do not retry a policy denial as if it were infrastructure failure. No security-gate skip.

**Service target:** Trigger and source checks complete within 2 minutes, excluding reviewer response time.

**Current state:** The workflow is manually triggered and nested under the project folder in the repository. It needs a repository-root workflow path and PR/push triggers before GitHub can run it automatically.

**AI attribution:** Draft created with generative AI assistance; owner review is pending.
