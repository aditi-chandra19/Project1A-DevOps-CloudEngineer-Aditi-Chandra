param(
    [string]$OutputPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) ("evidence\test-results\incident-simulation-" + (Get-Date -Format "yyyy-MM-dd") + ".json"))
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$startUtc = [DateTimeOffset]::UtcNow

$decisionJson = & (Join-Path $PSScriptRoot "evaluate-canary.ps1") `
    -CurrentTrafficPercent 10 `
    -Http5xxRatePercent 12 `
    -Http5xxDurationSeconds 120 `
    -PaymentGatewayTimeoutRatePercent 35 `
    -DatabasePoolExhausted `
    -PromotionChecksPassed
$decision = $decisionJson | ConvertFrom-Json
if ($decision.decision -ne "rollback-immediate" -or $decision.nextTrafficPercent -ne 0) {
    throw "The incident signals did not produce the expected immediate rollback decision."
}

$timeline = @(
    [ordered]@{
        offsetSeconds = 0
        elapsed = "T+0"
        severity = "SEV-1"
        action = "Freeze canary advancement and declare a critical incident."
        evidence = @("Alert timestamps", "Candidate digest", "Canary traffic weight")
    },
    [ordered]@{
        offsetSeconds = 30
        elapsed = "T+30 seconds"
        severity = "SEV-1"
        action = "Set candidate traffic to zero and select the last-known-good slot."
        evidence = @("Route change record", "Rollback start time", "Operator identity")
    },
    [ordered]@{
        offsetSeconds = 120
        elapsed = "T+2 minutes"
        severity = "SEV-1"
        action = "Check readiness, error rate, database pool, gateway timeouts, queue depth, and the synthetic journey."
        evidence = @("Health results", "Metric windows", "Synthetic check result")
    },
    [ordered]@{
        offsetSeconds = 300
        elapsed = "T+5 minutes"
        severity = "SEV-1"
        action = "Keep rollback in place and reconcile pending operations before any replay."
        evidence = @("Impact estimate", "Idempotency and duplicate check", "Reconciliation owner")
    },
    [ordered]@{
        offsetSeconds = 900
        elapsed = "T+15 minutes"
        severity = "SEV-1"
        action = "Record verified impact and recovery state for the internal incident record."
        evidence = @("Verified impact summary", "Recovery checks", "Internal update timestamp")
    },
    [ordered]@{
        offsetSeconds = 1800
        elapsed = "T+30 minutes"
        severity = "Review"
        action = "Keep the failed release frozen and assign corrective actions before retry."
        evidence = @("Gate history", "Root cause", "Corrective action owners and dates")
    }
)

foreach ($event in $timeline) {
    $event.timestampUtc = $startUtc.AddSeconds($event.offsetSeconds).ToString("o")
    $event.executionStatus = "SIMULATED_NOT_EXECUTED"
}

$report = [ordered]@{
    incident = "NovaPay fictional Friday 5:07 PM IST canary incident"
    incidentId = "NP-INC-SIM-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    generatedAtUtc = $startUtc.ToString("o")
    simulated = $true
    executionStatus = "SIMULATION_ONLY"
    signals = [ordered]@{
        http5xxRatePercent = 12
        http5xxDurationSeconds = 120
        databasePoolExhausted = $true
        paymentGatewayTimeoutRatePercent = 35
    }
    canaryDecision = $decision
    trafficBeforePercent = 10
    trafficAfterPercent = $decision.nextTrafficPercent
    rootCause = "The canary promotion gate was bypassed or ineffective, allowing a candidate to advance despite simultaneous error, database pool, and gateway timeout signals."
    prevention = @("Block advancement at HTTP 5xx >= 5% for 60 seconds.", "Treat an exhausted payment database pool as an immediate rollback signal.", "Trigger immediate rollback when gateway timeouts reach 35%.", "Require fresh telemetry and successful policy evidence before promotion.")
    recoveryChecks = [ordered]@{
        executed = $false
        status = "NOT_RUN"
        required = @("Last-known-good version serves traffic", "Readiness passes", "HTTP 5xx below 1% for 15 minutes", "Database pool and gateway recover", "Synthetic transaction passes", "Pending operations are reconciled")
    }
    timeline = $timeline
    note = "Fictional assessment scenario. This report evaluates operator-supplied signals; it does not change traffic, contact responders, or claim recovery."
}

$outputDirectory = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Output "Simulation decision: $($decision.decision)"
Write-Output "Evidence: $OutputPath"
Get-Content -LiteralPath $OutputPath -Raw
