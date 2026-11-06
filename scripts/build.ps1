[CmdletBinding()]
param(
    [switch]$Release
)

# Project root
$root = Split-Path -Parent $PSScriptRoot

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

$configuration = "Debug"
$target = "Build"

if ($Release) {
    $configuration = "Release"
    $target = "Rebuild"
}

& $msbuildPath "$root\Asda2_Server.sln" /p:Configuration=$configuration /p:Platform=x86 /t:$target

if ($LASTEXITCODE -ne 0) {
  throw "MSBuild failed with exit code $LASTEXITCODE."
}