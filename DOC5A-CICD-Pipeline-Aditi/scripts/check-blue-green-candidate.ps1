param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("blue", "green")]
    [string]$CandidateColor,

    [Parameter(Mandatory = $true)]
    [uri]$CandidateUrl
)

# Port-forward the slot's preview Service, then pass its local URL here.
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

$allPassed = @($checks | Where-Object { $_.result -ne "PASS" }).Count -eq 0
$recommendation = "Keep traffic on the current slot and investigate the failed checks."
if ($allPassed) {
    $recommendation = "Checks passed. An operator can now set activeColor to $CandidateColor."
}

$report = [pscustomobject]@{
    candidateColor = $CandidateColor
    candidateUrl = $baseUrl
    result = if ($allPassed) { "PASS" } else { "HOLD" }
    checks = @($checks)
    recommendation = $recommendation
}

$report | ConvertTo-Json -Depth 4
if (-not $allPassed) {
    exit 1
}
