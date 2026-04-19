#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$CommandsSrc = Join-Path $PSScriptRoot 'commands'
$CommandsDst = Join-Path $env:USERPROFILE '.claude\commands\skeptic'

New-Item -ItemType Directory -Force -Path $CommandsDst | Out-Null
Copy-Item -Path (Join-Path $CommandsSrc '*.md') -Destination $CommandsDst -Force

Write-Host "Skeptic commands installed to $CommandsDst"
