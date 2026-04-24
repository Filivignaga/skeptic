#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$CodexRoot = Join-Path $RepoRoot 'codex'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Text
  )

  [System.IO.File]::WriteAllText($Path, $Text, $script:Utf8NoBom)
}

$Stages = @(
  @{ Stage = 'formulate'; Number = 1; Source = 'references\formulate\formulate.md'; DescriptionPrefix = 'Skeptic problem formulation and data context.' },
  @{ Stage = 'protocol'; Number = 2; Source = 'references\protocol\protocol.md'; DescriptionPrefix = 'Skeptic protocol and project rules.' },
  @{ Stage = 'clean'; Number = 3; Source = 'references\clean\clean.md'; DescriptionPrefix = 'Skeptic auditable data cleaning.' },
  @{ Stage = 'examine'; Number = 4; Source = 'references\examine\examine.md'; DescriptionPrefix = 'Skeptic cleaned-data examination.' },
  @{ Stage = 'analyze'; Number = 5; Source = 'references\analyze\analyze.md'; DescriptionPrefix = 'Skeptic analysis contract lock and execution.' },
  @{ Stage = 'evaluate'; Number = 6; Source = 'references\evaluate\evaluate.md'; DescriptionPrefix = 'Skeptic route-appropriate PCS evaluation.' },
  @{ Stage = 'communicate'; Number = 7; Source = 'references\communicate\communicate.md'; DescriptionPrefix = 'Skeptic communication of evaluated results.' }
)

function Split-Frontmatter {
  param([string]$Text)

  if ($Text -notmatch '(?s)^---\r?\n(.*?)\r?\n---\r?\n(.*)$') {
    throw 'Expected markdown file with YAML frontmatter.'
  }

  return @{
    Frontmatter = $Matches[1]
    Body = $Matches[2]
  }
}

function Get-Description {
  param([string]$Frontmatter)

  $match = [regex]::Match($Frontmatter, '(?m)^description:\s*(.*)$')
  if (-not $match.Success) {
    throw 'Missing description in source frontmatter.'
  }

  return $match.Groups[1].Value.Trim()
}

function Convert-BodyForCodex {
  param(
    [string]$Body,
    [string]$Stage = ''
  )

  $converted = $Body
  $converted = $converted -replace '\.\./core-principles\.md', 'references/core-principles.md'
  $converted = $converted -replace '\.\./script-contract\.md', 'references/script-contract.md'
  $converted = $converted -replace '\.\./auto-mode\.md', 'references/auto-mode.md'
  if ($Stage) {
    $converted = $converted -replace "\.\./routes/\{route\}/$Stage\.md", 'references/routes/{route}.md'
    $converted = $converted -replace "\.\./routes/\{active\}/$Stage\.md", 'references/routes/{active}.md'
    $converted = $converted -replace "\.\./routes/\{active_route\}/$Stage\.md", 'references/routes/{active_route}.md'
    $converted = $converted -replace "references/routes/\{route\}/$Stage\.md", 'references/routes/{route}.md'
    $converted = $converted -replace "references/routes/\{active\}/$Stage\.md", 'references/routes/{active}.md'
    $converted = $converted -replace "references/routes/\{active_route\}/$Stage\.md", 'references/routes/{active_route}.md'
  }
  $converted = $converted -replace '\.\./routes/\{route\}/', 'references/routes/{route}/'
  $converted = $converted -replace '\.\./routes/\{active\}/', 'references/routes/{active}/'

  return $converted.TrimEnd() + "`r`n"
}

function Add-StageAutoInstruction {
  param(
    [string]$Body,
    [string]$Stage
  )

  $instruction = @'

## Codex Invocation

Use this skill for `skeptic __STAGE__`. If the user writes `skeptic __STAGE__ --auto`, run this same stage in auto mode: read `references/auto-mode.md` and apply its autonomous cycle protocol only to the `__STAGE__` stage. This folder is self-contained for this stage.

'@
  $instruction = $instruction.Replace('__STAGE__', $Stage)

  return ($instruction + $Body)
}

function Convert-StandaloneReferenceText {
  param(
    [string]$Text,
    [string]$Stage = ''
  )

  $converted = $Text
  if ($Stage) {
    $converted = $converted -replace "\.\./\.\./routes/([^/]+)/$Stage\.md", '../routes/$1.md'
    $converted = $converted -replace "\.\./routes/\{route\}/$Stage\.md", 'routes/{route}.md'
    $converted = $converted -replace "\.\./routes/\{active\}/$Stage\.md", 'routes/{active}.md'
    $converted = $converted -replace "\.\./routes/\{active_route\}/$Stage\.md", 'routes/{active_route}.md'
    $converted = $converted -replace "references/routes/\{route\}/[^/]+\.md", 'references/routes/{route}.md'
    $converted = $converted -replace "references/routes/\{active\}/[^/]+\.md", 'references/routes/{active}.md'
    $converted = $converted -replace "references/routes/\{active_route\}/[^/]+\.md", 'references/routes/{active_route}.md'
  }
  $converted = $converted -replace '\.\./\.\./core-principles\.md', '../core-principles.md'
  $converted = $converted -replace '\.\./\.\./script-contract\.md', '../script-contract.md'
  $converted = $converted -replace '\.\./\.\./auto-mode\.md', '../auto-mode.md'
  $converted = $converted -replace '\.\./\.\./routes/', '../routes/'
  $converted = $converted -replace '\.\./core-principles\.md', 'core-principles.md'
  $converted = $converted -replace '\.\./script-contract\.md', 'script-contract.md'
  $converted = $converted -replace '\.\./auto-mode\.md', 'auto-mode.md'
  $converted = $converted -replace '\.\./routes/\{route\}/', 'routes/{route}/'
  $converted = $converted -replace '\.\./routes/\{active\}/', 'routes/{active}/'
  return $converted
}

function Convert-MarkdownAndYamlFiles {
  param(
    [string]$Root,
    [string]$Stage = ''
  )

  Get-ChildItem -LiteralPath $Root -Recurse -File | Where-Object { $_.Extension -in @('.md', '.yaml', '.yml') } | ForEach-Object {
    $text = Get-Content -LiteralPath $_.FullName -Raw
    $converted = Convert-StandaloneReferenceText -Text $text -Stage $Stage
    if ($converted -ne $text) {
      Write-Utf8NoBom -Path $_.FullName -Text $converted
    }
  }
}

function Write-SkillMarkdown {
  param(
    [string]$Path,
    [string]$Name,
    [string]$Description,
    [string]$Body
  )

  $content = @"
---
name: $Name
description: $Description
---

$Body
"@

  Write-Utf8NoBom -Path $Path -Text $content
}

function Copy-CommonReferences {
  param([string]$SkillDir)

  $refs = Join-Path $SkillDir 'references'
  New-Item -ItemType Directory -Force -Path $refs | Out-Null

  foreach ($file in @('core-principles.md', 'script-contract.md', 'auto-mode.md')) {
    Copy-Item -LiteralPath (Join-Path $RepoRoot "references\$file") -Destination (Join-Path $refs $file) -Force
  }
}

function Copy-StageReferences {
  param(
    [string]$Stage,
    [string]$SkillDir
  )

  $source = Join-Path $RepoRoot "references\$Stage"
  $destination = Join-Path $SkillDir 'references'

  Get-ChildItem -LiteralPath $source -Force | Where-Object { $_.Name -ne "$Stage.md" } | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $destination -Recurse -Force
  }
}

function Copy-RoutesForStage {
  param(
    [string]$Stage,
    [string]$SkillDir
  )

  $routesRoot = Join-Path $RepoRoot 'references\routes'
  $destinationRoot = Join-Path $SkillDir 'references\routes'
  New-Item -ItemType Directory -Force -Path $destinationRoot | Out-Null

  Get-ChildItem -LiteralPath $routesRoot -Directory | ForEach-Object {
    $sourceFile = Join-Path $_.FullName "$Stage.md"
    if (Test-Path -LiteralPath $sourceFile) {
      Copy-Item -LiteralPath $sourceFile -Destination (Join-Path $destinationRoot "$($_.Name).md") -Force
    }
  }
}

if (Test-Path -LiteralPath $CodexRoot) {
  Remove-Item -LiteralPath $CodexRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $CodexRoot | Out-Null

foreach ($stageInfo in $Stages) {
  $stage = $stageInfo.Stage
  $skillName = "skeptic-$stage"
  $skillDir = Join-Path $CodexRoot $skillName
  New-Item -ItemType Directory -Force -Path $skillDir | Out-Null

  $sourcePath = Join-Path $RepoRoot $stageInfo.Source
  $sourceText = Get-Content -LiteralPath $sourcePath -Raw
  $parts = Split-Frontmatter -Text $sourceText
  $sourceDescription = Get-Description -Frontmatter $parts.Frontmatter
  $description = "$($stageInfo.DescriptionPrefix) $sourceDescription Use when Codex should run the Skeptic $stage stage as a standalone skill, including requests like `skeptic $stage --auto` to run this stage with autonomous cycle execution."
  $body = Add-StageAutoInstruction -Body (Convert-BodyForCodex -Body $parts.Body -Stage $stage) -Stage $stage

  Write-SkillMarkdown -Path (Join-Path $skillDir 'SKILL.md') -Name $skillName -Description $description -Body $body
  Copy-CommonReferences -SkillDir $skillDir
  Copy-StageReferences -Stage $stage -SkillDir $skillDir
  Copy-RoutesForStage -Stage $stage -SkillDir $skillDir
  Convert-MarkdownAndYamlFiles -Root (Join-Path $skillDir 'references') -Stage $stage
}

Write-Host "Codex Skeptic skills synchronized to $CodexRoot"
