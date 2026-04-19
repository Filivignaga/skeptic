# Skeptic: Analysis With Receipts

**A Claude Code skill that forces AI-assisted data analysis to follow the evidence instead of drifting into unsupported claims.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.1.0-green.svg)](CHANGELOG.md)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-purple.svg)]()

---

Ask any AI to "analyze this CSV" and watch what happens: it skips the question, picks a method, runs it, and hands you results with zero audit trail. The output looks professional. The methodology is indefensible.

Skeptic fixes this. It forces a 7-stage sequence where each stage has explicit gates, and claims that don't survive evaluation never reach the deliverable.

## How It Works

```
/skeptic:formulate    →  Lock the question type and claim boundaries
/skeptic:protocol     →  Set data-usage rules before touching data
/skeptic:clean        →  Prepare data under protocol constraints
/skeptic:examine      →  Inspect what the cleaned data can support
/skeptic:analyze      →  Execute one locked analysis contract
/skeptic:evaluate     →  PCS check: did the claims survive?
/skeptic:communicate  →  Package only what survived
```

`/skeptic:auto` runs the full sequence autonomously, pausing only for startup intake, escalation triggers, required human-input checkpoints, and stage-boundary approvals.

Each stage produces auditable artifacts. Each gate is enforceable. Backtracking is explicit and logged.

## Why This Exists

| What goes wrong | How Skeptic prevents it |
|---|---|
| Method chosen before the question is clear | **Question Before Query**: question type is classified and locked before any analysis code runs |
| Exploratory findings reported as conclusions | Examine stage is structurally separated from Analyze; no cross-contamination |
| Data splits applied mechanically | Protocol stage evaluates 8 data-usage modes and selects the one that matches the question |
| Claim strength exceeds the evidence | Claim Boundary Registry: a YAML registry of allowed vs. forbidden verbs, enforced downstream |
| Nobody can reconstruct why a result is trusted | Every stage produces named artifacts; the audit trail is the deliverable |
| Claims that fail evaluation still get reported | **Claims That Survive**: only PCS-passing claims reach the final output |

## Skeptic vs. Other Data Science Skills

| Capability | Skeptic | data-science-plugin | mlstack | DS Skills Marketplace | claude-scientific-skills |
|---|---|---|---|---|---|
| Question-first workflow | Yes | Partial | Partial | No | No |
| Protocol stage (rules before data) | Yes | No | No | No | No |
| Sequential stage enforcement | Yes | Suggested | Independent | No | No |
| Claim boundary enforcement | Yes | No | No | No | No |
| PCS evaluation gate | Yes | No | No | No | No |
| Route-specific analysis (6 types) | Yes | No | No | No | No |
| Auditable artifact chain | Yes | Partial | Partial | No | Partial |
| Dual-subagent review per cycle | Yes | Yes | No | No | No |
| Prevents unsupported claims | Yes | Partial | Partial | No | No |
| Knowledge compounding | No | Yes | No | No | No |
| ML model shipping pipeline | No | Yes | Yes | Yes | Partial |
| Breadth of libraries/tools | Narrow | Moderate | Moderate | Wide (79) | Wide (134) |

Other skills help you write analysis code faster or cover more libraries. Skeptic is the only one that enforces what you're allowed to claim and in what order you're allowed to work.

## Quick Start

**macOS, Linux, WSL, Git Bash:**

```bash
git clone https://github.com/Filivignaga/skeptic.git ~/.claude/skills/skeptic && ~/.claude/skills/skeptic/setup
```

**Windows PowerShell:**

```powershell
git clone https://github.com/Filivignaga/skeptic.git "$env:USERPROFILE\.claude\skills\skeptic"; & "$env:USERPROFILE\.claude\skills\skeptic\setup.ps1"
```

The setup script copies slash commands to `~/.claude/commands/skeptic/` (or `%USERPROFILE%\.claude\commands\skeptic\` on Windows). Safe to rerun.

**Verify:** type `/skeptic` in Claude Code. If it triggers the formulation stage, install is correct.

**Uninstall (bash):** `rm -rf ~/.claude/skills/skeptic ~/.claude/commands/skeptic`

**Uninstall (PowerShell):** `Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\skills\skeptic","$env:USERPROFILE\.claude\commands\skeptic"`

Then in Claude Code, point it at your data:

```text
Use Skeptic to analyze this dataset and determine whether churn is
a predictive or descriptive question before modeling anything.
```

**Requirements:** Claude Code with local skills enabled, Python 3.10+, Jupyter + nbconvert

## What It Produces

Every Skeptic run generates a project folder with:

```
your-project/
├── docs/
│   ├── 01_formulation.md      # Question type, claim boundary registry
│   ├── 02_protocol.md         # Data-usage mode, leakage rules, validation logic
│   ├── 03_clean_report.md     # Constraint spec, cleaning decisions
│   ├── 04_examination.md      # Support registry, analysis handoff
│   ├── 05_analysis.md         # Locked analysis contract + results
│   ├── 06_evaluation.md       # PCS verdicts, claim survival registry
│   └── 07_communication.md    # Final deliverable (surviving claims only)
├── notebooks/                 # Executable analysis notebooks
├── data/                      # Cleaned data + partition metadata
└── skeptic.yaml                # Project configuration
```

## Three Principles

**Question Before Query.** The question type and claim boundaries are defined before a single line of analysis code runs. The question constrains everything downstream -- not the other way around.

**Claims That Survive.** Every claim passes through PCS evaluation (Predictability, Computability, Stability). Claims that don't survive are discarded -- they cannot appear in the deliverable, regardless of how interesting they are.

**No Shortcuts to Claims.** Seven stages, each gated. You cannot skip protocol to start cleaning. You cannot skip evaluation to start communicating. Every conclusion is earned through the full process -- there is no fast path to the deliverable.

## Architecture

Skeptic supports 6 question types, each with route-specific constraints:

| Route | Example | What It Enforces |
|---|---|---|
| Descriptive | "What is the distribution of X?" | No causal or predictive verbs allowed |
| Exploratory | "Are there patterns in X?" | Findings labeled as hypotheses, not conclusions |
| Inferential | "Is there a difference between A and B?" | Sampling-frame-aware variance estimation required |
| Predictive | "Can we predict Y from X?" | Frozen holdout logic, no data leakage |
| Causal | "Does X cause Y?" | Propensity checks, IV diagnostics, falsification suites |
| Mechanistic | "How does X produce Y?" | Pathway evidence required, no black-box claims |

Each route loads specific instruction files from `references/routes/` that narrow the stage-core behavior.

## Repository Layout

```
skeptic/
├── SKILL.md                    # Trigger metadata, subcommand table
├── SPEC.md                     # Architecture contract
├── README.md
├── LICENSE
├── VERSION
├── CHANGELOG.md
├── CONTRIBUTING.md
├── skeptic.yaml                # Project configuration
├── setup                       # One-line install script
├── commands/                   # Slash command definitions (8 files)
└── references/
    ├── core-principles.md      # Master architecture
    ├── constraint-spec.md      # Constraint file format
    ├── auto-mode.md            # /skeptic:auto runtime
    ├── data-formats.md         # Format-agnostic ingest rules
    ├── formulate.md            # Stage 1
    ├── protocol.md             # Stage 2
    ├── clean.md                # Stage 3
    ├── examine.md              # Stage 4
    ├── analyze.md              # Stage 5
    ├── evaluate.md             # Stage 6
    ├── communicate.md          # Stage 7
    └── routes/                 # 6 question types × 5 stage files
        ├── descriptive/
        ├── exploratory/
        ├── inferential/
        ├── predictive/
        ├── causal/
        └── mechanistic/
```

## Built On

Skeptic is a structural implementation of ideas from:

- **Bin Yu & Rebecca Barter** -- *Veridical Data Science* (2024). The PCS framework (Predictability, Computability, Stability) and the epistemological foundation for trustworthy data analysis.
- **Jeff Leek** -- *The Elements of Data Analytic Style* (2015). The six question types (descriptive, exploratory, inferential, predictive, causal, mechanistic) and the principle that the question type determines what the data can legitimately support.
- **Sam Lau, Joseph Gonzalez & Deborah Nolan** -- *Learning Data Science* (2023). The data science lifecycle structure and the discipline of scoping analysis before execution.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). PRs reviewed within 72 hours.

If you change the workflow:
- Payoff before theory
- Install before deep docs
- Examples before architecture
- Product language in the README, formal language in references

## License

[MIT](LICENSE)
