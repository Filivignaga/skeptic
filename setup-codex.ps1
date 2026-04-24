#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'

$RepoRoot = $PSScriptRoot
$PackRoot = Join-Path $RepoRoot 'codex'

if (-not (Test-Path -LiteralPath $PackRoot)) {
    throw "Codex skill pack not found: $PackRoot"
}

$SkillsRoot = if ($env:CODEX_HOME) {
    Join-Path $env:CODEX_HOME 'skills'
} else {
    Join-Path $env:USERPROFILE '.codex\skills'
}

function Test-SkillFrontmatter {
    param(
        [Parameter(Mandatory = $true)][string]$SkillFile
    )

    $content = Get-Content -LiteralPath $SkillFile -Raw
    if ($content -notmatch '(?s)^---\s*\r?\n(.+?)\r?\n---') {
        throw "Missing YAML frontmatter: $SkillFile"
    }

    $frontmatter = $Matches[1]
    if ($frontmatter -notmatch '(?m)^name:\s*\S+') {
        throw "Missing frontmatter name: $SkillFile"
    }
    if ($frontmatter -notmatch '(?m)^description:\s*\S+') {
        throw "Missing frontmatter description: $SkillFile"
    }
}

function Test-ReferencedFiles {
    param(
        [Parameter(Mandatory = $true)][string]$SkillDir
    )

    $skillFile = Join-Path $SkillDir 'SKILL.md'
    $content = Get-Content -LiteralPath $skillFile -Raw
    $matches = [regex]::Matches($content, '`([^`]+)`')

    foreach ($match in $matches) {
        $ref = $match.Groups[1].Value
        if ($ref -notmatch '^(references|skeptic\.yaml)(/|\\|$)') {
            continue
        }
        if ($ref -match '[{}]') {
            continue
        }

        $relative = $ref -replace '/', '\'
        $target = Join-Path $SkillDir $relative
        if (-not (Test-Path -LiteralPath $target)) {
            throw "Missing referenced file in $skillFile : $ref"
        }
    }
}

function Test-MarkdownReferenceFiles {
    param(
        [Parameter(Mandatory = $true)][string]$SkillDir
    )

    $docs = Get-ChildItem -LiteralPath $SkillDir -Recurse -File -Include '*.md'
    foreach ($doc in $docs) {
        $content = Get-Content -LiteralPath $doc.FullName -Raw
        $matches = [regex]::Matches($content, '`([^`]+)`')

        foreach ($match in $matches) {
            $ref = $match.Groups[1].Value
            if ($ref -match '[{}]') {
                continue
            }
            if ($ref -notmatch '^(cycles/|routes/|core-principles\.md$|script-contract\.md$|auto-mode\.md$|bootstrap\.md$|data-formats\.md$).*\.(md|yaml)$') {
                continue
            }

            $baseDir = if ($doc.Name -eq 'SKILL.md') { $SkillDir } else { $doc.DirectoryName }
            $relative = $ref -replace '/', '\'
            $target = Join-Path $baseDir $relative
            if (-not (Test-Path -LiteralPath $target)) {
                throw "Missing markdown reference in $($doc.FullName) : $ref"
            }
        }
    }
}

function Test-CodexSkill {
    param(
        [Parameter(Mandatory = $true)][string]$SkillDir
    )

    $skillFile = Join-Path $SkillDir 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile)) {
        throw "Missing SKILL.md: $SkillDir"
    }

    Test-SkillFrontmatter -SkillFile $skillFile
    Test-ReferencedFiles -SkillDir $SkillDir
    Test-MarkdownReferenceFiles -SkillDir $SkillDir
}

$skillDirs = Get-ChildItem -LiteralPath $PackRoot -Directory | Sort-Object Name
if ($skillDirs.Count -eq 0) {
    throw "No Codex skill directories found under $PackRoot"
}

foreach ($skill in $skillDirs) {
    Test-CodexSkill -SkillDir $skill.FullName
}

Write-Host "Validated $($skillDirs.Count) Codex skills from $PackRoot"

if ($ValidateOnly) {
    return
}

New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null

foreach ($skill in $skillDirs) {
    $destination = Join-Path $SkillsRoot $skill.Name
    if ((Test-Path -LiteralPath $destination) -and -not $Force) {
        throw "Skill already exists: $destination. Re-run with -Force to overwrite."
    }

    if (Test-Path -LiteralPath $destination) {
        Remove-Item -LiteralPath $destination -Recurse -Force
    }

    Copy-Item -LiteralPath $skill.FullName -Destination $destination -Recurse -Force
    Write-Host "Installed $($skill.Name)"
}

Write-Host "Skeptic Codex skills installed to $SkillsRoot"
Write-Host "Restart Codex to pick up new skills."
