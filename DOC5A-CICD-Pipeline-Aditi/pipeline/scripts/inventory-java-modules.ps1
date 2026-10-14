param(
    [string]$ClassFile = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) ".build\com\novapay\demo\NovaPayDemo.class"),
    [string]$OutputPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) ".build\dependency-inventory.json")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ClassFile -PathType Leaf)) {
    throw "Compiled class not found. Compile the application before creating its dependency inventory: $ClassFile"
}

if (-not (Get-Command jdeps -ErrorAction SilentlyContinue)) {
    throw "JDK tool 'jdeps' is required for the runtime module inventory. No software was installed."
}

$moduleOutput = & jdeps --multi-release 21 --print-module-deps $ClassFile
if ($LASTEXITCODE -ne 0) {
    throw "jdeps failed with exit code $LASTEXITCODE."
}

$modules = @($moduleOutput.Trim() -split "," | Where-Object { $_ } | Sort-Object -Unique)
$report = [pscustomobject]@{
    application = "novapay-demo"
    generatedAtUtc = [DateTime]::UtcNow.ToString("o")
    javaReleaseTarget = 21
    jdkModules = $modules
    vulnerabilityScan = "Not run; this is a module inventory, not a vulnerability scan or full SBOM."
}

$outputDirectory = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Get-Content -LiteralPath $OutputPath -Raw
