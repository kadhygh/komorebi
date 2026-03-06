param(
    [string]$Version = "v0.1.0-preview1",
    [string]$Target = "x86_64-pc-windows-msvc"
)

$ErrorActionPreference = "Stop"

function Resolve-BinaryRoot {
    param(
        [string]$RepoRoot,
        [string]$Target
    )

    $candidates = @(
        (Join-Path $RepoRoot "target\$Target\release"),
        (Join-Path $RepoRoot "target\release")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path (Join-Path $candidate "komorebi.exe")) {
            return $candidate
        }
    }

    throw "Could not find compiled binaries in target\\$Target\\release or target\\release"
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$sourceRoot = Join-Path $repoRoot "release\portable"
$stagingRoot = Join-Path $repoRoot "release\.build\portable"
$artifactRoot = Join-Path $repoRoot "release\artifacts"
$binaryRoot = Resolve-BinaryRoot -RepoRoot $repoRoot -Target $Target
$applicationsPath = Join-Path $repoRoot "komorebic\applications.json"

if (-not (Test-Path $sourceRoot)) {
    throw "Missing source assets directory: $sourceRoot"
}

if (-not (Test-Path $applicationsPath)) {
    throw "Missing applications.json source: $applicationsPath"
}

$requiredSourceFiles = @(
    "start.cmd",
    "start-whkd.cmd",
    "stop.cmd",
    "CHANGELOG.md",
    "config\komorebi.json",
    "shortcuts\komorebi.ahk"
)

foreach ($relativePath in $requiredSourceFiles) {
    $fullPath = Join-Path $sourceRoot $relativePath
    if (-not (Test-Path $fullPath)) {
        throw "Missing source asset: $fullPath"
    }
}

$quickstartFile = Get-ChildItem -Path $sourceRoot -Filter "README-*.md" | Select-Object -First 1

if (-not $quickstartFile) {
    throw "Missing quickstart document in $sourceRoot"
}

$requiredBinaries = @(
    "komorebi.exe",
    "komorebic.exe",
    "komorebic-no-console.exe"
)

$optionalBinaries = @(
    "komorebi-bar.exe"
)

foreach ($binary in $requiredBinaries) {
    $fullPath = Join-Path $binaryRoot $binary
    if (-not (Test-Path $fullPath)) {
        throw "Missing binary: $fullPath"
    }
}

if (Test-Path $stagingRoot) {
    Remove-Item $stagingRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $stagingRoot | Out-Null
Copy-Item (Join-Path $sourceRoot "*") $stagingRoot -Recurse -Force

$stagingBin = Join-Path $stagingRoot "bin"
$stagingConfig = Join-Path $stagingRoot "config"

New-Item -ItemType Directory -Force -Path $stagingBin, $stagingConfig, $artifactRoot | Out-Null

foreach ($binary in $requiredBinaries) {
    Copy-Item (Join-Path $binaryRoot $binary) (Join-Path $stagingBin $binary) -Force
}

foreach ($binary in $optionalBinaries) {
    $fullPath = Join-Path $binaryRoot $binary
    if (Test-Path $fullPath) {
        Copy-Item $fullPath (Join-Path $stagingBin $binary) -Force
    }
}

Copy-Item $applicationsPath (Join-Path $stagingConfig "applications.json") -Force

$zipName = "komorebi-fork-$Version-portable-x64.zip"
$zipPath = Join-Path $artifactRoot $zipName
$checksumPath = Join-Path $artifactRoot "checksums.txt"

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path (Join-Path $stagingRoot "*") -DestinationPath $zipPath -Force

$hash = (Get-FileHash $zipPath -Algorithm SHA256).Hash.ToLower()
Set-Content -Path $checksumPath -Value "$hash  $zipName"

Write-Host "Staged portable package: $stagingRoot"
Write-Host "Created archive: $zipPath"
Write-Host "Created checksum: $checksumPath"
