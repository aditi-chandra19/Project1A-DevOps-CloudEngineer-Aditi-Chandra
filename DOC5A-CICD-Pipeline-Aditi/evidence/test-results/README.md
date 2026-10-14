# Test and scan results

This folder contains machine-generated evidence from local build/security checks and simulations. The dated build run is in `local-2026-10-14/`; its `manifest.json` records the source SHA-256, tool versions, outputs, and limits. `incident-simulation-2026-10-14.json` records the fictional incident's immediate rollback decision and simulated timeline. GitHub Actions is configured to produce container scan, image SBOM, and ZAP DAST artifacts, but those hosted results are not yet captured here. No live deployment or traffic rollback has been executed.
