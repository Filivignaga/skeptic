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
  param([string]$Body)

  $converted = $Body
  $converted = $converted -replace '\.\./core-principles\.md', 'references/core-principles.md'
  $converted = $converted -replace '\.\./script-contract\.md', 'references/script-contract.md'
  $converted = $converted -replace '\.\./auto-mode\.md', 'references/auto-mode.md'
  $converted = $converted -replace '\.\./routes/\{route\}/', 'references/routes/{route}/'
  $converted = $converted -replace '\.\./routes/\{active\}/', 'references/routes/{active}/'
  $converted = $converted -replace 'references/\{stage\}/\{stage\}\.md', 'references/stages/{stage}/{stage}.md'
  $converted = $converted -replace 'references/\{stage\}/cycles/\{cycle\}\.yaml', 'references/stages/{stage}/cycles/{cycle}.yaml'
  $converted = $converted -replace 'references/\{stage\}/cycles/\*\.yaml', 'references/stages/{stage}/cycles/*.yaml'

  return $converted.TrimEnd() + "`r`n"
}

function Convert-StandaloneReferenceText {
  param([string]$Text)

  $converted = $Text
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

function Convert-AutoReferenceText {
  param([string]$Text)

  $converted = $Text
  $converted = $converted -replace 'references/\{stage\}/\{stage\}\.md', 'references/stages/{stage}/{stage}.md'
  $converted = $converted -replace 'references/\{stage\}/cycles/\{cycle\}\.yaml', 'references/stages/{stage}/cycles/{cycle}.yaml'
  $converted = $converted -replace 'references/\{stage\}/cycles/\*\.yaml', 'references/stages/{stage}/cycles/*.yaml'
  $converted = $converted -replace '\.\./\.\./core-principles\.md', '../../../core-principles.md'
  $converted = $converted -replace '\.\./\.\./script-contract\.md', '../../../script-contract.md'
  $converted = $converted -replace '\.\./\.\./auto-mode\.md', '../../../auto-mode.md'
  $converted = $converted -replace '\.\./\.\./routes/', '../../../routes/'
  $converted = $converted -replace '(?<!\.\./)\.\./core-principles\.md', '../../core-principles.md'
  $converted = $converted -replace '(?<!\.\./)\.\./script-contract\.md', '../../script-contract.md'
  $converted = $converted -replace '(?<!\.\./)\.\./auto-mode\.md', '../../auto-mode.md'
  $converted = $converted -replace '(?<!\.\./)\.\./routes/\{route\}/', '../../routes/{route}/'
  $converted = $converted -replace '(?<!\.\./)\.\./routes/\{active\}/', '../../routes/{active}/'
  return $converted
}

function Convert-MarkdownAndYamlFiles {
  param(
    [string]$Root,
    [string]$Mode
  )

  Get-ChildItem -LiteralPath $Root -Recurse -File | Where-Object { $_.Extension -in @('.md', '.yaml', '.yml') } | ForEach-Object {
    $text = Get-Content -LiteralPath $_.FullName -Raw
    if ($Mode -eq 'auto') {
      $converted = Convert-AutoReferenceText -Text $text
    } else {
      $converted = Convert-StandaloneReferenceText -Text $text
    }
    if ($converted -ne $text) {
      Write-Utf8NoBom -Path $_.FullName -Text $converted
    }
  }
}

function Repair-AutoCycleReferences {
  param([string]$AutoReferencesRoot)

  Get-ChildItem -LiteralPath (Join-Path $AutoReferencesRoot 'stages') -Recurse -File | Where-Object {
    $_.FullName -match '\\cycles\\' -and $_.Extension -in @('.md', '.yaml', '.yml')
  } | ForEach-Object {
    $text = Get-Content -LiteralPath $_.FullName -Raw
    $converted = $text
    while ($converted.Contains('../../../../core-principles.md')) {
      $converted = $converted.Replace('../../../../core-principles.md', '../../../core-principles.md')
    }
    $converted = $converted -replace '\.\./\.\./core-principles\.md', '../../../core-principles.md'
    $converted = $converted -replace '\.\./\.\./script-contract\.md', '../../../script-contract.md'
    $converted = $converted -replace '\.\./\.\./auto-mode\.md', '../../../auto-mode.md'
    $converted = $converted -replace '\.\./\.\./routes/', '../../../routes/'
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

  Get-ChildItem -LiteralPath $routesRoot -Directory | ForEach-Object {
    $sourceFile = Join-Path $_.FullName "$Stage.md"
    if (Test-Path -LiteralPath $sourceFile) {
      $destinationDir = Join-Path $destinationRoot $_.Name
      New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
      Copy-Item -LiteralPath $sourceFile -Destination (Join-Path $destinationDir "$Stage.md") -Force
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
  $description = "$($stageInfo.DescriptionPrefix) $sourceDescription Use when Codex should run the Skeptic $stage stage as a standalone skill."
  $body = Convert-BodyForCodex -Body $parts.Body

  Write-SkillMarkdown -Path (Join-Path $skillDir 'SKILL.md') -Name $skillName -Description $description -Body $body
  Copy-CommonReferences -SkillDir $skillDir
  Copy-StageReferences -Stage $stage -SkillDir $skillDir
  Copy-RoutesForStage -Stage $stage -SkillDir $skillDir
  Convert-MarkdownAndYamlFiles -Root (Join-Path $skillDir 'references') -Mode 'standalone'
}

$autoDir = Join-Path $CodexRoot 'skeptic-auto'
New-Item -ItemType Directory -Force -Path $autoDir | Out-Null
Copy-CommonReferences -SkillDir $autoDir

$autoBody = Convert-BodyForCodex -Body (Get-Content -LiteralPath (Join-Path $RepoRoot 'references\auto-mode.md') -Raw)
$autoBody = $autoBody -replace 'For each stage:', "For each stage, read the corresponding local stage file under ``references/stages/{stage}/{stage}.md``:"
$autoDescription = 'Skeptic Auto Mode - run the full question-first Veridical Data Science lifecycle end to end with autonomous cycle execution, bounded escalation, stage-boundary approvals, and cross-stage audit. Use when Codex should run Skeptic automatically, run the full Skeptic lifecycle, invoke skeptic auto, or execute all Skeptic stages in order.'
Write-SkillMarkdown -Path (Join-Path $autoDir 'SKILL.md') -Name 'skeptic-auto' -Description $autoDescription -Body $autoBody

$autoRefs = Join-Path $autoDir 'references'
$autoStages = Join-Path $autoRefs 'stages'
New-Item -ItemType Directory -Force -Path $autoStages | Out-Null
foreach ($stageInfo in $Stages) {
  $stage = $stageInfo.Stage
  $stageDestination = Join-Path $autoStages $stage
  New-Item -ItemType Directory -Force -Path $stageDestination | Out-Null

  $sourceText = Get-Content -LiteralPath (Join-Path $RepoRoot $stageInfo.Source) -Raw
  $parts = Split-Frontmatter -Text $sourceText
  Write-Utf8NoBom -Path (Join-Path $stageDestination "$stage.md") -Text (Convert-BodyForCodex -Body $parts.Body)

  Copy-Item -LiteralPath (Join-Path $RepoRoot "references\$stage\cycles") -Destination $stageDestination -Recurse -Force
  Get-ChildItem -LiteralPath (Join-Path $RepoRoot "references\$stage") -File | Where-Object { $_.Name -ne "$stage.md" } | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $stageDestination $_.Name) -Force
  }
}
Copy-Item -LiteralPath (Join-Path $RepoRoot 'references\routes') -Destination $autoRefs -Recurse -Force
Convert-MarkdownAndYamlFiles -Root $autoRefs -Mode 'auto'
Repair-AutoCycleReferences -AutoReferencesRoot $autoRefs
Get-ChildItem -LiteralPath $autoRefs -Recurse -File | Where-Object { $_.Extension -in @('.md', '.yaml', '.yml') } | ForEach-Object {
  $text = Get-Content -LiteralPath $_.FullName -Raw
  $converted = $text.Replace('../../../../core-principles.md', '../../../core-principles.md')
  if ($converted -ne $text) {
    Write-Utf8NoBom -Path $_.FullName -Text $converted
  }
}

Write-Host "Codex Skeptic skills synchronized to $CodexRoot"
