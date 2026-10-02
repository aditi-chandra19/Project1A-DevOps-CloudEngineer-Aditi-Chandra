$ErrorActionPreference = "Stop"

$timeline = @(
    [ordered]@{
        time = "T+0"
        simulated = $true
        severity = "SEV-1"
        decision = "Freeze canary advancement and declare a critical incident."
        signals = @("HTTP 500 rate is 12% (assessment rollback threshold: 5%).",
                    "Primary PostgreSQL connection pool is exhausted.",
                    "Payment gateway timeout rate is 35%.")
        owner = "On-call SRE / Incident Commander"
        evidence = @("Alert timestamps and metric windows", "Candidate image digest", "Canary traffic weight")
    },
    [ordered]@{
        time = "T+30 seconds"
        simulated = $true
        severity = "SEV-1"
        decision = "Set canary traffic to zero or switch blue-green routing to the last known good digest."
        signals = @("Immediate rollback is triggered by the 5xx breach and pool exhaustion.")
        owner = "Release Operator + DBA"
        evidence = @("Route/traffic change record", "Pod and connection-pool events", "Rollback start time")
    },
    [ordered]@{
        time = "T+2 minutes"
        simulated = $true
        severity = "SEV-1"
        decision = "Verify prior revision health, database pool recovery, gateway timeouts, queue depth, and synthetic payment journey."
        signals = @("Do not advance or deploy a hotfix while checks are failing.")
        owner = "SRE + Payment Service Owner + DBA"
        evidence = @("Readiness results", "Pool and gateway metrics", "Synthetic check result", "Queue and reconciliation status")
    },
    [ordered]@{
        time = "T+5 minutes"
        simulated = $true
        severity = "SEV-1"
        decision = "Keep rollback in place; identify pending operations and reconcile idempotently before any replay."
        signals = @("Do not replay payments until duplicate processing has been ruled out.")
        owner = "Incident Commander + Payment Operations"
        evidence = @("Impact estimate", "Reconciliation summary", "Internal update timestamp")
    },
    [ordered]@{
        time = "T+15 minutes"
        simulated = $true
        severity = "SEV-1"
        decision = "Confirm service state and customer impact; use the organization's approved communication and reporting process."
        signals = @("The scenario is fictional; no real customer or regulatory notification is implied.")
        owner = "Incident Commander + Compliance Liaison"
        evidence = @("Verified impact summary", "Approvals for any replay", "Communication record")
    },
    [ordered]@{
        time = "T+30 minutes"
        simulated = $true
        severity = "Review"
        decision = "Preserve the pipeline freeze for the failed change and record corrective actions before retrying the release."
        signals = @("A promotion gate must prevent staging bypass; hotfixes still pass mandatory security and compliance gates.")
        owner = "Engineering Lead + Security + SRE"
        evidence = @("Change history", "Gate and approval events", "Postmortem action owners and dates")
    }
)

[ordered]@{
    incident = "NovaPay fictional Friday 5:07 PM IST canary incident"
    simulated = $true
    automated_action = "Freeze promotion and restore the last known good traffic target."
    timeline = $timeline
} | ConvertTo-Json -Depth 8
