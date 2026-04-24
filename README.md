# Skeptic: Analysis With Receipts

Skeptic is a Claude Code skill for question-first, auditable data analysis. It keeps the workflow focused on what the data can support and prevents unsupported claims from reaching the final deliverable.

## How It Works

```text
/skeptic:formulate    -> Lock the question type and claim boundaries
/skeptic:protocol     -> Set data-usage rules before cleaning or analysis
/skeptic:clean        -> Prepare data under protocol constraints
/skeptic:examine      -> Inspect what the cleaned data can support
/skeptic:analyze      -> Execute one locked analysis contract
/skeptic:evaluate     -> Decide which claims survive PCS review
/skeptic:communicate  -> Package only what survived
```

`/skeptic:auto` runs the full sequence autonomously, pausing only for startup intake, escalation triggers, required human-input checkpoints, and stage-boundary approvals.

Each stage has explicit required evidence, acceptance criteria, and a compact decision ledger. Backtracking is explicit and preserved.

## Artifact Model

Every stage writes a compact artifact set:

- `{docs_dir_name}/{NN}_{stage}.yaml` as canonical stage memory
- `{scripts_dir_name}/{NN}_{stage}.py` as the project-side evidence script
- `{docs_dir_name}/{NN}_{stage}.md` as the final rendered report
- one short README status block at stage close

Only the canonical YAML, stage script, rendered report, README block, and declared deliverables belong to the active artifact contract. Compact metrics, acceptance state, narrowing history, review summaries, and decision history live inside the canonical YAML.

## What It Prevents

| Failure mode | Skeptic control |
|---|---|
| Method chosen before the question is clear | `formulate` locks the question type and claim boundary first |
| Data access rules invented midstream | `protocol` locks visibility, validation, and prohibitions before `clean` |
| Exploratory patterns reported as conclusions | `examine` maps support but does not select the analysis contract |
| Analysis revised after seeing results | `analyze` locks one executable contract before execution |
| Weak claims packaged for an audience | `evaluate` determines claim survival before `communicate` |
| Process artifacts distract from analysis | canonical YAML holds compact state; markdown is rendered at close |

## Project Output

```text
your-project/
  data/
  deliverables/
  skeptic_documentation/
    01_formulation.yaml
    01_formulation.md
    02_protocol.yaml
    02_protocol.md
    ...
    07_communication.yaml
    07_communication.md
  scripts/
    01_formulation.py
    02_protocol.py
    ...
    07_communication.py
    stdout/
  README.md
```

## Repository Layout

```text
skeptic/
  SKILL.md
  commands/
  references/
    core-principles.md
    auto-mode.md
    script-contract.md
    formulate/
      formulate.md
      cycles/
    protocol/
      protocol.md
      cycles/
    clean/
      clean.md
      cycles/
    examine/
      examine.md
      cycles/
    analyze/
      analyze.md
      cycles/
    evaluate/
      evaluate.md
      cycles/
    communicate/
      communicate.md
      cycles/
    routes/
```

## Requirements

- Claude Code with local skills enabled
- Python 3.10+

## Install

macOS, Linux, WSL, Git Bash:

```bash
git clone https://github.com/Filivignaga/skeptic.git ~/.claude/skills/skeptic && ~/.claude/skills/skeptic/setup
```

Windows PowerShell:

```powershell
git clone https://github.com/Filivignaga/skeptic.git "$env:USERPROFILE\.claude\skills\skeptic"; & "$env:USERPROFILE\.claude\skills\skeptic\setup.ps1"
```

## Principles

**Question Before Query.** The question type and claim boundary are defined before analysis code runs.

**Claims That Survive.** Every claim passes through PCS evaluation: Predictability, Computability, and Stability.

**No Shortcuts to Claims.** Seven stages must close against their acceptance criteria before the final deliverable is complete.

## Built On

- Bin Yu and Rebecca Barter, *Veridical Data Science*.
- Jeff Leek, *The Elements of Data Analytic Style*.
- Sam Lau, Joseph Gonzalez, and Deborah Nolan, *Learning Data Science*.

## License

[MIT](LICENSE)
