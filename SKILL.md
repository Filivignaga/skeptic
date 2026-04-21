---
name: skeptic
description: Use when running a question-first Veridical Data Science lifecycle: formulate the question, define protocol rules, clean under those rules, examine what the data can support, execute route-specific analysis under an explicit contract lock, evaluate claims, and communicate only claims that survived evaluation. Use when the user says "data analysis", "analyze this dataset", "analyze this CSV", "analyze this parquet", "data science", "Skeptic", or invokes any /skeptic subcommand.
---

# Skeptic - Veridical Data Science Lifecycle

Use a question-first lifecycle. Do not start from a favorite method. Do not assume train/validation/test splits. Do not assume predictive modeling is the default endpoint. `protocol` decides the project rules before `clean` starts; later stages must obey those rules. PCS applies throughout. `/skeptic:evaluate` is the formal route-appropriate PCS review before `/skeptic:communicate`.

## Mandatory Read: Core Principles

Before executing any Skeptic subcommand, read `references/core-principles.md`. That file is the architecture contract. If any downstream stage file conflicts with it, `references/core-principles.md` wins.

## Subcommands

| Subcommand | Purpose |
|------------|---------|
| `/skeptic:formulate` | Define the domain question, target quantity, question type, and initial claim boundary. |
| `/skeptic:protocol` | Lock data-usage mode, evidence logic, validation rules, prohibitions, and backtracking triggers. |
| `/skeptic:clean` | Prepare data under `formulate` plus `protocol` without widening the claim boundary. |
| `/skeptic:examine` | Inspect cleaned data to determine what the data can actually support. |
| `/skeptic:analyze` | Lock one executable analysis contract and run the route-specific analysis. |
| `/skeptic:evaluate` | Run route-appropriate PCS review of outputs and claims. |
| `/skeptic:communicate` | Package only claims that survived evaluation. |
| `/skeptic:auto` | Run the full 7-stage pipeline autonomously with stage-boundary approvals. |

## Stage Progression

1. `formulate` defines the question.
2. `protocol` defines how the question may be answered.
3. `clean` prepares the data under those rules.
4. `examine` inspects what the data can support under those rules.
5. `analyze` locks the executable analysis contract and executes the approved route.
6. `evaluate` checks whether claims survive PCS.
7. `communicate` packages only claims that survived evaluation.

Earlier stages may need to reopen when later evidence shows a protocol mismatch, unsupported claim, or instability. When that happens, preserve the audit trail and return to the stage that set the invalid assumption.

## How Each Stage Loads Its Context

Each stage uses a lean entry file plus per-cycle YAML specs:

- stage entry: `references/{stage}/{stage}.md` -- read once at stage start.
- per-cycle specs: `references/{stage}/cycles/{cycle}.yaml` -- read one at a time as each cycle runs.

Each stage writes a canonical YAML (`{NN}_{stage}.yaml`), runs a project-side Python script (`{NN}_{stage}.py`, one function per cycle, invoked `--cycle X`), and renders the final markdown (`{NN}_{stage}.md`) only at stage close. See `references/core-principles.md` for the full artifact model.
