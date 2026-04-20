# Skeptic Core Principles

Use a question-first lifecycle. Do not start from a favorite method. Do not
treat predictive workflows as the default template for every project.

This file is the architecture contract for Skeptic. If any downstream stage
file conflicts with this file, this file wins.

## PCS Framework

PCS applies across all question types.

- Predictability: require a reality check that matches the question and claim.
  This is not always held-out prediction. It can be refreshed-data replication,
  external corroboration, resampling, falsification, simulation, or a
  protocol-approved holdout.
- Computability: make every material step executable, documented, and
  reproducible in code. Record parameters, random seeds, artifacts, and stage
  outputs.
- Stability: check whether conclusions survive reasonable perturbations to
  formulation, protocol, cleaning, examination, analysis-contract choices,
  execution choices, and presentation.
- Documentation: record the rationale for each judgment call, plausible
  alternatives, and downstream consequences.
- PCS is continuous. Do not treat it as an end-stage checklist.

## Architecture Overview

Stage order is fixed:

1. `formulate`
2. `protocol`
3. `clean`
4. `examine`
5. `analyze`
6. `evaluate`
7. `communicate`

Stage purposes:

- `formulate`: define the domain question, unit of analysis, target quantity,
  question type, and initial claim boundary.
- `protocol`: define how the question may be answered. Lock data-usage mode,
  admissible evidence logic, validation requirements, major prohibitions, and
  backtracking triggers.
- `clean`: build an auditable data pipeline consistent with `formulate` and
  `protocol`. Fix structural and value issues without smuggling in unsupported
  claims.
- `examine`: inspect distributions, relationships, structure, anomalies, and
  candidate patterns to understand what the data can support.
- `analyze`: start from the approved question, protocol, cleaned data, and
  examination findings. Lock one executable analysis contract, then execute only
  that route.
- `evaluate`: audit whether outputs and claims survive PCS checks appropriate to
  the route and protocol.
- `communicate`: package only the claims that survived evaluation, for the
  intended audience and use context.

`formulate` defines the question. `protocol` defines how that question may be
answered. Every later stage must obey both.

`structure` and `predict` are not core stages. Unsupervised methods belong
inside `examine` or a route-specific `analyze` overlay. Predictive work is one
route, not the architecture template.

## Execution Modes

Skeptic supports two execution modes:

- `interactive`: the user reviews outputs and decides cycle by cycle
- `auto`: the `/skeptic:auto` runtime defined in `references/auto-mode.md`

Mode-selection rules:

- if `/skeptic:auto` is active, load and follow `references/auto-mode.md`
- if a stage file conflicts with `references/auto-mode.md` about runtime
  control flow, `references/auto-mode.md` wins
- stage files still define what each stage must check, log, and protect

Auto mode keeps the same rigor:

- every checklist item still must be answered
- every gate still must be evaluated
- route files still narrow behavior
- PCS and integrity reviews still run
- backtracking still must be logged and preserved

## Configuration

Treat this skill as repo-portable.

- Do not depend on absolute paths, usernames, machine-specific folders, or
  personal workspace conventions.
- Prefer a repo-local `skeptic.yaml` file in the skill or project root.
- If `skeptic.yaml` is absent, use these defaults:
  - `projects_root`: `~/skeptic-projects`
  - `data_dir_name`: `data`
  - `docs_dir_name`: `skeptic_documentation`
  - `readme_name`: `README.md`
  - `subagent_model`: `sonnet`
- Interpret any legacy project-root example as illustrative, not as a hard
  requirement.
- When the project uses local files, copy portable raw inputs into the
  configured data directory.
- When the project uses a database, query engine, or remote source, record only
  portable source metadata and non-secret access instructions in project
  artifacts. Never store secrets in tracked files.

## Role of Protocol

`protocol` decides the project rules of the game before `clean` and `examine`.

- decide the data-usage mode
- decide what counts as leakage
- decide whether confounding, identification, sampling design, measurement
  error, grouping, time order, or interference materially constrain the project
- decide what validation is required for the allowed claims
- decide what downstream stages must not do
- freeze the claim boundary

`protocol` sets data-usage, evidence, and claim rules. It does not choose the
exact analysis specification. That is locked at the start of `analyze`.

Do not let `clean`, `examine`, or `analyze` silently invent these rules later.

## Question Type Constraints

Route files must honor these constraints. `analyze` may narrow them when
locking the executable contract. It may not widen them.

### Descriptive

- Objective: characterize what is present in a defined dataset or monitoring frame.
- Evidence pattern: counts, rates, distributions, cross-tabs, standardized
  summaries, descriptive graphics, audited denominators.
- Boundary: describe observed data or a defined reporting frame. Do not claim
  explanation, forecast, or causal effect.

### Exploratory

- Objective: surface candidate patterns, structures, hypotheses, or anomalies.
- Evidence pattern: open-ended visualization, subgroup discovery, clustering,
  dimensionality reduction, contrastive summaries, anomaly review.
- Boundary: hypothesis-generating only. Do not present exploratory patterns as
  confirmed conclusions.

### Inferential

- Objective: estimate a population quantity or relationship with uncertainty.
- Evidence pattern: estimators tied to a sampling or modeling frame, interval
  estimates, tests, model-based uncertainty, weighting, design-aware
  adjustments.
- Boundary: generalize only to the defined target population under stated
  assumptions. Do not use causal language unless the route is causal.

### Predictive

- Objective: predict unseen outcomes, rankings, probabilities, classifications,
  or forecasts for a defined deployment setting.
- Evidence pattern: supervised learning or forecasting methods, predeclared
  targets and horizons, scoring rules, calibration, protocol-approved
  unseen-data validation.
- Boundary: claim predictive performance only. Do not infer causes from
  predictors, coefficients, or feature importance alone.

### Causal

- Objective: estimate the effect of an intervention, exposure, or policy.
- Evidence pattern: randomized designs or defensible observational
  identification strategies, explicit estimands, treatment and outcome timing,
  confounder strategy, overlap assessment, sensitivity analysis.
- Boundary: make causal claims only within the identification assumptions,
  estimand, population, and treatment variation actually justified.

### Mechanistic

- Objective: explain or simulate the process that generates observed behavior
  through a structured model of the system.
- Evidence pattern: structural or domain models, governing equations,
  state-space or simulator-based approaches, parameter calibration, comparison
  to observed patterns and domain constraints.
- Boundary: claim mechanism only to the extent the structural assumptions,
  calibration targets, and domain knowledge are defended. Good fit alone is not
  enough.

## Stage Entry Plus Stage-Specific Route File

Every stage follows this runtime pattern:

1. Read the required upstream stage outputs.
2. Resolve exactly one active route from those upstream artifacts when the stage
   is route-aware.
3. Read the lean stage entry file for the active stage.
4. Load exactly one stage-specific route file when the stage requires one.
5. Load one cycle YAML file only when that cycle is about to run.
6. Keep the route context and current-cycle YAML in memory for the rest of the
   current cycle only.
7. If route context becomes ambiguous mid-stage, reread the upstream artifacts
   and the same route file before proceeding.
8. If the active route cannot be resolved or the expected route file is
   missing, stop. Do not improvise around missing routing architecture.

Stage entry files contain universal workflow machinery:

- stage purpose
- required inputs and outputs
- artifact names and numbering
- canonical YAML contract
- documentation duties
- reproducibility rules
- PCS checkpoints
- generic backtracking rules
- cycle file locations
- final artifact list

Stage-specific route files contain stage-specific narrowing:

- what the stage protects
- what the stage prohibits
- what the stage defers
- what triggers backtracking in that stage

Route files may narrow the stage entry. They may not override reproducibility
rules or widen the claim boundary.

## Determinism Mechanisms

Three patterns every stage file must follow.

### 1. Question Checklists

Every cycle replaces prose execution instructions with a Checklist table:

```text
| id | question | skip_when |
|----|----------|-----------|
| A01 | {question text} | {condition or "never"} |
```

Rules:

- IDs use format `{CycleLetter}{TwoDigitNumber}` such as `A01`
- the stage must answer every checklist item in order
- items may not be skipped unless `skip_when` is satisfied
- every item must produce visible, inspectable output in the current cycle
  execution result
- if a question cannot be answered, the execution output must state why and
  what is missing
- the Gate Condition Registry must link each gate to checklist item IDs
- if a depended-on checklist item was not answered, the gate auto-fails
- evaluation must verify checklist coverage before gate judgment

### 2. Decision Matrix

Every cycle decision uses this two-row matrix based on `blocking_failures`
(count of blocking defects plus blocking gate failures):

```text
| blocking_failures | forward actions allowed |
|-------------------|------------------------|
| 0                 | pass, iterate          |
| > 0               | iterate, acknowledge gap (with written justification) |
```

Rules:

- backward actions are always available regardless of `blocking_failures`
- user override is always available and must be logged as `override: {reason}`
- the stage presents only the allowed forward actions plus universal options
- diagnostic gates do not count toward `blocking_failures`

### 3. Computed Metrics

Every stage finalization phase produces a canonical machine-readable metrics
artifact. Human-readable summaries are optional derived renders only.

Rules:

- the canonical metrics artifact is JSON or YAML, not markdown
- every metric must cite its source artifact or log field
- common metrics across all stages: checklist items answered, mandatory cycles
  completed, blocking failures total, blocking failures resolved by iteration,
  blocking failures resolved by override
- stage-specific metrics are added per stage file
- if a human-readable metrics summary exists, render it from the canonical
  metrics artifact. Do not let it become a second source of truth

## Project Folder Structure

Every project lives under the configured `projects_root`:

```text
projects_root/
  project-name/
    data_dir_name/               # Raw inputs and codebooks. Never modify.
      splits/                    # Optional. Create only if protocol requires frozen partitions.
      silver/                    # Optional. Cleaned stage outputs when distinct from raw files.
    deliverables/                # Audience-facing outputs rendered by communicate.
    docs_dir_name/
      01_formulation.py
      01_formulation.yaml
      01_formulation.md
      formulation_metrics.json
      formulation_decision_log.jsonl
      claim_boundary_registry.yaml
      02_protocol.md
      03_cleaning.md
      04_examination.md
      05_analysis.md
      06_evaluation.md
      07_communication.md
    readme_name
```

Rules:

- keep raw files in the configured data directory unchanged
- treat the raw source format as the canonical source throughout the full lifecycle
- treat split artifacts as conditional, not universal
- if `protocol` chooses full-data analysis, rolling windows, external
  validation, cross-validation folds, or another pattern, create only the
  artifacts that plan requires and document them in `02_protocol.md`
- if `clean` produces cleaned outputs as distinct files, store them in
  `data_dir_name/silver/` with a `README.md` documenting each artifact
- rebuild derived data from raw inputs plus protocol-defined frozen artifacts
- keep stage-local Python scripts inside the project folder

## Universal Rules

- never modify raw files in the configured data directory
- express every material transformation in code
- record every judgment call with rationale and plausible alternatives
- respect protocol-defined data visibility
- do not change question type or claim class midstream without reopening
  `formulate` and `protocol`
- keep one canonical YAML contract per stage when the stage file requires it
- rerun from raw data plus protocol-defined frozen artifacts, not from ad hoc
  saved intermediates
- record random seeds when stochastic procedures matter
- preserve an audit trail when backtracking. Mark superseded work. Do not erase it
- generated project documents and helper artifacts must reference real project
  files
- README summaries must be derived from the actual project filesystem state

## README Update Rules

After each completed stage, update `README.md` with:

- stage name and completion status
- one-line summary of the key decision or outcome
- current question type and route if they changed or were fixed at that stage
- next stage

`protocol` must explicitly record the data-usage mode, validation logic, and
major prohibitions. If a stage is reopened, mark the earlier summary as
superseded instead of silently rewriting history.

## Execution Conventions

- use one primary Python script per stage when the stage file requires it
- put one cycle function in that script for each mandatory cycle
- run one cycle at a time with an explicit CLI argument such as `--cycle A`
- make stage scripts rerunnable from raw data plus protocol-defined artifacts,
  not hidden session state
- emit structured outputs for each cycle
- put reusable functions, constraints, and configuration in companion `.py`,
  `.json`, or `.yaml` files only when they materially reduce duplication
- use ASCII by default in generated execution artifacts

## Source Data Encoding

Before loading any source data file for the first time, detect its encoding:

- try UTF-8 strict mode first
- if UTF-8 fails, check for a BOM that indicates UTF-16 or UTF-8-BOM
- if no BOM and UTF-8 fails, attempt Latin-1 or Windows-1252 as a fallback
- record the detected encoding for each source file in canonical stage artifacts
- all downstream reads of that file must use the detected encoding explicitly
- if the source contains non-ASCII text, verify that the loaded values display
  correctly in the cycle execution output before proceeding

Encoding detection is mandatory for CSV, TSV, and other text-based data files.
Binary formats such as Parquet, HDF5, and SQLite do not need this check.

## Generated Artifact Encoding

The Windows mojibake risk applies to generated project artifacts, not just
script output.

Rules:

- use ASCII by default for generated `.md`, `.json`, `.yaml`, `.yml`, and `.py` files
- if non-ASCII text must be preserved, keep it deliberate and localized
- do not introduce typographic punctuation such as em dashes, curly quotes, or
  en dashes in generated artifacts
- before stage finalization, scan generated `.md`, `.json`, `.yaml`, `.yml`,
  and `.py` files touched in the stage for mojibake markers and unintended
  non-ASCII punctuation
- treat mojibake in tracked project artifacts as a blocking defect for stage closure

## Stage Script Execution

After writing or updating the stage script, execute only the current cycle.
Example:

```text
python 01_formulation.py --cycle A
```

Then read the structured output, validate required keys, and update canonical
YAML and metrics artifacts.

After execution, scan the current cycle output for Python exceptions, malformed
JSON, missing checklist answers, or missing gate evidence. Any unhandled
exception or malformed structured output is a blocking defect that must be
fixed before subagent review.

- interactive mode: the user reviews outputs and provides feedback before
  subagents are dispatched
- auto mode: follow the self-review loop in `references/auto-mode.md` and pause
  only on required escalation triggers or human-input checkpoints

If execution fails entirely, report the error and repair the stage script
before continuing.

## Backtracking Principle

Later stages may force a return to earlier stages. Backtrack when any of the
following is discovered:

- route mismatch
- protocol mismatch
- cleaning invalidation
- unsupported claims
- instability

When backtracking occurs, preserve the earlier record and mark it as
superseded. Do not pretend the earlier stage never happened.

## Auto Mode Preflight and State

Before Stage 1 in auto mode:

- verify the project inputs exist or collect only the missing ones
- verify Python execution for project-side stage scripts is available
- verify the stage and route files are readable
- write a run-state artifact to
  `{projects_root}/{project-name}/{docs_dir_name}/auto_mode_state.json`

Update the run-state artifact after every auto-mode cycle decision, escalation,
backtrack, and stage approval.

## Dependency Notes

- `protocol` is a mandatory dependency for `clean` and `examine`
- `analyze` depends on `formulate`, `protocol`, `clean`, `examine`, and the
  active route file for `analyze`
- `evaluate` audits `analyze` against the commitments made in `protocol` and
  the analysis contract locked inside `analyze`
- `communicate` may only package claims that survived `evaluate`
