param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("blue", "green")]
    [string]$CandidateColor,

    [Parameter(Mandatory = $true)]
    [uri]$CandidateUrl
)

$ErrorActionPreference = "Stop"
$baseUrl = $CandidateUrl.AbsoluteUri.TrimEnd("/")
$checks = [System.Collections.Generic.List[object]]::new()

foreach ($path in @("/health/live", "/health/ready", "/version")) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl$path" -Method Get -TimeoutSec 5
        $passed = switch ($path) {
            "/health/live" { $response.status -eq "UP" -and $response.check -eq "live" }
            "/health/ready" { $response.status -eq "UP" -and $response.check -eq "ready" }
            "/version" { $response.service -eq "novapay-demo" -and -not [string]::IsNullOrWhiteSpace($response.version) }
        }

        $checks.Add([pscustomobject]@{
            endpoint = $path
            result = if ($passed) { "PASS" } else { "FAIL" }
        })
    }
    catch {
        $checks.Add([pscustomobject]@{
            endpoint = $path
            result = "FAIL"
            detail = $_.Exception.Message
        })
    }
}

$failedChecks = @($checks | Where-Object result -ne "PASS")
$report = [pscustomobject]@{
    candidateColor = $CandidateColor
    candidateUrl = $baseUrl
    result = if ($failedChecks.Count -eq 0) { "PASS" } else { "HOLD" }
    checks = @($checks)
    nextStep = if ($failedChecks.Count -eq 0) {
        "Candidate checks passed. An operator may now switch activeColor to $CandidateColor."
    } else {
        "Keep traffic on the current slot and investigate the failed checks."
    }
}

$report | ConvertTo-Json -Depth 4
if ($failedChecks.Count -gt 0) {
    exit 1
}
