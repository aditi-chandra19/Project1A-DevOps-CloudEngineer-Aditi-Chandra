param(
    [int]$Port = 8080,
    [string]$Version = "0.1.0+local",
    [string]$GitSha = "local"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$source = Join-Path $projectRoot "src\main\java\com\novapay\demo\NovaPayDemo.java"
$build = Join-Path $projectRoot ".build"

if (-not (Get-Command javac -ErrorAction SilentlyContinue)) {
    throw "A JDK is required. No software was installed by this script."
}
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    throw "A Java runtime is required. No software was installed by this script."
}

New-Item -ItemType Directory -Force -Path $build | Out-Null
javac --release 21 --add-modules jdk.httpserver -d $build $source
if ($LASTEXITCODE -ne 0) {
    throw "Compilation failed with exit code $LASTEXITCODE."
}

$env:PORT = "$Port"
$env:NOVAPAY_VERSION = $Version
$env:GIT_SHA = $GitSha
$env:NOVAPAY_ENVIRONMENT = "local"
java --add-modules jdk.httpserver -cp $build com.novapay.demo.NovaPayDemo
