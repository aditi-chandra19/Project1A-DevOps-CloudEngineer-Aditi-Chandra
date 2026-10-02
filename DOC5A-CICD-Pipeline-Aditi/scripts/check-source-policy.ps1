param(
    [string]$SourcePath = (Join-Path (Split-Path -Parent $PSScriptRoot) "src\main\java\com\novapay\demo\NovaPayDemo.java")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
    throw "Java source file not found: $SourcePath"
}

# Local preflight rules for this dependency-free demo. This is not a substitute for
# a maintained SAST scanner such as Semgrep or SonarQube.
$rules = @(
    @{
        Id = "NP-SEC-001"
        Severity = "HIGH"
        Pattern = '(?i)(password|passwd|secret|api[_-]?key|access[_-]?token)\s*[:=]\s*["''][^"'']{8,}["'']'
        Message = "Possible hard-coded credential or token. Read secrets from an approved secret store."
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
        Message = "Shell process execution requires a reviewed, constrained design."
    },
    @{
        Id = "NP-SEC-004"
        Severity = "HIGH"
        Pattern = 'new\s+ObjectInputStream\s*\('
        Message = "Native Java deserialization is blocked by default due to gadget risks."
    },
    @{
        Id = "NP-SEC-005"
        Severity = "HIGH"
        Pattern = 'new\s+InetSocketAddress\s*\(\s*["''](0\.0\.0\.0|::)["'']'
        Message = "The demo server must bind to loopback for local-only execution."
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
    scanner = "NovaPay local source policy preflight"
    scannerVersion = "0.1.0"
    scannerType = "custom-pattern-check; not full SAST"
    threshold = "block on any HIGH finding"
    result = if ($findings.Count -eq 0) { "PASS" } else { "FAIL" }
    findingCount = $findings.Count
    findings = @($findings)
}

$report | ConvertTo-Json -Depth 5
if ($findings.Count -gt 0) {
    exit 1
}
