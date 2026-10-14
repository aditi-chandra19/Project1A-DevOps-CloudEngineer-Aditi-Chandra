# Stage 2: Build and Compilation

**Tool and version:** JDK 21 target; multi-stage Docker build using Eclipse Temurin Java 21 images. Pin image digests at implementation time.

**Input:** Reviewed source commit and locked dependency metadata. The current simulator has no third-party Java dependencies. **Output:** Compiled JAR and container image candidate, each tied to the source SHA and run ID.

**Quality gates:** Compilation succeeds; all unit tests pass; line coverage is at least 80% and branch coverage at least 70%; SemVer plus build metadata is recorded; rebuild from the same source and locked inputs is reproducible.

**Failure and remediation:** Compile/test/coverage failure blocks artifact publication. Fix the source or update an explicitly reviewed test. Missing dependency lock data blocks builds if external libraries are added.

**Retry and skip:** Retry a failed runner once only when infrastructure failure is identified. Do not retry source/test failures automatically. No test or build gate may be skipped.

**Service target:** Build and compile in 5 minutes, excluding runner queue time and base-image download on a cold cache.

**Current state:** The application compiles locally for Java 21. A Dockerfile exists; no container image has been built because the local container engine is not ready. Unit tests and coverage gates are not yet present.

**AI attribution:** Draft created with generative AI assistance; owner review is pending.
