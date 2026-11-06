
[CmdletBinding()]
param(
    [switch]$skipBuild
)

$ErrorActionPreference = 'Stop'

# Project root
$root = Split-Path -Parent $PSScriptRoot

# Build Release x86 unless explicitly skipped
# TODO: extract this into a general build script with flags for build configs debug/release
if (-not $skipBuild) {
    $msbuildPath = Get-Command msbuild.exe -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty Source

    if (-not $msbuildPath) {
        $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

        if (-not (Test-Path $vsWhere)) {
            throw "MSBuild was not found on PATH, and vswhere.exe was not found. Install Visual Studio Build Tools with the MSBuild component."
        }

        $msbuildPath = & $vsWhere -latest -products '*' `
            -requires Microsoft.Component.MSBuild `
            -find 'MSBuild\**\Bin\MSBuild.exe' |
            Select-Object -First 1

        if (-not $msbuildPath) {
            throw "No MSBuild installation was detected. Install or modify Visual Studio Build Tools to include MSBuild."
        }
    }

    & $msbuildPath "$root\Asda2_Server.sln" /p:Configuration=Release /p:Platform=x86 /t:Rebuild

    if ($LASTEXITCODE -ne 0) {
        throw "MSBuild failed with exit code $LASTEXITCODE."
    }
}

# Source and destination paths
$content = "$root\Run\Content"
$release = "$root\Run\ReleaseX86"
$dist = "$root\dist"
$defaultServerConfig = "$root\assets\RealmServerConfig.xml"

$releaseTitle = "Asda2-Server-Windows-x86"
$releaseDir = "$dist\$releaseTitle"
$releasePackage = "$dist\$releaseTitle.zip"

# Verify source directories
if (-not (Test-Path $release -PathType Container)) {
    throw "Release output directory not found: $release"
}

if (-not (Test-Path $content -PathType Container)) {
    throw "Content directory not found: $content"
}

# Prepare a fresh staging directory
if (-not (Test-Path $dist)) {
    New-Item -Path $dist -ItemType Directory | Out-Null
}

if (Test-Path $releaseDir) {
    Remove-Item -Path $releaseDir -Recurse -Force
}

New-Item -Path $releaseDir -ItemType Directory | Out-Null

# Copy runtime files, excluding local configurations and debug files
$excludedReleaseFiles = "*.pdb", "RealmServerConfig.xml", "RealmServerConfig.xml.bak"
$excludedReleaseDirs = "logs"

robocopy $release "$releaseDir\ReleaseX86" /E /XF $excludedReleaseFiles /XD $excludedReleaseDirs /R:2 /W:1

if ($LASTEXITCODE -ge 8) {
    throw "Failed to copy Release files. Robocopy exit code: $LASTEXITCODE."
}

robocopy $content "$releaseDir\Content" /E /R:2 /W:1

if ($LASTEXITCODE -ge 8) {
    throw "Failed to copy Content. Robocopy exit code: $LASTEXITCODE."
}

Copy-Item -Path $defaultServerConfig -Destination "$releaseDir\ReleaseX86"

# Validate required runtime files
$requiredFiles = @(
    "ReleaseX86\WCell.RealmServerConsole.exe"
    "ReleaseX86\WCell.RealmServer.dll"
    "ReleaseX86\MySql.Data.dll"
    "ReleaseX86\NLog.config"
    "Content\Impl\UDB\Tables.xml"
    "Content\Lang\English.xml",
    "ReleaseX86\RealmServerConfig.xml"
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path "$releaseDir\$file" -PathType Leaf)) {
        throw "Package validation failed: missing required file '$file'."
    }
}

# Ensure logs are excluded
$excludedPaths = @(
    "ReleaseX86\logs"
)

foreach ($path in $excludedPaths) {
    if (Test-Path "$releaseDir\$path") {
        throw "Package validation failed: unexpected '$path'."
    }
}

$pdbFiles = Get-ChildItem -Path "$releaseDir\ReleaseX86" -Filter "*.pdb" -File -Recurse

if ($pdbFiles) {
    throw "Package validation failed: debug symbols were included."
}

# Create the ZIP without overwriting the previous package on compression failure
$tempPackage = "$dist\tmp.zip"

try {
    Compress-Archive -Path $releaseDir -DestinationPath $tempPackage -Force
    Move-Item -Path $tempPackage -Destination $releasePackage -Force
}
finally {
    if (Test-Path $tempPackage) {
        Remove-Item -Path $tempPackage -Force
    }
}

Write-Host "Successfully packaged: $releasePackage" -ForegroundColor Green
