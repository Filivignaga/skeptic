# Skeptic: Analysis With Receipts

Skeptic is a Claude Code skill for question-first data analysis. It forces the
workflow to follow the evidence instead of drifting into unsupported claims.

## How It Works

```text
/skeptic:formulate    -> lock the question and claim boundary
/skeptic:protocol     -> lock data-usage and validation rules
/skeptic:clean        -> prepare data under those rules
/skeptic:examine      -> inspect what the data can actually support
/skeptic:analyze      -> execute one locked analysis contract
/skeptic:evaluate     -> check whether claims survive PCS
/skeptic:communicate  -> package only what survived
```

`/skeptic:auto` runs the full sequence autonomously with stage-boundary
approvals.

## Core Ideas

- Question before method.
- Protocol before cleaning and analysis.
- Claim boundaries are explicit and enforceable.
- Canonical YAML and machine-readable metrics come first.
- Project-side Python scripts run one cycle at a time.
- Markdown reports are derived outputs, not working memory.

## Formulate v2 Shape

`formulate` now follows a lean, script-first structure:

- `references/formulate.md` is a small stage entry file
- `references/formulate/cycles/*.yaml` hold cycle-specific rules
- the project writes `01_formulation.yaml` first
- the project runs `01_formulation.py --cycle {X}` one cycle at a time
- the project renders `01_formulation.md` only after canonical artifacts are consistent

## What It Produces

Each project lives under the configured `projects_root` and writes its own
artifacts inside the project folder.

Current formulate artifacts:

```text
your-project/
  data/
  skeptic_documentation/
    01_formulation.py
    01_formulation.yaml
    01_formulation.md
  README.md
```

Later stages will follow the same pattern: canonical structured artifacts first,
human-readable markdown last.

## Repository Layout

```text
skeptic/
  SKILL.md
  README.md
  CHANGELOG.md
  LICENSE
  VERSION
  CONTRIBUTING.md
  skeptic.yaml
  setup
  setup.ps1
  commands/
    formulate.md
    auto.md
    protocol.md
    clean.md
    examine.md
    analyze.md
    evaluate.md
    communicate.md
  references/
    core-principles.md
    auto-mode.md
    data-formats.md
    formulate.md
    formulate/
      cycles/
        A.yaml
        B.yaml
        C.yaml
        D.yaml
        E.yaml
    protocol.md
    clean.md
    examine.md
    analyze.md
    evaluate.md
    communicate.md
    routes/
      descriptive/
      exploratory/
      inferential/
      predictive/
      causal/
      mechanistic/
```

## Install

macOS, Linux, WSL, Git Bash:

```bash
git clone https://github.com/Filivignaga/skeptic.git ~/.claude/skills/skeptic && ~/.claude/skills/skeptic/setup
```

Windows PowerShell:

```powershell
git clone https://github.com/Filivignaga/skeptic.git "$env:USERPROFILE\.claude\skills\skeptic"
& "$env:USERPROFILE\.claude\skills\skeptic\setup.ps1"
```

The setup script copies slash commands to the Claude commands directory. Safe to
rerun.

## Requirements

- Claude Code with local skills enabled
- Python 3.10+

## Built On

Skeptic is structurally informed by:

- Bin Yu and Rebecca Barter on Veridical Data Science and PCS
- Jeff Leek on question types in data analysis
- Sam Lau, Joseph Gonzalez, and Deborah Nolan on lifecycle discipline

## License

[MIT](LICENSE)
