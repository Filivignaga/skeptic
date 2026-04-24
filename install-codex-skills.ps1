#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$CodexSource = Join-Path $PSScriptRoot 'codex'
$CodexSkills = Join-Path $env:USERPROFILE '.codex\skills'

if (-not (Test-Path -LiteralPath $CodexSource)) {
  & (Join-Path $PSScriptRoot 'tools\sync-codex-skills.ps1')
}

New-Item -ItemType Directory -Force -Path $CodexSkills | Out-Null

Get-ChildItem -LiteralPath $CodexSource -Directory | ForEach-Object {
  $destination = Join-Path $CodexSkills $_.Name
  if (Test-Path -LiteralPath $destination) {
    Remove-Item -LiteralPath $destination -Recurse -Force
  }
  Copy-Item -LiteralPath $_.FullName -Destination $destination -Recurse -Force
  Write-Host "Installed $($_.Name) to $destination"
}

Write-Host "Codex Skeptic skills installed to $CodexSkills"
