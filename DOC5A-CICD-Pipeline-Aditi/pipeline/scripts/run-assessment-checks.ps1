param(
    [string]$EvidenceDirectory = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "evidence\test-results\local-2026-10-14")
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$classDirectory = Join-Path $projectRoot ".build"
$classFile = Join-Path $classDirectory "com\novapay\demo\NovaPayDemo.class"
$jarPath = Join-Path $classDirectory "novapay-demo.jar"
$chartPath = Join-Path $projectRoot "pipeline\helm\novapay"
$policyPath = Join-Path $projectRoot "pipeline\policies"
$sourcePath = Join-Path $projectRoot "src\main\java\com\novapay\demo\NovaPayDemo.java"
$demoDigest = "sha256:" + ("0" * 64)
$helmDemoValues = @(
    "--set-string", "images.blue.digest=$demoDigest",
    "--set-string", "images.green.digest=$demoDigest"
)

New-Item -ItemType Directory -Force -Path $EvidenceDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $classDirectory | Out-Null

$requiredTools = @("javac", "jar", "jdeps", "helm", "opa", "trivy", "syft")
foreach ($tool in $requiredTools) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "Required local tool '$tool' is not available. This script does not install software."
    }
}

$transcriptPath = Join-Path $EvidenceDirectory "local-checks.log"
Start-Transcript -Path $transcriptPath -Force | Out-Null

try {
    Write-Output "Project: $projectRoot"
    Write-Output "Evidence: $EvidenceDirectory"
    Write-Output "Source SHA-256: $((Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash)"
    Write-Output "Java compiler: $(javac -version 2>&1)"
    Write-Output "Helm: $(helm version --short)"
    Write-Output "OPA: $(opa version | Select-Object -First 1)"
    Write-Output "Trivy: $(trivy --version | Select-Object -First 1)"
    Write-Output "Syft: $(syft version | Select-String -Pattern '^Version:' | ForEach-Object { $_.Line.Trim() })"

    & (Join-Path $PSScriptRoot "check-source-policy.ps1")
    if (-not $?) { throw "Source policy check failed." }

    & javac --release 21 --add-modules jdk.httpserver -d $classDirectory $sourcePath
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $classFile)) { throw "Java compilation failed." }

    & jar --create --file $jarPath -C $classDirectory com
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $jarPath)) { throw "JAR creation failed." }

    & (Join-Path $PSScriptRoot "inventory-java-modules.ps1") -ClassFile $classFile -OutputPath (Join-Path $EvidenceDirectory "dependency-inventory.json")
    if (-not $?) { throw "JDK module inventory failed." }

    Write-Output "Helm lint and rendering use an all-zero synthetic digest fixture; it is not a deployable image."
    & helm lint $chartPath @helmDemoValues
    if ($LASTEXITCODE -ne 0) { throw "Helm chart lint failed." }

    $renderedChart = Join-Path $EvidenceDirectory "novapay-rendered.yaml"
    & helm template novapay $chartPath @helmDemoValues | Set-Content -LiteralPath $renderedChart -Encoding utf8
    if ($LASTEXITCODE -ne 0) { throw "Helm chart rendering failed." }

    & opa check --strict $policyPath
    if ($LASTEXITCODE -ne 0) { throw "OPA policy check failed." }

    & trivy fs --skip-db-update --skip-java-db-update --skip-check-update --scanners vuln,secret --format json --output (Join-Path $EvidenceDirectory "trivy-filesystem.json") $projectRoot
    if ($LASTEXITCODE -ne 0) { throw "Trivy filesystem scan failed." }

    & trivy config --skip-check-update --format json --output (Join-Path $EvidenceDirectory "trivy-rendered-chart.json") $renderedChart
    if ($LASTEXITCODE -ne 0) { throw "Trivy rendered-chart scan failed." }

    & syft $jarPath --output ("cyclonedx-json=" + (Join-Path $EvidenceDirectory "novapay-demo.cdx.json"))
    if ($LASTEXITCODE -ne 0) { throw "Syft SBOM generation failed." }

    $manifest = [ordered]@{
        generatedAtUtc = [DateTime]::UtcNow.ToString("o")
        sourceSha = (git -C $projectRoot rev-parse HEAD).Trim()
        sourceSha256 = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash
        workingTreeChangesPresent = $true
        evidenceScope = "Local compilation, source rule, module inventory, Helm lint/rendering with a synthetic all-zero digest fixture, OPA syntax, filesystem scan, rendered-chart scan, and source JAR SBOM. The fixture is not a deployable image. No unit tests, container image scan, DAST, live deployment, or statistical canary was run."
        outputs = @("local-checks.log", "dependency-inventory.json", "novapay-rendered.yaml", "trivy-filesystem.json", "trivy-rendered-chart.json", "novapay-demo.cdx.json")
    }
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $EvidenceDirectory "manifest.json") -Encoding utf8
    Write-Output "Local evidence run completed."
}
finally {
    Stop-Transcript | Out-Null
}
