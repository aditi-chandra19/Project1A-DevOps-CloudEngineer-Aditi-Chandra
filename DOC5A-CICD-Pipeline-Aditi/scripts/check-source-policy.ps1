param(
    [string]$SourcePath = (Join-Path (Split-Path -Parent $PSScriptRoot) "src\main\java\com\novapay\demo\NovaPayDemo.java")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
    throw "Java source file not found: $SourcePath"
}

# These are quick checks for this demo, not a full SAST scan.
$rules = @(
    @{
        Id = "NP-SEC-001"
        Severity = "HIGH"
        Pattern = '(?i)(password|passwd|secret|api[_-]?key|access[_-]?token)\s*[:=]\s*".{8,}"'
        Message = "Possible hard-coded credential. Keep secrets out of source code."
    },
    @{
        Id = "NP-SEC-002"
        Severity = "HIGH"
        Pattern = '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
        Message = "Private key material must not be committed to source control."
    },
    @{
        Id = "NP-SEC-003"
        Severity = "HIGH"
        Pattern = 'Runtime\.getRuntime\(\)\.exec\s*\(|new\s+ProcessBuilder\s*\('
        Message = "Review shell process execution before allowing it."
    },
    @{
        Id = "NP-SEC-004"
        Severity = "HIGH"
        Pattern = 'new\s+ObjectInputStream\s*\('
        Message = "Review native Java deserialization before allowing it."
    },
    @{
        Id = "NP-SEC-005"
        Severity = "HIGH"
        Pattern = 'new\s+InetSocketAddress\s*\(\s*"(0\.0\.0\.0|::)"'
        Message = "The local demo must bind to loopback."
    }
)

$findings = [System.Collections.Generic.List[object]]::new()
$lines = Get-Content -LiteralPath $SourcePath
for ($index = 0; $index -lt $lines.Count; $index++) {
    foreach ($rule in $rules) {
        if ($lines[$index] -match $rule.Pattern) {
            $findings.Add([pscustomobject]@{
                ruleId = $rule.Id
                severity = $rule.Severity
                file = [System.IO.Path]::GetFileName($SourcePath)
                line = $index + 1
                message = $rule.Message
            })
        }
    }
}

$report = [pscustomobject]@{
    check = "NovaPay source checks"
    result = if ($findings.Count -eq 0) { "PASS" } else { "FAIL" }
    findings = @($findings)
}

$report | ConvertTo-Json -Depth 5
if ($findings.Count -gt 0) {
    exit 1
}
