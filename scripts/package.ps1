
[CmdletBinding()]
param(
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

# Project paths
$root = Split-Path -Parent $PSScriptRoot

$content = Join-Path $root "Run\Content"
$release = Join-Path $root "Run\ReleaseX86"
$dist = Join-Path $root "dist"

$defaultServerConfig = Join-Path $root "assets\RealmServerConfig.xml"
$databaseSql = Join-Path $root "database\asda2tahadidb.sql"
$composeFile = Join-Path $root "compose.yaml"
$readme = Join-Path $root "README.md"

$releaseTitle = "Asda2-Server-Windows-x86"
$releaseDir = Join-Path $dist $releaseTitle
$releasePackage = Join-Path $dist "$releaseTitle.zip"
$tempPackage = Join-Path $dist "$releaseTitle.tmp.zip"

# Validate packaging inputs
foreach ($file in @(
    $defaultServerConfig,
    $databaseSql,
    $composeFile,
    $readme
)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Required packaging file not found: $file"
    }
}

if (-not (Test-Path -LiteralPath $content -PathType Container)) {
    throw "Content directory not found: $content"
}

# Build Release x86 unless explicitly skipped
if (-not $SkipBuild) {
    & "$PSScriptRoot\build.ps1" -Release
}

if (-not (Test-Path -LiteralPath $release -PathType Container)) {
    throw "Release output directory not found: $release"
}

# Prepare fresh staging directory
if (-not (Test-Path -LiteralPath $dist)) {
    New-Item -Path $dist -ItemType Directory | Out-Null
}

if (Test-Path -LiteralPath $releaseDir) {
    Remove-Item -LiteralPath $releaseDir -Recurse -Force
}

New-Item -Path $releaseDir -ItemType Directory | Out-Null
New-Item -Path (Join-Path $releaseDir "database") -ItemType Directory | Out-Null

# Copy runtime files, excluding local configuration and debug artifacts
$excludedReleaseFiles = @(
    "*.pdb",
    "RealmServerConfig.xml",
    "RealmServerConfig.xml.bak"
)

robocopy $release "$releaseDir\ReleaseX86" /E `
    /XF $excludedReleaseFiles /XD "logs" /R:2 /W:1

if ($LASTEXITCODE -ge 8) {
    throw "Failed to copy Release files. Robocopy exit code: $LASTEXITCODE."
}

robocopy $content "$releaseDir\Content" /E /R:2 /W:1

if ($LASTEXITCODE -ge 8) {
    throw "Failed to copy Content. Robocopy exit code: $LASTEXITCODE."
}

# Add public configuration and database setup files
Copy-Item -LiteralPath $defaultServerConfig -Destination "$releaseDir\ReleaseX86"
Copy-Item -LiteralPath $databaseSql -Destination "$releaseDir\database"
Copy-Item -LiteralPath $composeFile -Destination $releaseDir
Copy-Item -LiteralPath $readme -Destination $releaseDir

# Validate package contents
$requiredFiles = @(
    "ReleaseX86\WCell.RealmServerConsole.exe",
    "ReleaseX86\WCell.RealmServer.dll",
    "ReleaseX86\MySql.Data.dll",
    "ReleaseX86\NLog.config",
    "ReleaseX86\RealmServerConfig.xml",
    "Content\Impl\UDB\Tables.xml",
    "Content\Lang\English.xml",
    "database\asda2tahadidb.sql",
    "compose.yaml",
    "README.md"
)

foreach ($file in $requiredFiles) {
    $path = Join-Path $releaseDir $file

    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Package validation failed: missing '$file'."
    }
}

# Verify excluded runtime artifacts
if (Test-Path -LiteralPath "$releaseDir\ReleaseX86\logs") {
    throw "Package validation failed: runtime logs were included."
}

if (Test-Path -LiteralPath "$releaseDir\ReleaseX86\RealmServerConfig.xml.bak") {
    throw "Package validation failed: local configuration backup was included."
}

$pdbFiles = Get-ChildItem -LiteralPath "$releaseDir\ReleaseX86" `
    -Filter "*.pdb" -File -Recurse

if ($pdbFiles) {
    throw "Package validation failed: debug symbols were included."
}

# Create ZIP without replacing the previous package on compression failure
try {
    Compress-Archive -Path $releaseDir -DestinationPath $tempPackage -Force
    Move-Item -LiteralPath $tempPackage -Destination $releasePackage -Force
}
finally {
    if (Test-Path -LiteralPath $tempPackage) {
        Remove-Item -LiteralPath $tempPackage -Force
    }
}

Write-Host "Successfully packaged: $releasePackage" -ForegroundColor Green
