param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(1, 2, 5, 10, 25, 50, 100)]
    [int]$CurrentTrafficPercent,

    [double]$Http5xxRatePercent = 0,
    [int]$Http5xxDurationSeconds = 0,
    [int]$ConsecutiveReadinessFailures = 0,
    [int]$OomKills = 0,
    [double]$PaymentGatewayTimeoutRatePercent = 0,
    [switch]$CrashLoopBackOff,
    [switch]$DatabasePoolExhausted,

    [double]$CandidateP99Milliseconds = 0,
    [double]$BaselineP99Milliseconds = 0,
    [int]$P99RegressionDurationSeconds = 0,
    [double]$ErrorBudgetBurnRate = 0,
    [int]$ErrorBudgetBurnDurationSeconds = 0,
    [double]$TransactionSuccessDropPercentagePoints = 0,
    [double]$CpuUtilizationPercent = 0,
    [int]$CpuSaturationDurationSeconds = 0,
    [double]$MemoryUtilizationPercent = 0,
    [int]$MemorySaturationDurationSeconds = 0,

    [switch]$OnCallAcknowledged,
    [switch]$ManualReviewRequired,
    [switch]$PromotionChecksPassed
)

$immediateTriggers = [System.Collections.Generic.List[string]]::new()
$escalatedTriggers = [System.Collections.Generic.List[string]]::new()

if ($Http5xxRatePercent -gt 5 -and $Http5xxDurationSeconds -ge 60) {
    $immediateTriggers.Add("HTTP 5xx rate exceeded 5% for at least 60 seconds")
}
if ($ConsecutiveReadinessFailures -ge 3) {
    $immediateTriggers.Add("Candidate failed readiness three consecutive times")
}
if ($OomKills -gt 0) {
    $immediateTriggers.Add("Candidate container was OOM-killed")
}
if ($CrashLoopBackOff) {
    $immediateTriggers.Add("Candidate entered CrashLoopBackOff")
}
if ($DatabasePoolExhausted) {
    $immediateTriggers.Add("Database connection pool is exhausted")
}
if ($PaymentGatewayTimeoutRatePercent -ge 35) {
    $immediateTriggers.Add("Payment gateway timeout rate reached 35%")
}

if ($BaselineP99Milliseconds -gt 0 -and
    $CandidateP99Milliseconds -gt (2 * $BaselineP99Milliseconds) -and
    $P99RegressionDurationSeconds -ge 300) {
    $escalatedTriggers.Add("Candidate p99 exceeded 2x baseline for at least 5 minutes")
}
if ($ErrorBudgetBurnRate -gt 10 -and $ErrorBudgetBurnDurationSeconds -ge 600) {
    $escalatedTriggers.Add("Error budget burn exceeded 10x for at least 10 minutes")
}
if ($TransactionSuccessDropPercentagePoints -gt 2) {
    $escalatedTriggers.Add("Transaction success rate dropped more than 2 percentage points")
}
if ($CpuUtilizationPercent -gt 90 -and $CpuSaturationDurationSeconds -ge 300) {
    $escalatedTriggers.Add("CPU exceeded 90% for at least 5 minutes")
}
if ($MemoryUtilizationPercent -gt 85 -and $MemorySaturationDurationSeconds -ge 300) {
    $escalatedTriggers.Add("Memory exceeded 85% for at least 5 minutes")
}

$decision = "hold"
$reason = "Required promotion checks have not all been confirmed."
$nextTrafficPercent = $CurrentTrafficPercent

if ($immediateTriggers.Count -gt 0) {
    $decision = "rollback-immediate"
    $reason = "An immediate rollback trigger is active. Set candidate traffic to zero and restore the last known good revision."
    $nextTrafficPercent = 0
}
elseif ($escalatedTriggers.Count -gt 0) {
    if ($OnCallAcknowledged) {
        $decision = "escalate-and-hold"
        $reason = "An escalated trigger is active and on-call acknowledged it. Freeze traffic progression while the incident owner decides."
    }
    else {
        $decision = "rollback-escalated"
        $reason = "An escalated trigger is active and unacknowledged. Roll back within the 15-minute escalation window."
        $nextTrafficPercent = 0
    }
}
elseif ($ManualReviewRequired) {
    $decision = "manual-review"
    $reason = "A Category C signal needs an operator decision. Freeze traffic progression."
}
elseif (-not $PromotionChecksPassed) {
    $decision = "hold"
    $reason = "No rollback trigger is active, but promotion checks were not confirmed."
}
elseif ($CurrentTrafficPercent -eq 100) {
    $decision = "observe-full-rollout"
    $reason = "Traffic is fully shifted. Continue the required bake and verification window before marking stable."
}
else {
    $decision = "promote"
    $reason = "No configured rollback trigger is active and promotion checks passed. Advance one canary phase."
    switch ($CurrentTrafficPercent) {
        { $_ -in 1, 2 } { $nextTrafficPercent = 5; break }
        5 { $nextTrafficPercent = 10; break }
        10 { $nextTrafficPercent = 25; break }
        25 { $nextTrafficPercent = 50; break }
        50 { $nextTrafficPercent = 100; break }
    }
}

[ordered]@{
    evaluation = "operator-supplied metrics; no live systems queried"
    currentTrafficPercent = $CurrentTrafficPercent
    decision = $decision
    nextTrafficPercent = $nextTrafficPercent
    immediateTriggers = @($immediateTriggers)
    escalatedTriggers = @($escalatedTriggers)
    paymentGatewayTimeoutRatePercent = $PaymentGatewayTimeoutRatePercent
    onCallAcknowledged = [bool]$OnCallAcknowledged
    reason = $reason
} | ConvertTo-Json -Depth 4
