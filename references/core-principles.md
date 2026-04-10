# Skeptic Core Principles

Use a question-first lifecycle. Do not start from a favorite method. Do not treat predictive workflows as the default template for every project.

This file is the architecture contract for the Skeptic. If any downstream stage file conflicts with this file, this file wins.

## PCS Framework

PCS applies across all question types.

- Predictability: Require a reality check that matches the question and claim. This is not always held-out prediction. It can be refreshed-data replication, external corroboration, resampling, falsification, simulation, or protocol-approved holdout validation. Choose the check in `protocol`.
- Computability: Make every material step executable, documented, and reproducible in code. Record parameters, random seeds, artifacts, and stage outputs. If the workflow cannot be rerun and audited, it does not count.
- Stability: Check whether conclusions survive reasonable perturbations to formulation, protocol, cleaning, examination, analysis-contract choices inside `analyze`, execution choices inside `analyze`, and presentation. If a claim fails under reasonable alternatives, downgrade the claim or return to the stage that created the fragility.
- Documentation: Record the rationale for each judgment call, the plausible alternatives, and the downstream consequences.
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

- `formulate`: Define the domain question, unit of analysis, target quantity, question type, and initial claim boundary.
- `protocol`: Define how the question may be answered. Lock the data usage mode, admissible evidence logic, validation requirements, major prohibitions, and backtracking triggers.
- `clean`: Build an auditable data pipeline consistent with `formulate` and `protocol`. Fix structural and value issues without smuggling in unsupported claims.
- `examine`: Inspect distributions, relationships, structure, anomalies, and candidate patterns to understand what the data can support. This replaces the old `eda` framing.
- `analyze`: Start from the approved question, protocol, cleaned data, and examination findings. Lock one executable analysis contract, then execute only that route.
- `evaluate`: Audit whether outputs and claims survive PCS checks appropriate to the route and protocol.
- `communicate`: Package only the claims that survived evaluation, for the intended audience and use context.

`formulate` defines the question. `protocol` defines how that question may be answered. Every later stage must obey both.

`structure` and `predict` are not core stages. Unsupervised methods belong inside `examine` or a route-specific `analyze` overlay. Predictive work is one route, not the architecture template.

## Execution Modes

Skeptic supports two execution modes:

- `interactive`: the original runtime where the user reviews outputs and decides cycle by cycle
- `auto`: the `/skeptic:auto` runtime defined in `references/auto-mode.md`

Mode-selection rules:

- if `/skeptic:auto` is active, load and follow `references/auto-mode.md`
- if a stage file conflicts with `references/auto-mode.md` about runtime control flow, `references/auto-mode.md` wins
- stage files still define what each stage must check, log, and protect

Auto mode keeps the same rigor:

- every checklist item still must be answered
- every gate still must be evaluated
- route files still narrow behavior
- PCS and integrity reviews still run
- backtracking still must be logged and preserved

## Configuration

Treat this skill as repo-portable.

- Do not depend on absolute paths, usernames, machine-specific folders, or personal workspace conventions.
- Prefer a repo-local `skeptic.yaml` file in the skill or project root.
- If `skeptic.yaml` is absent but `skeptic.yaml.example` exists, copy it to `skeptic.yaml` and use it. This gives the user a local config they can edit without affecting the tracked example file.
- If neither `skeptic.yaml` nor `skeptic.yaml.example` exists, use these defaults:
  - `projects_root`: `~/skeptic-projects`
  - `data_dir_name`: `data`
  - `docs_dir_name`: `skeptic_documentation`
  - `notebooks_dir_name`: `notebooks`
  - `readme_name`: `README.md`
  - `notebook_runner`: `jupyter nbconvert --execute --inplace --to notebook --ExecutePreprocessor.timeout=300 --ExecutePreprocessor.allow_errors=true`
  - `subagent_model`: `sonnet`
- Interpret any legacy project-root example as illustrative, not as a hard requirement.
- When the project uses local files, copy portable raw inputs into the configured data directory.
- When the project uses a database, query engine, or remote source, record only portable source metadata and non-secret access instructions in project artifacts. Never store secrets in tracked files.

## Role of Protocol

`protocol` decides the project rules of the game before `clean` and `examine`.

- Decide the data usage mode: full data, frozen holdout splits, rolling validation, group-based validation, external validation, resampling only, or another justified pattern.
- Decide what counts as leakage.
- Decide whether confounding, identification, sampling design, measurement error, or interference materially constrain the project.
- Decide what validation is required for the allowed claims.
- Decide what downstream stages must not do.
- Freeze the claim boundary: what kinds of claims are allowed, what kinds are forbidden, and what evidence would force backtracking.

Typical `protocol` outputs include:

- the confirmed question type and route family
- the data usage plan and any required frozen artifacts
- leakage rules and forbidden variables
- confounding and identification relevance
- validation and uncertainty requirements
- explicit stage prohibitions
- backtracking triggers

`protocol` sets data-usage, evidence, and claim rules. It does not choose the exact analysis specification. That is locked at the start of `analyze`.

Do not let `clean`, `examine`, or `analyze` silently invent these rules later.

## Question Type Constraints

Route files must honor these constraints. `analyze` may narrow them when locking the executable contract. It may not widen them.

### Descriptive

- Primary objective: characterize what is present in a defined dataset or monitoring frame.
- Admissible evidence pattern: counts, rates, distributions, cross-tabs, standardized summaries, descriptive graphics, and audited denominators.
- Interpretation boundary: describe observed data or an explicitly defined reporting frame. Do not claim explanation, forecast, or causal effect.
- Typical validation logic: coverage checks, denominator integrity, measurement fidelity, sensitivity to subgroup and aggregation choices, reproducibility on refreshed extracts when available.
- Core risks: denominator errors, hidden filtering, misleading summaries, and explanation smuggled into description.

### Exploratory

- Primary objective: surface candidate patterns, structures, hypotheses, or anomalies worth later confirmation.
- Admissible evidence pattern: open-ended visualization, subgroup discovery, clustering, dimensionality reduction, contrastive summaries, anomaly review, and other pattern-search tools.
- Interpretation boundary: hypothesis-generating only. Do not present exploratory patterns as confirmed conclusions.
- Typical validation logic: perturbation checks across samples, parameters, algorithms, and visual encodings; triangulation with external context when relevant.
- Core risks: data snooping, cherry-picking, unstable clusters, overreading artifacts, and converting exploration into evidence.

### Inferential

- Primary objective: estimate a population quantity or relationship with uncertainty.
- Admissible evidence pattern: estimators tied to a sampling or modeling frame, interval estimates, tests, model-based uncertainty, weighting, and design-aware adjustments.
- Interpretation boundary: generalize only to the defined target population under stated assumptions. Do not use causal language unless the route is causal.
- Typical validation logic: sampling and design checks, assumption diagnostics, uncertainty calibration, and sensitivity to specification or weighting choices.
- Core risks: representativeness failure, ignored dependence, model misspecification, selection bias, and overconfident uncertainty.

### Predictive

- Primary objective: predict unseen outcomes, rankings, probabilities, classifications, or forecasts for a defined deployment setting.
- Admissible evidence pattern: supervised learning or forecasting methods, predeclared targets and horizons, scoring rules, calibration, and protocol-approved unseen-data validation.
- Interpretation boundary: claim predictive performance only. Do not infer causes from predictors, coefficients, or feature importance alone.
- Typical validation logic: holdout, rolling-origin validation, group split, cross-validation, external validation, calibration checks, and drift-aware error analysis as required by `protocol`.
- Core risks: leakage, optimistic validation, target drift, proxy targets, threshold gaming, and causal language attached to predictive variables.

### Causal

- Primary objective: estimate the effect of an intervention, exposure, or policy on an outcome.
- Admissible evidence pattern: randomized designs or defensible observational identification strategies, explicit estimands, treatment and outcome timing, confounder strategy, overlap assessment, and sensitivity analysis.
- Interpretation boundary: make causal claims only within the identification assumptions, estimand, population, and treatment variation actually justified.
- Typical validation logic: design diagnostics, balance checks where relevant, placebo or falsification tests, overlap checks, and sensitivity to unmeasured confounding or alternative specifications.
- Core risks: hidden confounding, post-treatment adjustment, positivity violations, interference, bad controls, and unsupported causal language.

### Mechanistic

- Primary objective: explain or simulate the process that generates observed behavior through a structured model of the system.
- Admissible evidence pattern: structural or domain models, governing equations, state-space or simulator-based approaches, parameter calibration, and comparison to observed patterns and domain constraints.
- Interpretation boundary: claim mechanism only to the extent the structural assumptions, calibration targets, and domain knowledge are defended. Good fit alone is not enough.
- Typical validation logic: identifiability checks, simulation-based validation, boundary-condition checks, sensitivity to structural assumptions, and out-of-regime failure analysis.
- Core risks: unidentifiable parameters, multiple models fitting equally well, overfitting through flexible structure, narrative plausibility mistaken for evidence, and failure to falsify the mechanism.

## Stage-Core Plus Stage-Specific Route File

Every post-`formulate` stage follows the same runtime pattern:

1. Read the required upstream stage outputs.
2. Resolve exactly one active route from those upstream artifacts.
3. Load exactly one stage-specific route file:
   - `references/routes/{route}/protocol.md`
   - `references/routes/{route}/clean.md`
   - `references/routes/{route}/examine.md`
   - `references/routes/{route}/analyze.md` when that stage file exists
4. Keep that route context in memory for the rest of the stage and reuse it across cycles in the same chat.
5. If route context becomes ambiguous mid-stage, reread the upstream artifacts and the same route file before proceeding.
6. If the active route cannot be resolved or the expected route file is missing, stop. Do not improvise around missing routing architecture.

Stage-core files contain universal workflow machinery:

- stage purpose
- required inputs and outputs
- artifact names and numbering
- documentation duties
- reproducibility rules
- PCS checkpoints
- generic backtracking rules

Stage-specific route files contain stage-specific narrowing:

- what the stage protects
- what the stage prohibits
- what the stage defers
- what triggers backtracking in that stage

Route files may narrow the stage-core. They may not override reproducibility rules or widen the claim boundary.

Keep route handling memory-first. Do not add notebook or stage-document scaffolding just to carry route context.

## Determinism Mechanisms

Three patterns every stage file must follow. These are part of the architecture contract.

### 1. Question Checklists

Every cycle in every stage replaces prose notebook-cell instructions with a Checklist table:

```
| id | question | skip_when |
|----|----------|-----------|
| A01 | {question text} | {condition or "never"} |
```

Rules:

- IDs use format `{CycleLetter}{TwoDigitNumber}` (A01, A02, B01, etc.)
- Claude writes whatever code fits the dataset, but must answer every checklist item in order
- Items may not be skipped unless `skip_when` condition is satisfied
- Every item must produce a visible output in the notebook (table, print statement, or markdown cell)
- If a question cannot be answered, the notebook cell must state why and what is missing
- The Gate Condition Registry gains a `depends_on` column linking each gate to checklist item IDs
- If a depended-on checklist item was not answered, the gate auto-fails without judgment
- The evaluation subagent must verify all checklist items were answered before evaluating gate conditions

### 2. Decision Matrix

Every Step 4 (Decision) in every stage uses a two-row matrix based on `blocking_failures` (count of blocking defects + blocking gate failures from the evaluation subagent):

```
| blocking_failures | forward actions allowed |
|-------------------|------------------------|
| 0                 | pass, iterate          |
| > 0               | iterate, acknowledge gap (with written justification) |
```

Rules:

- Backward actions are always available regardless of `blocking_failures`: reopen relevant upstream stages (each stage file specifies which), archive
- User override is always available: user states the specific reason the FAIL is incorrect, logged as `override: {reason}`, forward actions unlock
- The stage presents only the allowed forward actions plus the universal options
- Diagnostic gates (explicitly marked as such in the gate registry) do not count toward `blocking_failures`

### 3. Computed Scorecards

Every stage's finalization phase produces a scorecard as a table of numbers computed from stage artifacts. No prose assessments in the scorecard. Interpretation belongs in the PCS Assessment section.

Rules:

- Every scorecard metric must cite its source (which phase, file, or log it was computed from)
- Format: `| metric | value | source |`
- Common metrics across all stages: checklist items answered, mandatory cycles completed, blocking failures total, blocking failures resolved by iteration, blocking failures resolved by override
- Stage-specific metrics are added per stage file

## Project Folder Structure

Every project lives under the configured `projects_root`:

```text
projects_root/
  project-name/
    data_dir_name/               # Raw inputs and codebooks. Never modify.
      splits/                    # Optional. Create only if protocol requires frozen partitions.
    deliverables/                # Audience-facing outputs rendered by communicate.
    docs_dir_name/
      01_formulation.md
      02_protocol.md
      03_cleaning.md
      04_examination.md
      05_analysis.md
      06_evaluation.md
      07_communication.md
      metrics.md
    notebooks_dir_name/
      01_formulation.ipynb
      02_protocol.ipynb
      03_cleaning.ipynb
      04_examination.ipynb
      05_analysis.ipynb
      06_evaluation.ipynb
      07_communication.ipynb
      *.py
      *.json
    readme_name
```

Rules:

- Keep raw files in the configured data directory unchanged.
- Treat the raw source format as the canonical source throughout the full lifecycle.
- Treat split artifacts as conditional, not universal. Do not assume train, validation, and test files exist for every project.
- If `protocol` chooses full-data analysis, rolling windows, external validation, cross-validation folds, or another pattern, create only the artifacts that plan requires and document them in `02_protocol.md`.
- Rebuild derived data from raw inputs plus protocol-defined frozen artifacts. Do not rely on hand-edited intermediate CSVs.

## Universal Rules

- Never modify raw files in the configured data directory.
- Express every material transformation in code.
- Record every judgment call with rationale and plausible alternatives.
- Respect protocol-defined data visibility. If a partition or holdout is restricted, do not touch it outside the stages and purposes allowed by `protocol`.
- Do not change question type or claim class midstream without reopening `formulate` and `protocol`.
- Keep one stage document per completed stage in the configured documentation directory.
- Re-run from raw data plus protocol-defined frozen artifacts, not from ad hoc saved intermediates.
- Record random seeds when stochastic procedures matter.
- Preserve an audit trail when backtracking. Mark superseded work; do not erase it.

## README Update Rules

After each completed stage, update `README.md` with:

- stage name and completion status
- one-line summary of the key decision or outcome
- current question type and route, if they changed or were fixed at that stage
- next stage

`protocol` must explicitly record the data usage mode, validation logic, and major prohibitions. If a stage is reopened, mark the earlier summary as superseded instead of silently rewriting history.

## Notebook Conventions

- Use one primary notebook per stage, numbered in stage order.
- First cell: stage title, date, project name, purpose, active question type, and upstream dependencies.
- Put markdown reasoning before the code it justifies.
- Keep code cells atomic and rerunnable.
- Print or display critical outputs explicitly.
- Make notebooks runnable from raw data plus protocol-defined artifacts, not hidden session state.
- Put reusable functions, constraints, and configuration in companion `.py` or `.json` files when they must survive across stages.
- Use only ASCII characters in notebook cell content. Use `--` instead of em dashes, straight quotes instead of curly quotes, and plain hyphens instead of en dashes. Non-ASCII punctuation causes mojibake on Windows (e.g., `—` renders as `â€"`).

## Notebook Execution

After writing cells with `NotebookEdit`, Claude executes the notebook automatically. Use the `notebook_runner` value from `skeptic.yaml` when present. Otherwise use:

```text
Bash(jupyter nbconvert --execute --inplace --to notebook --ExecutePreprocessor.timeout=300 --ExecutePreprocessor.allow_errors=true <notebook_path>)
```

Then Claude reads the notebook to extract outputs and presents key results inline.

- interactive mode: the user reviews outputs and provides feedback before subagents are dispatched
- auto mode: follow the self-review loop in `references/auto-mode.md` and pause only on required escalation triggers or required human-input checkpoints

If execution fails entirely (kernel not found, Jupyter not installed), Claude reports the error and falls back to asking the user to run the cells manually.

## Backtracking Principle

Later stages may force a return to earlier stages. Backtrack when any of the following is discovered:

- route mismatch: the planned method or claim exceeds the approved question type or the analysis contract locked inside `analyze`
- protocol mismatch: later work needs data access, validation logic, or assumptions forbidden by `protocol`
- cleaning invalidation: a discovered data problem or cleaning choice materially changes the analyzable population, variables, or admissible claims
- unsupported claims: evaluation shows the claimed interpretation is not licensed by the evidence
- instability: reasonable perturbations change the conclusion enough to alter the allowed claim

When backtracking occurs, preserve the earlier record and mark it as superseded. Do not pretend the earlier stage never happened.

## Auto Mode Preflight and State

Before Stage 1 in auto mode:

- verify the project inputs exist or collect only the missing ones
- verify notebook execution is available or explicitly degraded
- verify the stage and route files are readable
- write a run-state artifact to `{projects_root}/{project-name}/{docs_dir_name}/auto_mode_state.json`

Update the run-state artifact after every auto-mode cycle decision, escalation, backtrack, and stage approval.

## Dependency Notes

- `protocol` is a mandatory dependency for `clean` and `examine`.
- `analyze` depends on `formulate`, `protocol`, `clean`, `examine`, and the active route file for `analyze`.
- `evaluate` audits `analyze` against the commitments made in `protocol` and the analysis contract locked inside `analyze`.
- `communicate` may only package claims that survived `evaluate`.
