param(
    [int]$Port = 18081,
    [string]$EvidenceDirectory = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "evidence\test-results\local-2026-10-14")
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$classDirectory = Join-Path $projectRoot ".build"
$sourcePath = Join-Path $projectRoot "src\main\java\com\novapay\demo\NovaPayDemo.java"

if (-not (Get-Command javac -ErrorAction SilentlyContinue) -or -not (Get-Command java -ErrorAction SilentlyContinue)) {
    throw "A JDK is required. This script does not install software."
}
if (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue) {
    throw "Port $Port is already in use. Choose another port or stop its current owner."
}

New-Item -ItemType Directory -Force -Path $classDirectory, $EvidenceDirectory | Out-Null
& javac --release 21 --add-modules jdk.httpserver -d $classDirectory $sourcePath
if ($LASTEXITCODE -ne 0) { throw "Java compilation failed." }

$stdout = Join-Path $EvidenceDirectory "simulator.stdout.log"
$stderr = Join-Path $EvidenceDirectory "simulator.stderr.log"
$resultPath = Join-Path $EvidenceDirectory "simulator-http-results.json"
$env:PORT = "$Port"
$env:NOVAPAY_VERSION = "0.1.0+local"
$env:GIT_SHA = "local-demo"
$env:NOVAPAY_ENVIRONMENT = "local"
$process = Start-Process -FilePath (Get-Command java).Source -ArgumentList @("--add-modules", "jdk.httpserver", "-cp", $classDirectory, "com.novapay.demo.NovaPayDemo") -PassThru -WindowStyle Hidden -RedirectStandardOutput $stdout -RedirectStandardError $stderr

try {
    $results = @()
    foreach ($endpoint in @("/health/live", "/health/ready", "/version", "/metrics")) {
        $response = $null
        for ($attempt = 0; $attempt -lt 20 -and -not $response; $attempt++) {
            try {
                $response = Invoke-WebRequest -Uri "http://127.0.0.1:$Port$endpoint" -TimeoutSec 2
            }
            catch {
                Start-Sleep -Milliseconds 250
            }
        }
        if (-not $response) { throw "Simulator did not respond at $endpoint" }
        $results += [pscustomobject]@{
            path = $endpoint
            statusCode = [int]$response.StatusCode
            body = $response.Content.Trim()
        }
    }

    [ordered]@{
        generatedAtUtc = [DateTime]::UtcNow.ToString("o")
        port = $Port
        processId = $process.Id
        result = "PASS"
        endpoints = $results
        simulated = $true
        scope = "Local process demonstration only; no payment authorization or cloud deployment."
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $resultPath -Encoding utf8
    Get-Content -LiteralPath $resultPath -Raw
}
finally {
    if (-not $process.HasExited) {
        Stop-Process -Id $process.Id -Force
        $process.WaitForExit()
    }
}
