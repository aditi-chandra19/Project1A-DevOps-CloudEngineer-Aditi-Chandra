param(
    [Parameter(Mandatory = $true)]
    [string]$ReleaseName,

    [Parameter(Mandatory = $true)]
    [ValidateSet("blue", "green")]
    [string]$CurrentColor,

    [Parameter(Mandatory = $true)]
    [ValidateSet("blue", "green")]
    [string]$CandidateColor,

    [Parameter(Mandatory = $true)]
    [string]$CheckReportPath
)

$ErrorActionPreference = "Stop"

if ($CurrentColor -eq $CandidateColor) {
    throw "Candidate color must be different from the active color."
}

$check = Get-Content -LiteralPath $CheckReportPath -Raw | ConvertFrom-Json
if ($check.result -ne "PASS" -or $check.candidateColor -ne $CandidateColor) {
    throw "Promotion blocked. The candidate check must pass for $CandidateColor."
}

$checkedAt = [DateTimeOffset]::Parse($check.checkedAtUtc).ToUniversalTime()
if ([DateTimeOffset]::UtcNow - $checkedAt -gt [TimeSpan]::FromMinutes(10)) {
    throw "Promotion blocked. Run the candidate check again; this report is over 10 minutes old."
}

$chartPath = Join-Path (Split-Path -Parent $PSScriptRoot) "pipeline\helm\novapay"
[pscustomobject]@{
    result = "READY"
    promote = "helm upgrade $ReleaseName $chartPath --reuse-values --set-string activeColor=$CandidateColor --wait --atomic --timeout 5m"
    rollback = "helm upgrade $ReleaseName $chartPath --reuse-values --set-string activeColor=$CurrentColor --wait --atomic --timeout 5m"
} | ConvertTo-Json
