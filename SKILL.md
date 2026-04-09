---
name: skeptic
description: Use when running a question-first Veridical Data Science lifecycle: formulate the question, define protocol rules, clean under those rules, examine what the data can support, execute route-specific analysis under an explicit contract lock, evaluate claims, and communicate only claims that survived evaluation. Use when the user says "data analysis", "analyze this dataset", "analyze this CSV", "analyze this parquet", "data science", "Skeptic", or invokes any /skeptic subcommand.
---

# Skeptic - Veridical Data Science Lifecycle

Use a question-first lifecycle. Do not start from a favorite method. Do not assume train, validation, and test splits. Do not assume predictive modeling is the default endpoint. `protocol` decides the project rules before `clean` starts, and later stages must obey those rules.

PCS applies throughout the lifecycle. `/skeptic:evaluate` is the formal route-appropriate PCS review before `/skeptic:communicate`.

## Mandatory Read: Core Principles

Before executing any Skeptic subcommand, read `references/core-principles.md`.

`core-principles.md` is the architecture contract. If any downstream stage file conflicts with it, `core-principles.md` wins.

## Subcommands

| Subcommand | Purpose |
|------------|---------|
| `/skeptic:formulate` | Define the domain question, target quantity, question type, and initial claim boundary |
| `/skeptic:auto` | Run the full 7-stage Skeptic pipeline autonomously with stage-boundary approvals |
| `/skeptic:protocol` | Define the project rules of the game before clean starts |
| `/skeptic:clean` | Prepare data under `formulate` plus `protocol` without widening the claim boundary |
| `/skeptic:examine` | Inspect cleaned data to determine what the data can actually support |
| `/skeptic:analyze` | Lock the executable analysis contract, run the route-specific analysis, and do not widen the claim boundary |
| `/skeptic:evaluate` | Perform route-appropriate PCS review of outputs and claims |
| `/skeptic:communicate` | Package only claims that survived evaluation |

## /skeptic:formulate

Define the question first. Fix the unit of analysis, target quantity, question type, and initial claim boundary so later stages know what problem they are allowed to solve.

## /skeptic:protocol

Define the project rules of the game before clean starts. Lock data usage, admissible evidence logic, validation requirements, major prohibitions, and backtracking triggers without choosing the exact analysis specification.

## /skeptic:clean

Prepare data under `formulate` plus `protocol`. Build an auditable data pipeline that fixes structural and value issues without smuggling in unsupported claims.

## /skeptic:examine

Run the post-clean data inspection stage that determines what the data can actually support. Inspect distributions, relationships, structure, anomalies, and candidate patterns under the active protocol rules.

## /skeptic:analyze

Start from the approved question, protocol, cleaned data, and examination handoff. First lock one executable analysis contract inside those constraints, then run the descriptive, exploratory, inferential, predictive, causal, or mechanistic analysis without widening the claim boundary.

## /skeptic:evaluate

Perform route-appropriate PCS review. Check whether outputs and claims survive predictability, computability, and stability requirements under the approved protocol and analysis contract used in `analyze`.

## /skeptic:communicate

Package only claims that survived evaluation for the intended audience. Translate claims into audience-appropriate language, present uncertainty and stability evidence honestly, disclose all mandatory limitations, generate bounded recommendations, and produce a self-sufficient deliverable without re-analyzing data, re-evaluating claims, or widening the claim boundary.

## Stage Progression

1. `formulate` defines the question.
2. `protocol` defines how the question may be answered.
3. `clean` prepares the data under those rules.
4. `examine` inspects what the data can support under those rules.
5. `analyze` locks the executable analysis contract and executes the approved route.
6. `evaluate` checks whether claims survive PCS.
7. `communicate` packages only claims that survived evaluation.

Earlier stages may need to reopen when later evidence shows a protocol mismatch, unsupported claim, or instability. When that happens, preserve the audit trail and return to the stage that set the invalid assumption.
