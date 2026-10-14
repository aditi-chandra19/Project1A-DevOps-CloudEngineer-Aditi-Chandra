# Stage 4: Dependency Scan and SBOM

**Tool and version:** Trivy 0.74.0 and Syft 1.54.0 are installed locally. Generate a CycloneDX SBOM for every release candidate; scan dependencies and the built container image with Trivy.

**Input:** Locked dependency manifests, build artifact, container image, and approved license policy. **Output:** CycloneDX SBOM, vulnerability/license findings, scanner/database timestamps, and artifact digests.

**Quality gates:** Block all Critical CVEs and High CVEs with CVSS greater than 8.0; block GPL/AGPL/SSPL dependencies pending legal approval; require an SBOM; verify base-image provenance. The assessment also sets a 72-hour High-CVE remediation window: that window applies to remediation planning, never to a release-blocking Critical/High finding.

**Failure and remediation:** Upgrade or remove the affected package/base image, regenerate the artifact and SBOM, then rescan. A license exception requires Legal approval. No image is promoted when scanning is unavailable or incomplete.

**Retry and skip:** Retry transient database download/scanner failures twice with backoff. Never skip image scanning or SBOM generation for a production candidate.

**Service target:** Complete within 8 minutes for a warm scanner cache; report cold-cache update time separately.

**Current state:** Trivy filesystem/config scans and a Syft source SBOM were generated locally. There is no container-image scan yet, and no third-party Java dependency manifest was found.

**AI attribution:** Draft created with generative AI assistance; owner review is pending.
