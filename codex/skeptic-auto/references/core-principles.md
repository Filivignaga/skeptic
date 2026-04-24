# Skeptic Core Principles

Use a question-first lifecycle: the question chooses the method. Treat every project as open to any of the six question types, with predictive workflows reserved for questions that target unseen-outcome forecasting.

This file is the architecture contract for Skeptic. If any downstream stage file conflicts with this file, this file wins.

## PCS Framework

PCS applies across all question types.

- Predictability: require a reality check that matches the question and claim. This is not always held-out prediction. It can be refreshed-data replication, external corroboration, resampling, falsification, simulation, or protocol-approved holdout validation. Choose the check in `protocol`.
- Computability: make every material step executable, documented, and reproducible in code. Record parameters, random seeds, artifacts, and stage outputs. If the workflow cannot be rerun and audited, it does not count.
- Stability: check whether conclusions survive reasonable perturbations to formulation, protocol, cleaning, examination, analysis-contract choices inside `analyze`, execution choices inside `analyze`, and presentation. If a claim fails under reasonable alternatives, downgrade the claim or return to the stage that created the fragility.
- Documentation: record the rationale for each judgment call, the plausible alternatives, and the downstream consequences. Documentation lives inside the canonical stage YAML, not in side notes.
- PCS runs continuously across every stage, informing decisions at each one.

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

Every stage produces a compact, fixed artifact set. Only the canonical YAML, stage script, rendered report, README block, and declared deliverables belong to the active artifact contract. Compact metrics, acceptance state, narrowing history, and a compact decision ledger live inside the canonical YAML.

| Artifact | Role |
|----------|------|
| `{docs_dir_name}/{NN}_{stage}.yaml` | Canonical stage memory. Contract, state, claim boundary, protocol handoff, cycle history, PCS review. Created at stage start. Updated at the end of every cycle. Single source of truth for the stage. |
| `{scripts_dir_name}/{NN}_{stage}.py` | Project-side analysis script. One function per cycle. Invoked one cycle at a time: `python {NN}_{stage}.py --cycle X`. Returns a JSON evidence packet on stdout. The script never writes the canonical YAML. Only the model writes the canonical YAML. |
| `{docs_dir_name}/{NN}_{stage}.md` | Human-readable report. Rendered once at stage close from the canonical YAML. Derived, not canonical. |
| `{readme_name}` | Short stage-status block added at each stage close. |

If the rendered markdown disagrees with the canonical YAML, the YAML wins.

Stage numbering follows stage order: `01_formulation`, `02_protocol`, `03_cleaning`, `04_examination`, `05_analysis`, `06_evaluation`, `07_communication`.

## Canonical YAML Discipline

Canonical YAML is the decision record, not a transcript or evidence dump.

- Store upstream context as `upstream_refs` or `upstream_contract`: file path, section names, and hashes. Do not copy upstream fact blocks when a pointer plus hash is enough to detect drift.
- File hashes have one authority. The first registration lives in `provenance.files` or the stage's equivalent provenance registry. Later stages record verification status and a `provenance_ref`, not a second hash value, unless they are checking a frozen derivative artifact.
- Visibility constraints are inherited by reference from `protocol`. Later stages may record `visibility_ref`, `visibility_set_ref`, or a compact allowed/restricted summary needed for execution, but they must not duplicate the protocol visibility block as a second source of truth.
- Batch identical no-op or "retained as-is" decisions when the rationale, alternatives, reversibility, and downstream consequence are identical. Preserve the affected column or artifact list inside the single decision entry.
- `cycle_history[*].script_evidence` is compact: 4-8 one-line bullets, or one line per `evidence_key`. Full stdout is not retained by default; write a debug sidecar only when a cycle fails, is rerun for diagnosis, or the user asks for retained raw evidence.
- `pcs_review` stores compact verdicts, disposition, and open conditions in YAML. A full subagent reply may be written to a sidecar such as `pcs_review.json`; if no `transcript_ref` is present, the compact YAML verdict is the complete record.

`pcs_review` shape:

```yaml
pcs_review:
  verdicts:
    predictability:
    computability:
    stability:
  open_conditions: []
  transcript_ref:
  disposition:
  disposition_reason:
```

## Evidence and Research Logs

Numeric, categorical, and citation claims in canonical YAML must be traceable.

- Canonical YAML prose must not introduce numbers, percentages, counts, dates, thresholds, or categorical sets unless the same entry has `evidence_key`, `evidence_ref`, `research_log#n`, `upstream_ref`, or `computed_by`.
- Use a warning-first YAML evidence-claim lint check. It flags suspicious prose and should allow legitimate IDs, versions, timestamps, and structured provenance fields.
- External research citations live in one append-only `{docs_dir_name}/research_log.jsonl` sidecar only when external sources materially drive a decision or are cited in a deliverable. Canonical YAML references stable IDs such as `research_log#7`.
- Each research log row includes at least `id`, `stage`, `cycle`, `url`, `claim_used`, `verified_at`, and `status`.
- Cycle review findings store research-log pointers only when a source changed a decision, not raw citation strings or long source notes.

## User-Owned Judgment Decisions

In interactive mode, dispatch `AskUserQuestion` before closing any cycle that contains a user-owned judgment decision. If the user has no preference, record `agent_decides` with the evidence shown.

Stage decision classes:

- `formulate`: question type, operationalization, unit of analysis, claim boundary, intended/prohibited uses, material bias severity.
- `protocol`: data usage mode, validation logic, leakage/prohibition policy, backtracking triggers, external standard adoption.
- `clean`: missing-vs-censored policy, irreversible exclusions above materiality threshold, stability thresholds, high-impact perturbation axes.
- `examine`: route-pressure decisions, stop/backtrack choices, analysis-handoff inclusion when patterns are material.
- `analyze`: analysis contract approval, assumption-failure policy, material-difference thresholds, contract amendments.
- `evaluate`: stability verdict thresholds, predictability verdicts, fatal validity threats, claim survival or narrowing decisions.
- `communicate`: audience-action framing, caveat translation, recommendation strength, final deliverable approval.

## Thresholds and Perturbations

Thresholds and expected perturbation effects are not agent inventions.

- Threshold sources must be one of: protocol-derived, data-derived computation, external standard recorded in `research_log.jsonl`, or explicit user approval.
- `evaluate` consumes thresholds from protocol, analyze, or approved evaluation rules. It does not silently invent wider thresholds to pass claims.
- Perturbation scripts should maintain or infer a dependency map so coupled metrics, variables, and claim components are expected to move together. Hand-written expected-movement maps are allowed only when the rationale and source are recorded.

## Subagent Policy

Use inline acceptance checks by default. Add an evaluation subagent only for high-risk cycles, unresolved blocking issues, stage close, or when claims could widen or cross the approved boundary. Add a research subagent only when external domain, methodological, legal, standards, or audience knowledge can change a decision.

Likely research-backed cycles include question/domain framing, protocol standards and prohibitions, cleaning policy choices, route-specific anomaly interpretation, analysis contract selection, assumption policy, sensitivity design, evaluation verdict thresholds, claim survival, and audience/regulatory framing.

Likely evaluator-only cycles include mechanical artifact audits, reproducibility reruns, filesystem presence checks, final assembly checks, pure rendering checks, and README updates. An evaluator may recommend a research-backed follow-up when it finds a knowledge gap.

## Execution Modes

Skeptic supports two execution modes:

- `interactive`: the user reviews outputs and decides cycle by cycle.
- `auto`: the `/skeptic:auto` runtime defined in `references/auto-mode.md`.

Mode-selection rules:

- if `/skeptic:auto` is active, load and follow `references/auto-mode.md`.
- if a stage file conflicts with `references/auto-mode.md` on runtime control flow, `references/auto-mode.md` wins.
- stage files still define what each stage must check, log, and protect.

Auto mode keeps the same rigor:

- every required evidence key still must be produced or explicitly skipped.
- every acceptance criterion still must be evaluated.
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

1. One lean stage-entry markdown at `references/stages/{stage}/{stage}.md`.
2. One per-cycle YAML at `references/stages/{stage}/cycles/{cycle}.yaml` for each cycle that stage defines.
3. Optional stage-local reference files (for example `data-formats.md` under `references/formulate/`).

Each stage-entry file carries:

- stage purpose and required inputs/outputs
- the canonical YAML schema for the stage
- the shared cycle protocol
- stage-close finalization rules
- dependency notes

Each per-cycle YAML carries:

- `upstream`: canonical-YAML fields that must be set before the cycle runs
- `setup_side_effects`: one-time actions (typically for the first cycle only); omit when empty
- `required_evidence`: the evidence keys the script or model must produce for the cycle
- `acceptance_criteria`: 3-5 verifiable conditions that must hold for the cycle to close
- `writes`: mapping from evidence or judgment outputs to canonical-YAML fields
- `research_questions`: topics for a research subagent only when outside information can materially change a decision
- `guidance`: short, cycle-specific judgment rules
- `pcs_focus` or `log_extension`: present only when the cycle adds a specific discipline

Each cycle that makes a judgment must identify the plausible alternative most likely to change a downstream decision. Record whether it would change the route, claim boundary, data-usage rule, cleaning policy, analysis contract, evaluation verdict, or communication framing. Store this only in the relevant destination field, `rejected_alternatives`, `open_risks`, or `material_findings`; do not create a separate process log.

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

Freeze these rules in `protocol` so `clean`, `examine`, and `analyze` execute against a committed contract.

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
6. If the active route cannot be resolved or the expected route file is missing, stop and repair the routing architecture before continuing.

Route files may narrow the stage-core. They may not override reproducibility rules or widen the claim boundary.

## Determinism Mechanisms

Two patterns every stage must follow.

### 1. Per-cycle Evidence and Acceptance Criteria

Every cycle is specified by a cycle YAML under `references/stages/{stage}/cycles/{cycle}.yaml`. That file defines the required evidence, acceptance criteria, optional research questions, and guidance for that cycle.

Rules:

- Required evidence keys are the script JSON keys or model judgments that must exist before the cycle can close.
- Acceptance criteria are the enforceable cycle bar. Keep them few enough to reason about directly; 3-5 criteria is the default target.
- A missing required evidence key or failed acceptance criterion is a blocking failure.
- Skip rules must be explicit. If a required evidence key has no skip rule, absence is blocking.
- If a project needs to proceed with a bounded risk, use `override: {reason, criterion}` rather than a soft-fail concept.

### 2. Decision Matrix

Every cycle decision uses a two-row matrix based on `blocking_failures` (missing required evidence + blocking defects + failed acceptance criteria):

| blocking_failures | forward actions allowed |
|-------------------|------------------------|
| 0                 | pass, iterate          |
| > 0               | iterate, acknowledge gap (with written justification) |

Rules:

- Backward actions are always available regardless of `blocking_failures`: reopen relevant upstream stages (each stage file specifies which), archive.
- User override is always available: user states the specific reason the FAIL is incorrect, logged as `override: {reason, criterion}`, forward actions unlock.
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
      *_constraints.json       # Optional clean/preprocess constraint artifacts.
      *.json                   # Optional companion artifacts shared across cycles.
      stdout/                  # Optional debug evidence for failed or user-requested cycle captures.
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

- Generate stage scripts for the current project. Do not copy a shared Python scaffold.
- Follow the compact contract in `references/script-contract.md`.
- One file per stage, containing one function per cycle (`run_cycle_a`, `run_cycle_b`, ...).
- CLI contract: `python {NN}_{stage}.py --cycle {cycle}`. Only the requested cycle runs.
- Each function returns a dict. `main()` prints exactly one JSON object to stdout. Nothing else on stdout.
- The script reads the canonical stage YAML to find data paths and prior decisions. It does not write the canonical YAML; only the model writes the canonical YAML.
- Shared helpers are allowed when they prevent repeated file loading, preserve dtype or encoding consistency, validate constraints, or make cycle outputs reproducible. They must be deterministic, side-effect-limited, and covered by cycle evidence or final reproducibility checks.
- Use memoized loaders such as `load_state()`, `load_raw()`, or `load_inputs()` when multiple cycles read the same inputs. The loader must apply the encoding and dtype contract recorded in provenance.
- Use a shared `check_dtype_meaning(series, expected_meaning)` helper when semantic dtype matters, including strings, identifiers, nullable integers, dates, categoricals, and pandas or pyarrow dtype variants.
- Heavy data (full DataFrames, long arrays) is summarized, not dumped. Evidence packets stay compact.
- `decision_ledger[*].evidence_summary` in the canonical YAML carries a compact summary of each cycle's stdout (4-8 one-line bullets, or one-line value per material evidence key). The stage script does not write stdout sidecars by default. If a debug sidecar is written after a failure, rerun, or user request, the model never copies that file into the canonical YAML.
- Per-file provenance (schema, encoding, sha256) is emitted only the first time a file is recorded -- typically Cycle A iter 1. After it lands in `provenance.files`, neither the stdout packet nor `decision_ledger[*].evidence_summary` re-emits those fields; downstream cycles reference those files by filename.
- Seeds are set inside the function whenever stochastic steps run, and the seed value is echoed into the evidence packet.
- Stable helper functions or sibling helper modules are allowed when they reduce duplication and improve reproducibility. Helpers must be deterministic, documented briefly, listed in provenance when project-local, and must not write canonical YAML or access restricted artifacts.
- After script execution, scan stdout and stderr for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing, unless the function body explicitly marks an expected failure with a `# expected_failure` comment.

## Universal Rules

- Never modify raw files in the configured data directory.
- Express every material transformation in code.
- Record every judgment call with rationale and plausible alternatives in the canonical YAML.
- Respect protocol-defined data visibility. If a partition or holdout is restricted, do not touch it outside the stages and purposes `protocol` allows.
- Change question type or claim class only by reopening `formulate` and `protocol`.
- Keep one canonical YAML plus one rendered markdown per completed stage in the configured documentation directory.
- Re-run from raw data plus protocol-defined frozen artifacts, not from ad hoc saved intermediates.
- Record random seeds when stochastic procedures matter.
- Preserve an audit trail when backtracking. `decision_ledger` is append-only; new iterations append to the list and past entries remain as recorded.
- Keep decision ledger entries compact. Analytical findings belong in their destination fields, not in a parallel process log.
- Generated project documents must reference real project files. Every reference must point to a file that currently exists in the project.
- Derive README summaries from the actual project filesystem state and verify them against artifacts on disk.

## Source Data Encoding

Before loading any source data file for the first time (typically in Formulate Cycle A), detect its encoding:

- Try reading with UTF-8 strict first. If it succeeds, the file is UTF-8.
- If UTF-8 fails, check for a BOM (byte order mark) indicating UTF-16 or UTF-8-BOM.
- If no BOM and UTF-8 fails, attempt Latin-1 / Windows-1252 as a fallback. Log the detected encoding.
- Record the detected encoding for each text source file in the canonical YAML. All downstream text reads must pass the detected encoding explicitly. Do not rely on default encoding inference.
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

- Preserve the earlier record. `decision_ledger` entries are append-only.
- Unlock the stage (set `status.locked_at: null`) and re-run the affected cycles.
- Re-render the markdown at the end of the reopen.
- Preserve earlier work by marking it superseded in a new iteration; past entries stay as written.

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
