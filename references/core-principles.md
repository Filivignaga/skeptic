# Skeptic Core Principles

Use a question-first lifecycle. Do not start from a favorite method. Do not treat predictive workflows as the default template for every project.

This file is the architecture contract for Skeptic. If any downstream stage file conflicts with this file, this file wins.

## PCS Framework

PCS applies across all question types.

- Predictability: require a reality check that matches the question and claim. This is not always held-out prediction. It can be refreshed-data replication, external corroboration, resampling, falsification, simulation, or protocol-approved holdout validation. Choose the check in `protocol`.
- Computability: make every material step executable, documented, and reproducible in code. Record parameters, random seeds, artifacts, and stage outputs. If the workflow cannot be rerun and audited, it does not count.
- Stability: check whether conclusions survive reasonable perturbations to formulation, protocol, cleaning, examination, analysis-contract choices inside `analyze`, execution choices inside `analyze`, and presentation. If a claim fails under reasonable alternatives, downgrade the claim or return to the stage that created the fragility.
- Documentation: record the rationale for each judgment call, the plausible alternatives, and the downstream consequences. Documentation lives inside the canonical stage YAML, not in side notes.
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

- `formulate`: define the domain question, unit of analysis, target quantity, question type, and initial claim boundary.
- `protocol`: define how the question may be answered. Lock the data-usage mode, admissible evidence logic, validation requirements, major prohibitions, and backtracking triggers.
- `clean`: build an auditable data pipeline consistent with `formulate` and `protocol`. Fix structural and value issues without smuggling in unsupported claims.
- `examine`: inspect distributions, relationships, structure, anomalies, and candidate patterns to understand what the data can support.
- `analyze`: start from the approved question, protocol, cleaned data, and examination findings. Lock one executable analysis contract, then execute only that route.
- `evaluate`: audit whether outputs and claims survive PCS checks appropriate to the route and protocol.
- `communicate`: package only the claims that survived evaluation, for the intended audience and use context.

`formulate` defines the question. `protocol` defines how that question may be answered. Every later stage must obey both.

`structure` and `predict` are not core stages. Unsupervised methods belong inside `examine` or a route-specific `analyze` overlay. Predictive work is one route, not the architecture template.

## Canonical Artifact Model

Every stage produces a compact, fixed artifact set. No notebooks. No stage-wide metrics file. No separate claim-boundary registry file. Compact metrics, gate state, narrowing history, and cycle history live inside the canonical YAML.

| Artifact | Role |
|----------|------|
| `{docs_dir_name}/{NN}_{stage}.yaml` | Canonical stage memory. Contract, state, claim boundary, protocol handoff, cycle history, PCS review. Created at stage start. Updated at the end of every cycle. Single source of truth for the stage. |
| `{scripts_dir_name}/{NN}_{stage}.py` | Project-side analysis script. One function per cycle. Invoked one cycle at a time: `python {NN}_{stage}.py --cycle X`. Returns a JSON evidence packet on stdout. The script never writes the canonical YAML. Only the model writes the canonical YAML. |
| `{docs_dir_name}/{NN}_{stage}.md` | Human-readable report. Rendered once at stage close from the canonical YAML. Derived, not canonical. |
| `{readme_name}` | Short stage-status block added at each stage close. |

If the rendered markdown disagrees with the canonical YAML, the YAML wins.

Stage numbering follows stage order: `01_formulation`, `02_protocol`, `03_cleaning`, `04_examination`, `05_analysis`, `06_evaluation`, `07_communication`.

## Execution Modes

Skeptic supports two execution modes:

- `interactive`: the user reviews outputs and decides cycle by cycle.
- `auto`: the `/skeptic:auto` runtime defined in `references/auto-mode.md`.

Mode-selection rules:

- if `/skeptic:auto` is active, load and follow `references/auto-mode.md`.
- if a stage file conflicts with `references/auto-mode.md` on runtime control flow, `references/auto-mode.md` wins.
- stage files still define what each stage must check, log, and protect.

Auto mode keeps the same rigor:

- every checklist item still must be answered.
- every gate still must be evaluated.
- route files still narrow behavior.
- PCS and integrity reviews still run.
- backtracking still must be logged and preserved.

## Configuration

Treat this skill as repo-portable.

- Do not depend on absolute paths, usernames, machine-specific folders, or personal workspace conventions.
- Prefer a repo-local `skeptic.yaml` file in the skill or project root.
- If `skeptic.yaml` is absent, use these defaults:
  - `projects_root`: `~/skeptic-projects`
  - `data_dir_name`: `data`
  - `docs_dir_name`: `skeptic_documentation`
  - `scripts_dir_name`: `scripts`
  - `readme_name`: `README.md`
  - `subagent_model`: `sonnet`
- When the project uses local files, copy portable raw inputs into the configured data directory.
- When the project uses a database, query engine, or remote source, record only portable source metadata and non-secret access instructions in project artifacts. Never store secrets in tracked files.

## Stage Files

Every stage follows the same skill-side surface.

1. One lean stage-entry markdown at `references/{stage}/{stage}.md`.
2. One per-cycle YAML at `references/{stage}/cycles/{cycle}.yaml` for each cycle that stage defines.
3. Optional stage-local reference files (for example `data-formats.md` under `references/formulate/`).

Each stage-entry file carries:

- stage purpose and required inputs/outputs
- the canonical YAML schema for the stage
- the shared cycle protocol
- stage-close finalization rules
- dependency notes

Each per-cycle YAML carries:

- `upstream`: canonical-YAML fields that must be set before the cycle runs
- `setup_side_effects`: one-time actions (typically for the first cycle only)
- `checklist`: the items the cycle must answer. Each item carries `id`, `question`, `evidence_key` (script output key, or `null` if judgment-driven), `writes_to` (canonical-YAML field or list of fields, or `null`), and optionally `skip_when` (absent means "never skip")
- `gates`: verifiable conditions. Single-dep gates encode the dep in the ID (e.g. `A01-loadable`); multi-dep gates use a short ID plus `depends_on`
- `research_questions`: topics for the research subagent
- `guidance`: short, cycle-specific judgment rules
- `step4_additions`, `pcs_checkpoint`, `log_extension`: present only when the cycle adds a specific discipline

### Load Pattern

The model reads the stage-entry markdown once at stage start. Per-cycle YAMLs are loaded one at a time as each cycle runs. Do not re-read the stage entry between cycles.

Read the canonical stage YAML only on first entry to the stage (new chat session, or reopen after a backtrack). Within a continuous session, the model just wrote the canonical YAML -- its content is already in context. Re-reading it between cycles in the same session is waste.

## Role of Protocol

`protocol` decides the project rules of the game before `clean` and `examine`.

- Decide the data-usage mode: full data, frozen holdout splits, rolling validation, group-based validation, external validation, resampling only, or another justified pattern.
- Decide what counts as leakage.
- Decide whether confounding, identification, sampling design, measurement error, or interference materially constrain the project.
- Decide what validation is required for the allowed claims.
- Decide what downstream stages must not do.
- Freeze the claim boundary: what kinds of claims are allowed, what kinds are forbidden, and what evidence would force backtracking.

Typical `protocol` outputs (written into `02_protocol.yaml`) include:

- the confirmed question type and route family
- the data-usage plan and any required frozen artifacts
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

1. Read the required upstream canonical YAMLs.
2. Resolve exactly one active route from those YAMLs.
3. Load exactly one stage-specific route file:
   - `references/routes/{route}/protocol.md`
   - `references/routes/{route}/clean.md`
   - `references/routes/{route}/examine.md`
   - `references/routes/{route}/analyze.md` when that stage file exists
4. Keep the route context in memory across cycles in the same chat.
5. If route context becomes ambiguous mid-stage, reread upstream YAMLs and the same route file before proceeding.
6. If the active route cannot be resolved or the expected route file is missing, stop. Do not improvise around missing routing architecture.

Route files may narrow the stage-core. They may not override reproducibility rules or widen the claim boundary.

## Determinism Mechanisms

Two patterns every stage must follow.

### 1. Per-cycle Checklists and Gates

Every cycle is specified by a cycle YAML under `references/{stage}/cycles/{cycle}.yaml`. That file defines the checklist, gates, research questions, and guidance for that cycle.

Rules:

- Checklist IDs use the format `{CycleLetter}{TwoDigitNumber}` (A01, A02, B01, ...).
- Each checklist item carries `evidence_key` (the JSON key the script must produce for this item, or `null` if judgment-driven) and `writes_to` (the canonical-YAML field or list of fields the answer populates, or `null` if the item only feeds gates).
- Every item must be answered for a cycle to pass. Unanswered items feed `blocking_failures` directly; there is no 1:1 "was this answered" gate. Gates exist only for checks stricter than "the item was answered."
- Gates depend on one or more checklist items. Single-dep gates encode the dep in the gate ID (e.g. `A01-loadable` depends on A01). Multi-dep gates use a short ID plus an explicit `depends_on: [ID1, ID2, ...]` field. If any depended-on item was not answered, the gate auto-fails without judgment.
- The evaluation subagent lists the unanswered items, the blocking defects, and the failed gates. The model sums the three counts into `blocking_failures`.
- Items may not be skipped unless a `skip_when` condition is present and satisfied. Absent `skip_when` means "never skip."
- Every gate is binary: PASS or FAIL. If a project needs to proceed with a bounded risk, use `override: {reason, gate}` rather than a soft-fail concept.

### 2. Decision Matrix

Every Step 4 (Decision) in every stage uses a two-row matrix based on `blocking_failures` (unanswered checklist items + blocking defects + failed gates from the evaluation subagent):

| blocking_failures | forward actions allowed |
|-------------------|------------------------|
| 0                 | pass, iterate          |
| > 0               | iterate, acknowledge gap (with written justification) |

Rules:

- Backward actions are always available regardless of `blocking_failures`: reopen relevant upstream stages (each stage file specifies which), archive.
- User override is always available: user states the specific reason the FAIL is incorrect, logged as `override: {reason, gate}`, forward actions unlock.
- The stage presents only the allowed forward actions plus the universal options.

## Project Folder Structure

Every project lives under the configured `projects_root`:

```text
projects_root/
  project-name/
    data_dir_name/             # Raw inputs and codebooks. Never modify.
      silver/                  # Optional. Cleaned stage outputs when distinct from raw files.
      splits/                  # Optional. Create only if protocol mandates frozen partitions.
    deliverables/              # Audience-facing outputs rendered by communicate.
                               # Must contain exactly one primary deliverable and zero or more
                               # companion data files. See communicate for naming rules.
    docs_dir_name/
      01_formulation.yaml      # Canonical stage memory.
      01_formulation.md        # Final rendered report.
      02_protocol.yaml
      02_protocol.md
      03_cleaning.yaml
      03_cleaning.md
      04_examination.yaml
      04_examination.md
      05_analysis.yaml
      05_analysis.md
      06_evaluation.yaml
      06_evaluation.md
      07_communication.yaml
      07_communication.md
      auto_mode_state.json     # Only when auto mode is used.
    scripts_dir_name/
      01_formulation.py        # One function per cycle; invoked one cycle at a time.
      02_protocol.py
      03_cleaning.py
      04_examination.py
      05_analysis.py
      06_evaluation.py
      07_communication.py
      *.json                   # Optional companion artifacts shared across cycles.
    readme_name
```

Rules:

- Keep raw files in the configured data directory unchanged.
- Treat the raw source format as the canonical source throughout the lifecycle.
- Treat split artifacts as conditional, not universal. Do not assume train, validation, and test files exist for every project.
- If `protocol` chooses full-data analysis, rolling windows, external validation, cross-validation folds, or another pattern, create only the artifacts that plan requires and record them inside `02_protocol.yaml`.
- If `clean` produces cleaned outputs as distinct files (not modifying raw data), store them in `data_dir_name/silver/` with a `README.md` documenting each artifact, its schema, and known limitations.
- Rebuild derived data from raw inputs plus protocol-defined frozen artifacts. Do not rely on hand-edited intermediate files.

## Stage Script Rules

Each stage may produce a project-side Python script at `scripts_dir_name/{NN}_{stage}.py`.

Rules:

- One file per stage, containing one function per cycle (`run_cycle_a`, `run_cycle_b`, ...).
- CLI contract: `python {NN}_{stage}.py --cycle {cycle}`. Only the requested cycle runs.
- Each function returns a dict. `main()` prints exactly one JSON object to stdout. Nothing else on stdout.
- The script reads the canonical stage YAML to find data paths and prior decisions. It does not write the canonical YAML; only the model writes the canonical YAML.
- Heavy data (full DataFrames, long arrays) is summarized, not dumped. Evidence packets stay compact.
- Seeds are set inside the function whenever stochastic steps run, and the seed value is echoed into the evidence packet.
- After script execution, scan stdout and stderr for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing, unless the function body explicitly marks an expected failure with a `# expected_failure` comment.

## Universal Rules

- Never modify raw files in the configured data directory.
- Express every material transformation in code.
- Record every judgment call with rationale and plausible alternatives in the canonical YAML.
- Respect protocol-defined data visibility. If a partition or holdout is restricted, do not touch it outside the stages and purposes `protocol` allows.
- Do not change question type or claim class midstream without reopening `formulate` and `protocol`.
- Keep one canonical YAML plus one rendered markdown per completed stage in the configured documentation directory.
- Re-run from raw data plus protocol-defined frozen artifacts, not from ad hoc saved intermediates.
- Record random seeds when stochastic procedures matter.
- Preserve an audit trail when backtracking. `cycle_history` is append-only; new iterations append to the list. Do not edit past entries.
- Generated project documents must reference real project files. Do not leave stale references to deleted artifacts, placeholder scripts, or personal workspace paths.
- README summaries must be derived from the actual project filesystem state and verified against artifacts on disk, not written from memory.

## Source Data Encoding

Before loading any source data file for the first time (typically in Formulate Cycle A), detect its encoding:

- Try reading with UTF-8 strict first. If it succeeds, the file is UTF-8.
- If UTF-8 fails, check for a BOM (byte order mark) indicating UTF-16 or UTF-8-BOM.
- If no BOM and UTF-8 fails, attempt Latin-1 / Windows-1252 as a fallback. Log the detected encoding.
- Record the detected encoding for each source file in the canonical YAML. All downstream reads must pass the detected encoding explicitly (for example `pd.read_csv(path, encoding='...')`). Do not rely on default encoding inference.
- If the source contains non-ASCII text, verify values display correctly before proceeding.

Encoding detection is mandatory for CSV, TSV, and other text-based data files. Binary formats (Parquet, HDF5, SQLite) handle encoding internally and do not need this check.

## Generated Artifact Encoding

The Windows mojibake risk applies to generated project artifacts.

- Use ASCII by default for generated `.md`, `.json`, `.yaml`, `.yml`, and `.py` files.
- If non-ASCII text must be preserved because it comes from source data, domain terminology, or quoted user-provided content, keep it deliberate and localized. Do not introduce typographic punctuation such as em dashes, curly quotes, or en dashes in generated artifacts.
- Before stage finalization, scan generated `.md`, `.json`, `.yaml`, `.yml`, and `.py` files touched in the stage for mojibake markers and unintended non-ASCII punctuation. This includes files in `deliverables/` -- audience-facing artifacts are the highest-risk location for encoding corruption.
- Treat mojibake in tracked project artifacts as a blocking defect for stage closure until the affected files are rewritten cleanly.

## README Update Rules

After each completed stage, update `README.md` with a short stage block:

- stage name and completion status
- one-line summary of the key decision or outcome
- current question type and route, if they changed or were fixed at that stage
- next stage

`protocol` must explicitly record the data-usage mode, validation logic, and major prohibitions. If a stage is reopened, mark the earlier summary as superseded instead of silently rewriting history.

## Backtracking Principle

Later stages may force a return to earlier stages. Backtrack when any of the following is discovered:

- route mismatch: the planned method or claim exceeds the approved question type or the analysis contract locked inside `analyze`.
- protocol mismatch: later work needs data access, validation logic, or assumptions forbidden by `protocol`.
- cleaning invalidation: a discovered data problem or cleaning choice materially changes the analyzable population, variables, or admissible claims.
- unsupported claims: evaluation shows the claimed interpretation is not licensed by the evidence.
- instability: reasonable perturbations change the conclusion enough to alter the allowed claim.

When backtracking:

- Preserve the earlier record. `cycle_history` entries are append-only.
- Unlock the stage (set `status.locked_at: null`) and re-run the affected cycles.
- Re-render the markdown at the end of the reopen.
- Never erase earlier work. Mark it superseded via the new iteration rather than editing past entries.

## Auto Mode Preflight and State

Before Stage 1 in auto mode:

- verify the project inputs exist or collect only the missing ones.
- verify the stage entry files and route files are readable.
- write a run-state artifact to `{projects_root}/{project-name}/{docs_dir_name}/auto_mode_state.json`.

Update the run-state artifact after every auto-mode cycle decision, escalation, backtrack, and stage approval.

## Dependency Notes

- `protocol` is a mandatory dependency for `clean` and `examine`.
- `analyze` depends on `formulate`, `protocol`, `clean`, `examine`, and the active route file for `analyze`.
- `evaluate` audits `analyze` against the commitments made in `protocol` and the analysis contract locked inside `analyze`.
- `communicate` may only package claims that survived `evaluate`.
