---
name: clean
description: Use after formulate and protocol to build an auditable cleaning pipeline under protocol-defined data visibility, without widening the claim boundary or assuming predictive workflow defaults.
---

# /skeptic:clean - Data Cleaning and Preprocessing

**IMPORTANT:** Before executing, read `references/core-principles.md` from the parent `skeptic` skill for shared conventions.

`core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

This file is the universal stage-core for `clean`. It defines the cleaning workflow machinery that applies across question types. Route files may narrow or prohibit actions. They may not widen this stage-core, the approved formulation, or the protocol contract.

## Data Contract
Every clean run should establish an explicit data contract before cleaning begins.

The contract should name:
- the raw artifact(s) being inspected
- the cleaned artifact(s) that will exist after cleaning
- the tidy-data rules for row and column meaning
- the codebook or data dictionary and where it lives
- the required codebook contents: variable definitions, units, allowed values, missing and censored codes, observational-unit notes, and any source-specific semantic conventions
- the missing-vs-censored rule for question-critical fields
- the raw-to-clean recipe or script that reproduces the final outputs
- any structural conventions that affect interpretation, such as identifier rules or joined-table semantics

If the contract cannot be written from available documentation, stop and surface the ambiguity. Do not improvise the data model in the notebook.

## Structural Cleaning Rules
Cleaning must preserve meaning while making structure explicit.

Use these default structural rules unless `formulate`, `protocol`, or the route file narrows them:
- one variable per column
- one observation per row
- one observational unit per row unless a multi-row representation is explicitly documented
- explicit keys for joins and repeated measurements
- categorical meaning stored in values, not in formatting
- column names should be consistent, explicit, and mechanically readable
- merged fields should be split when the components have distinct meanings
- unit conversions must be documented and verified, not assumed
- label switching or contradictory joins must be resolved as a semantic issue, not hidden as a value-cleaning issue

## Preprocessing Doctrine
Preprocessing changes representation, not the underlying question.

Use these defaults:
- standardization and normalization are representation choices, not model choices
- monotonic transforms such as logs are allowed only when they preserve meaning for the approved question
- one-hot encoding is allowed only when the category split is meaning-preserving and the downstream representation remains honest
- low-regret preprocessing should make structure easier to inspect, not manufacture analysis-ready features
- any transform that must be fit from data for later use must respect protocol-defined visibility rules and must not use reserved validation, future, or restricted artifacts
- if a categorical expansion introduces a dummy-variable dependency or omitted-reference convention, the convention must be documented and kept aligned with the eventual route file or analysis contract

If a proposed preprocessing step is really compensating for unresolved data quality, route it back to the cleaning cycles instead of masking it here.

## Required Input

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` |

`clean` requires completed `formulate` and `protocol` stages. Do not start from partial upstream context.

## What Prior Outputs This Stage Reads

The stage reads:

- `skeptic_documentation/01_formulation.md` - approved question, question type, target quantity or estimand, claim boundary, operationalization table, unit of analysis, assumptions, protocol handoff
- `skeptic_documentation/02_protocol.md` - active route, data usage mode, visibility rules, frozen artifacts, leakage and forbidden-variable rules, clean prohibitions, validation logic, backtracking triggers
- `skeptic_documentation/metrics.md` - formulation and protocol scorecards
- `notebooks/01_formulation.ipynb` - formulation evidence and rationale trace
- `notebooks/02_protocol.ipynb` - protocol evidence, artifact creation logic, and restriction rationale
- protocol-defined artifacts under `data/` or `data/splits/` or another path named in `02_protocol.md`
- `README.md` - confirms prior stage completion

No additional user input is required if `formulate` and `protocol` are complete. If upstream outputs are incomplete, contradictory, or missing required restrictions, stop and repair the upstream stage. Do not invent cleaning permissions around gaps.

## Route Resolution

Before Cycle A, do this in order:

1. Read `01_formulation.md`, `02_protocol.md`, `metrics.md`, `01_formulation.ipynb`, `02_protocol.ipynb`, and `README.md`.
2. Resolve exactly one active route from upstream outputs. Use the confirmed question type in `01_formulation.md` and `02_protocol.md` as the anchor. If `02_protocol.md` contradicts it or does not collapse to one route for `clean`, stop and reopen `protocol`.
3. Load exactly one stage-specific route file:

| Route | File |
|-------|------|
| `descriptive` | `references/routes/descriptive/clean.md` |
| `exploratory` | `references/routes/exploratory/clean.md` |
| `inferential` | `references/routes/inferential/clean.md` |
| `predictive` | `references/routes/predictive/clean.md` |
| `causal` | `references/routes/causal/clean.md` |
| `mechanistic` | `references/routes/mechanistic/clean.md` |

4. Keep that route context in memory for the rest of `clean` and reuse it across cycles in the same chat.
5. If route context becomes ambiguous mid-stage, reread `01_formulation.md`, `02_protocol.md`, and the same route file before proceeding.
6. If the active route cannot be resolved or the expected route file is missing, stop and route back upstream.

## Precondition Gate

Run this gate before anything else.

Verify all of the following:

- `skeptic_documentation/01_formulation.md` exists
- `skeptic_documentation/02_protocol.md` exists
- `skeptic_documentation/metrics.md` exists
- `README.md` exists
- at least one raw data file exists in `data/`
- raw file SHA-256 hashes from `01_formulation.md` `## Raw File Hashes` section match current hashes of the corresponding files on disk. Recompute the hash of each raw file and compare. Any mismatch is a blocking defect indicating the raw data was modified after formulation.

Verify `01_formulation.md` contains:

- `## Summary`
- `## Protocol Handoff`
- `## PCS Assessment`
- an approved question
- a question type
- a target quantity or estimand
- a claim boundary
- a unit of analysis
- an operationalization table or equivalent list of question-critical variables
- key assumptions

Verify `02_protocol.md` contains:

- `## Summary`
- `## Protocol Contract`
- `## Frozen Artifacts`
- `## PCS Assessment`
- a confirmed question type
- active route
- data usage mode
- explicit visibility rules for `clean`
- frozen artifacts required or an explicit statement that none are required
- leakage relevance and forbidden-variable classes
- validation logic required later
- major `clean` prohibitions
- backtracking triggers

Resolve the active route from `01_formulation.md` plus `02_protocol.md`.

Verify the matching file `references/routes/{route}/clean.md` exists.

Verify protocol-required artifacts exist for the approved data usage mode. Examples include:

- full-data analysis with no frozen artifacts
- restricted partitions defined by a partition index or materialized split files
- temporal slices or cutoffs
- group partition artifacts
- rolling validation windows
- external validation manifests
- resampling-compatible full-data logic with no restricted artifacts
- another protocol-defined artifact pattern

Do not require train, validation, and test files universally.

Before Cycle A, derive and record the active visibility set for this stage:

- which raw files are visible
- which protocol-created artifacts are visible
- which artifacts are restricted from inspection in `clean`
- what level of access is allowed for each visible artifact

If any required field, artifact, or restriction is missing or contradictory:

- stop
- tell the user exactly what is missing or inconsistent
- route back to `protocol` or `formulate` as appropriate

Do not proceed with partial context.

## Guiding Principle

The goal of cleaning is not to produce "clean data" in some abstract sense. The goal is to produce an auditable, reproducible data pipeline that preserves measurement meaning and supports the approved question inside the approved protocol.

Use cleaning to:

- fix structural and value problems
- make semantic contracts explicit
- document judgment calls
- preserve or clarify the analyzable population
- prepare trustworthy inputs for later stages

Do not use cleaning to:

- smuggle in a predictive workflow as the default
- widen the claim boundary
- choose the final analysis contract
- override protocol visibility rules
- invent route-specific permissions that belong in the loaded route file or later `analyze`

When convenience conflicts with meaning, choose meaning.

## Setup

Before Cycle A, create:

1. `notebooks/03_cleaning.ipynb` with a header cell containing:
   - stage title
   - date
   - project name
   - approved question
   - question type
   - target quantity or estimand
   - claim boundary
   - link to `01_formulation.md`
   - link to `02_protocol.md`
   - active protocol mode
   - active visibility rules for `clean`
   - visible artifacts list
   - note: "This notebook is stage-core only. The loaded route file may narrow or prohibit actions. This stage does not widen protocol or claim boundaries."

2. `skeptic_documentation/03_cleaning.md` with this initial structure:

```markdown
# Clean: Data Cleaning and Preprocessing

## Dataset
- Source: {raw data file(s)}
- Approved question: {from 01_formulation.md}
- Question type: {from 01_formulation.md}
- Target quantity: {from 01_formulation.md}
- Claim boundary: {from 01_formulation.md}
- Protocol mode: {from 02_protocol.md}
- Visibility rules: {short summary from 02_protocol.md}
- Visible artifacts: {artifact list from protocol}
- Date started: {date}

## Question-Critical Variables
| Term | Operationalization | Column(s) or artifact(s) | Rationale |
|------|--------------------|--------------------------|-----------|
| {from formulate} | {from formulate} | {from formulate} | {from formulate} |

## Data Contract
- Raw artifact(s): {raw data file(s)}
- Cleaned artifact(s): {final cleaned table(s)}
- Tidy-data rules: {one variable per column, one observation per row, explicit keys}
- Codebook/data dictionary: {location and required contents}
- Missing-vs-censored rule: {rule for source and question-critical fields}
- Raw-to-clean recipe: {script or function path}
- Structural conventions: {identifier, naming, join, and unit rules}

## Protocol Constraints
- Leakage relevance: {from 02_protocol.md}
- Forbidden variables: {from 02_protocol.md}
- Clean prohibitions: {from 02_protocol.md}
- Validation logic reserved for later stages: {from 02_protocol.md}

## Cleaning Rules
- Structural rules: {one variable per column, one observation per row, explicit keys, documented unit conversions}
- Representation rules: {standardization, normalization, log transforms, one-hot encoding, and when each is meaning-preserving}
- Missingness rule: {missing vs structurally missing vs censored}
- Preprocessing fit scope: {whether any transform must be fit only from protocol-allowed visible artifacts}

## Decision Log

## Dataset Fitness Review

## PCS Assessment
```

The notebook header must state the active protocol mode and visibility rules explicitly. `clean` starts only after those fields are written.

## Stage Map

| Cycle | Focus | Default function target |
|-------|-------|-------------------------|
| A | Structural audit | `clean_data()` |
| B | Integrity diagnostics | `clean_data()` |
| C | Cleaning resolution | `clean_data()` |
| D+ | Cleaning follow-ups | `clean_data()` |
| E | Preprocessing | `preprocess_data()` |
| F | Derived variables and related downstream-safe transformations | `preprocess_data()` |
| G+ | Preprocessing and derived-variable follow-ups | `preprocess_data()` |

Cycles `A`, `B`, `C`, and `E` are mandatory. Cycle `F` is conditional. Use it only if derived variables or similarly downstream-safe transformations are justified by the approved question and protocol. `D+` and `G+` are follow-up windows, not standing obligations.

Cycles `E`, `F`, and `G+` may force a return to `D+` if a representation decision turns out to be an unresolved cleaning issue.

## Execution Gates

Before each cycle, verify the required outputs from prior work exist. If anything is missing, stop and tell the user exactly what is missing.

| Before | Required state |
|--------|----------------|
| Cycle A | Precondition gate passed. Setup files exist. Active visibility set recorded. |
| Cycle B | `03_cleaning.md` contains `### Cycle A` log entry. `03_cleaning.ipynb` has Cycle A outputs. |
| Cycle C | `03_cleaning.md` contains `### Cycle B` log entry. `03_cleaning.ipynb` has Cycle B outputs. |
| Cycle E | `03_cleaning.md` contains `### Cycle A`, `### Cycle B`, and `### Cycle C` log entries. `## Dataset Fitness Review` updated after the most recent cleaning resolution. |
| Cycle F | `03_cleaning.md` contains `### Cycle E` log entry. There is an explicit note that derived variables remain within the approved question and protocol boundary. |
| Post-cycle evaluation | Cycle loop complete. Any approved `D+` and `G+` follow-ups are closed. User has indicated the stage is ready for post-cycle validation. |

## Gate Condition Registry

Every evaluation gate has a stable ID used in cycle metrics. The evaluation subagent references these IDs in its structured output.

| gate_id | cycle | depends_on | condition |
|---------|-------|------------|-----------|
| `A-visibility-confirmed` | A | A01 | The stage identifies exactly which data and artifacts `clean` is allowed to inspect under protocol rules |
| `A-structure-audited` | A | A02, A03, A04 | Visible artifacts load and align to the documented unit of analysis and structural expectations |
| `A-semantics-aligned` | A | A05 | Question-critical and high-risk fields have semantic contracts or explicit unresolved ambiguity logs |
| `A-protocol-scope-respected` | A | A06 | Planned cleaning actions stay within question type, protocol, and active route-file restrictions |
| `A-data-contract-defined` | A | A07 | The tidy-data contract, codebook, row/column semantics, and raw-to-clean recipe are explicit |
| `A-structure-rules-defined` | A | A08 | Structural conventions such as column naming, merged fields, identifier rules, and unit handling are explicit and consistent |
| `B-values-profiled` | B | B01, B02 | Invalid values, sentinel patterns, format inconsistencies, and domain-plausibility issues are inventoried |
| `B-missingness-assessed` | B | B03 | Missingness is diagnosed for question-critical and high-risk fields |
| `B-duplicates-classified` | B | B04 | Duplicate-like patterns are classified before any action is taken |
| `B-cross-var-checked` | B | B05 | Cross-variable consistency checks run where applicable |
| `B-restricted-artifacts-respected` | B | B06 | Restricted artifacts are untouched or used only in protocol-approved ways |
| `B-missing-censored-separated` | B | B07 | Missing, structurally missing, and censored values are distinguished according to source rules |
| `C-policies-defined` | C | C01, C02 | Material cleaning policies are explicitly chosen and logged |
| `C-transforms-auditable` | C | C03 | Every material transformation is expressed in code and traceable to a rationale |
| `C-population-shift-stated` | C | C04 | Material row, value, or coverage changes include an explicit population-shift statement |
| `C-row-count-reconciled` | C | C04 | A row-count reconciliation table exists showing: raw_rows - exclusion_1 - exclusion_2 - ... = cleaned_rows. The arithmetic sum must match the actual cleaned artifact row count. Any discrepancy > 0 is a blocking defect. |
| `C-claim-impact-stated` | C | C05 | Claim consequences of cleaning decisions are stated explicitly |
| `C-fitness-checkpoint-run` | C | C06 | Dataset fitness checkpoint is completed after material cleaning resolution |
| `C-suspicious-cleanliness-reviewed` | C | C07 | Suspiciously neat outputs are challenged when trigger conditions appear |
| `E-transforms-protocol-safe` | E | E01, E05 | Preprocessing stays within protocol visibility rules and transformation permissions |
| `E-low-regret-only` | E | E02, E03 | Preprocessing choices preserve meaning and remain broadly defensible across later approved paths |
| `E-no-hidden-model-prep` | E | E04, E06 | No silent move toward model-family-specific preparation occurs |
| `F-derived-justified` | F | F01 | Derived variables are justified by the approved question and protocol |
| `F-route-safe` | F | F02 | Derived variables remain compatible with question type, protocol, and the active route file |
| `F-derived-validated` | F | F03 | Derived variables are checked for meaning, missingness, distribution, and interpretation risk |

## Cycle Protocol

Apply this protocol to every cycle.

### Step 0: Progress Indicator

At the start of each cycle, print:

`"Clean stage: Cycle {X} ({focus}) - {mandatory/conditional/follow-up} - {ordinal} of 4 mandatory cycles"`

For post-cycle phases, print:

`"Clean stage: Post-cycle Phase {N} ({name})"`

### Step 1: Setup and Execution

- Claude reads existing notebook outputs. Skip this only for Cycle A beyond the header.
- Claude reads `01_formulation.md` and `02_protocol.md` before every cycle. Treat the approved question, question type, claim boundary, protocol mode, visibility rules, and prohibitions as hard constraints.
- Claude reuses the route context already loaded at stage start from `references/routes/{route}/clean.md`.
- If route context becomes ambiguous, Claude rereads `01_formulation.md`, `02_protocol.md`, and the same route file before proceeding.
- If the active route cannot be confirmed or the expected route file is missing, stop and reopen upstream. Do not guess.
- Claude identifies which visible artifacts the current cycle is allowed to inspect. If visibility is unclear, stop and reopen `protocol` rather than guessing.
- Claude verifies that planned actions stay within the approved question type, protocol contract, and active route file.
- Claude identifies which conditional modules apply for the cycle:
  - semantic contract audit
  - duplicate classification
  - missingness strategy comparison
  - restricted-artifact checks
  - population-shift checkpoint
  - protocol-conditioned transfer diagnostics
- Claude writes notebook cells with markdown reasoning followed by code.
- Claude executes the notebook and presents key outputs to the user (see `core-principles.md` Notebook Execution).

### Step 2: Human Review

- Interactive mode: the user reviews the outputs presented by Claude, provides questions or concerns, and Claude responds before proceeding.
- Auto mode: replace this step with the self-review loop from `references/auto-mode.md`. Claude may self-correct within the configured budget, then proceeds without waiting unless an escalation trigger fires.

### Step 3: Subagent Review

Claude reads the notebook outputs, then dispatches two subagents in parallel.

**Research subagent:**

```text
Agent(
  model="{subagent_model}",
  description="Research for Clean Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a research assistant for a Skeptic clean stage.

  Context:
  - Approved question: "{approved question}"
  - Question type: {question type}
  - Target quantity: {target quantity}
  - Claim boundary: {claim boundary}
  - Protocol mode: {protocol mode}
  - Clean-stage visibility rules: {visibility rules}
  - Visible artifacts used in this cycle: {artifact list}
  - Question-critical variables: {from formulate}
  - Current notebook findings: {specific findings from this cycle}
  - User observations: {user observations if any}

  Answer these research questions for Cycle {X} ({focus}):
  {insert cycle-specific research questions}

  Rules:
  - Stay inside the approved question and protocol.
  - Reuse prior formulate and protocol findings before researching beyond them.
  - Stay specific to the variables, artifacts, values, slices, or transformations surfaced in the notebook.
  - If a question does not apply, say "not applicable" and give a one-line reason.
  - Cite sources for any claim that would change a cleaning or preprocessing decision.

  Return concise findings with sources, organized by research question.
  Focus on actionable information that changes cleaning judgments, semantic interpretation, or protocol compliance.
  """
)
```

**Evaluation subagent:**

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Clean Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a Skeptic clean-stage cycle.

  Before evaluating gates, verify that all checklist items for this cycle were answered with evidence in the notebook. If any checklist item was not answered, the gates that depend on it auto-fail.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.md
  2. {projects_root}/{project-name}/{notebooks_dir_name}/03_cleaning.ipynb
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  4. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.md

  Cycle focus: {focus description}
  User observations: {user observations if any}

  Question-critical variables:
  {from formulate}

  Active protocol mode and visibility rules:
  {from protocol}

  Answer these evaluation questions for Cycle {X} ({focus}):
  {insert cycle-specific evaluation questions}

  Applicable gates for this cycle:
  {list applicable gate IDs from the Gate Condition Registry}

  Task:
  1. Evaluate each applicable gate using notebook evidence.
  2. Answer the cycle-specific evaluation questions directly from notebook evidence.
  3. Identify up to 3 findings that determine whether the cycle should pass.
  4. Flag any decision that appears outcome-dependent, protocol-violating, or claim-widening.
  5. Recommend whether to pass, iterate, acknowledge a gap, reopen protocol, or reopen formulate plus protocol.
  6. Read the Claim Boundary Registry from `metrics.md`. Verify that no cleaning
     decision widens `scope` or changes the analyzable population in ways that
     would require loosening `generalization_limit`. If cleaning narrows the
     claim, append to `narrowing_log`.

  Output format (follow this exact structure in order):

  EVALUATION: Cycle {X} - {focus}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Your job is to actively falsify each gate
  and checklist answer rather than confirm them. For each gate you mark PASS,
  you must state the specific failure mode you tested and ruled out.
  Categories to scan: unstated assumptions, outcome-dependent decisions,
  protocol violations, claim-widening moves, cleaning choices that change
  the analyzable population without documentation, leakage risks.
  If after genuinely adversarial scrutiny you find zero defects, state
  "No defects found" and name at least 3 specific failure modes you tested
  and ruled out. Do not fabricate defects to meet a quota.
  - Defect 1: [description with evidence]
  - Defect 2: [description with evidence]

  SEVERITY CLASSIFICATION:
  For each defect: BLOCKING (must fix before proceeding) or NON-BLOCKING
  (noted, acceptable for this cycle).
  - Defect 1: BLOCKING / NON-BLOCKING - [one-line reason]
  - Defect 2: BLOCKING / NON-BLOCKING - [one-line reason]

  GATE ASSESSMENTS:
  - {gate_id}: PASS / FAIL - [evidence]
  - {gate_id}: PASS / FAIL - [evidence]
  (list every applicable gate)

  Cycle-specific findings:
  - [criterion]: [fact-based answer with notebook evidence]
  - [criterion]: [fact-based answer with notebook evidence]

  Key findings:
  - [finding]
  - [finding]
  - [finding]

  Gaps remaining: [list, or "none"]
  Recommended next step: pass / iterate on {topic} / acknowledge gap / reopen protocol / reopen formulate plus protocol
  Recommended follow-up cycle: [topic and why] / None

  VERDICT:
  PASS = zero BLOCKING defects and zero FAIL gates.
  FAIL = one or more BLOCKING defects or FAIL gates.
  Verdict: [PASS/FAIL]
  Blocking defects: [count]
  Failed gates: [count]

  Be objective. Not harsh, not lenient.
  """
)
```

### Step 4: Decision

When both subagents return, Claude synthesizes them into one cycle assessment. Do not present disconnected subagent reports as if they were the stage decision. Log the raw outputs for traceability.

Do not fabricate certainty. If the evidence shows the cleaning problem cannot be resolved inside the current boundary, surface it.

Count the blocking failures from the evaluation subagent output: blocking defects plus gates with verdict FAIL. Then apply the decision matrix.

**Decision matrix:**

| blocking_failures | forward actions allowed | note |
|-------------------|------------------------|------|
| 0 | pass, iterate | cycle meets minimum bar |
| > 0 | iterate, acknowledge gap (with written justification) | pass is blocked until blocking failures are resolved or justified |

**Always-available actions (regardless of blocking_failures):**

- **Reopen protocol** -> stop and reopen `protocol`
- **Reopen formulate** -> stop and reopen `formulate` plus `protocol`
- **Data insufficient** -> request more data or archive
- **User override** -> user states the specific reason the FAIL is incorrect, logged as `override: {reason}`, forward actions unlock

**Dataset fitness checkpoint** (required at Cycle C close, and after any later cycle that materially changes coverage, population, question-critical variables, or visibility):

The checkpoint must answer:
- Is the cleaned dataset still fit for the approved question?
- Is additional data now required?
- Is the approved question still appropriate for this dataset?
- Did cleaning reveal a protocol mismatch?
- Did cleaning reveal a formulation mismatch?

If any answer is `no` or `unclear`, surface it explicitly to the user as a decision point. Do not bury it inside "gaps."

Interactive mode: present the synthesized assessment to the user with the allowed actions from the matrix. The user decides. After every cycle, force an explicit decision. Do not silently continue.

Auto mode: apply the autonomous decision protocol from `references/auto-mode.md`, log the rationale, and continue without waiting unless an escalation trigger fires.

### Step 5: Log

Immediately after each cycle decision, append to `skeptic_documentation/03_cleaning.md`:

```markdown
### Cycle {X}: {Focus}
- **Visible artifacts used:** {artifact list}
- **What we inspected:** {notebook cells run, data examined}
- **Research findings:** {key findings from the research subagent}
- **Evaluation verdict:** PASS / FAIL
- **Key findings:** {up to 3 findings from the evaluation subagent}
- **Protocol check:** {within bounds / protocol mismatch found / formulation mismatch found}
- **Action items:**
  - [action] | Judgment call: No
  - [action] | Judgment call: Yes
    #### {Short judgment-call name}
    - **Decision:** {what we chose}
    - **Plausible alternatives:** {real alternatives only}
    - **Rationale source:** {measurement meaning / domain source / data-generating process / protocol rule / transferability evidence}
    - **Rationale:** {why}
    - **Would revisiting this require protocol or formulation change?:** {No / Protocol / Formulation + Protocol}
- **Row or unit impact:** {before -> after, if applicable}
- **Value impact:** {fields changed, how, and why}
- **Population shift:** {none identified / explicit statement}
- **Claim consequence:** {none / explicit limitation or downgrade}
- **Reproducibility update:** {code cells added, helper functions extracted, constraints noted}
- **Decision:** {pass / iterate / acknowledge gap / protocol mismatch / formulation mismatch / data insufficient}
```

Also append structured cycle metrics to `skeptic_documentation/metrics.md`. Create the section `## Cleaning` if it does not yet exist.

```markdown
**Cycle metrics:**
- iterations: {n}
- verdict: PASS/FAIL (on iteration {n})
- gates: [{gate_id}: PASS/FAIL, ...]
- research_sources_returned: {n}
- evaluation_verdict_aligned: yes/no/partial/indeterminate
- visibility_mode: {protocol mode}
- protocol_artifacts_used: {artifact list}
- judgment_calls: {n}
- material_population_shift: yes/no
```

## Cycle Definitions

## Cycle A: Structural Audit

**Focus:** Identify what data this stage is allowed to inspect, then verify structural and semantic alignment under protocol rules.

Do not assume test-set parity checks, holdout comparisons, or restricted-artifact access are relevant. Those depend on `protocol`.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| A01 | Which artifacts did we load, what are their dimensions, and which are restricted from inspection? | never |
| A02 | What are the data types, and do any columns have types that contradict their apparent meaning? | never |
| A03 | What does each row represent? Is there a unique identifier? Is observational-unit consistency confirmed? | never |
| A04 | If multiple visible artifacts exist, what are the candidate join keys and do they align? | single artifact |
| A05 | For each question-critical and high-risk field, what is its meaning, unit, expected range, and any unresolved ambiguity? | never |
| A06 | Do planned cleaning actions stay within the question type, protocol contract, and active route-file restrictions? | never |
| A07 | What is the tidy-data contract: raw artifact(s), cleaned artifact(s), codebook, row/column semantics, and raw-to-clean recipe? | never |
| A08 | Are structural conventions such as column naming, merged fields, identifier rules, and unit handling explicit and consistent? | never |

If a needed semantic contract is missing and the stage cannot resolve it from available documentation, stop and surface the exact ambiguity. Do not guess through it.

**Research questions:**

- What domain or source documentation clarifies the meaning, units, codes, or timestamp semantics of the visible fields?
- What structural expectations are normal for these artifacts?
- Are there domain-specific conventions that would change how duplicates, identifiers, or row units should be interpreted?
- What tidy-data and codebook conventions are required for these artifacts?
- Which values are missing, structurally missing, or censored?
- Does any unresolved semantic ambiguity threaten protocol compliance or the approved question?

**Evaluation focus:**

The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle B: Integrity Diagnostics

**Focus:** Diagnose values, missingness, duplicates, and cross-variable integrity issues without forcing predictive assumptions into the workflow.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| B01 | What sentinel values, invalid formats, impossible values, or suspicious codes exist in each column? | never |
| B02 | For numeric, date, text, and categorical columns, what domain-plausibility violations exist? | never |
| B03 | For question-critical and high-risk fields, what is the extent, concentration, and co-missingness of missing values? Does missingness itself carry meaning? | never |
| B04 | What duplicate-like patterns exist, and how are they classified (exact, repeated measurement, conflicting, near-duplicate, valid repeated unit)? | never |
| B05 | What cross-variable consistency violations exist? | never |
| B06 | Were any restricted artifacts touched or used outside protocol-approved ways? | no restricted artifacts |
| B07 | For question-critical and high-risk fields, are missing, structurally missing, and censored values distinguished according to the codebook and source rules? | never |

Keep this cycle universal. The goal is diagnosis, not premature resolution.

**Research questions:**

- Which flagged values, codes, ranges, or patterns are domain-plausible versus true integrity defects?
- What do common sentinel values or missing codes mean for this source type?
- When do apparent duplicates represent real repeated units rather than defects?
- Which cross-variable constraints are real measurement rules rather than arbitrary convenience rules?
- Which values need a missing-vs-censored distinction before cleaning can proceed?

**Evaluation focus:**

The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle C: Cleaning Resolution

**Focus:** Choose and implement cleaning policies. Log population shifts, claim consequences, and reproducibility implications explicitly.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| C01 | For each material issue from Cycles A and B, what are the real policy options? | never |
| C02 | For each chosen policy, what is the rationale from measurement meaning, domain knowledge, data-generating process, or protocol constraints? | never |
| C03 | For each material action, what code implements it and is the transformation traceable to the rationale? | never |
| C04 | For each material action, what changed (rows, values, fields, analyzable population) and what is the population-shift statement? | never |
| C05 | For each material action, what is the claim consequence (no change, narrower coverage, changed interpretation, or need for backtracking)? | never |
| C06 | Is the cleaned dataset still fit for the approved question? (Dataset fitness checkpoint) | never |
| C07 | Does the cleaned output look suspiciously neat? If trigger conditions appear, are they challenged? | no trigger conditions observed |

If a proposed cleaning action would require protocol-forbidden visibility, unauthorized use of restricted artifacts, or a wider claim than the approved boundary, stop and reopen upstream. Do not force the action through.

**Research questions:**

- Which competing cleaning policies are defensible for the flagged issues?
- What population or interpretation shifts follow from each plausible cleaning action?
- Are any proposed actions likely to erase meaningful variation or create artificial regularity?
- Does any unresolved issue indicate a protocol mismatch rather than a pure cleaning problem?

**Evaluation focus:**

The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycles D+: Cleaning Follow-ups

Use a `D+` follow-up only when a material cleaning issue remains unresolved after Cycle C or a later cycle exposes an upstream cleaning problem.

A `D+` cycle must be narrow and issue-specific. Define only:

- the unresolved cleaning issue
- why it materially matters for the approved question
- what evidence is still needed
- what concrete decision the follow-up is meant to unlock

Use `D+` for issues such as:

- unresolved semantic contract conflicts
- a disputed duplicate policy
- a missingness decision with real claim consequences
- an integrity rule discovered during preprocessing or derived-variable work
- a population shift that may require backtracking

Do not turn `D+` into generic extra exploration. If the issue is actually protocol or formulation mismatch, route back upstream.

Each D+ cycle must define its own checklist items (D01, D02...) scoped to the specific unresolved issue.

## Cycle E: Preprocessing

**Focus:** Apply low-regret representation changes only when they remain valid under the approved protocol and claim boundary.

This cycle does not prepare data for a generic downstream model. It applies only those transformations that preserve meaning, stay inside protocol rules, and keep later route choices honest.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| E01 | Do proposed transformations stay within the approved question, protocol mode, and visibility rules? | never |
| E02 | For category representation, what inconsistent labels, rare levels, or grouping decisions exist, and are they meaning-preserving? | never |
| E03 | For numeric, date, and time representation, what normalization, parsing, or monotonic transforms are proposed, and do they preserve meaning? | never |
| E04 | Which transformations are deferred to the route file or analyze stage, and why? | never |
| E05 | If a transform must be fit from data for later use, is its fitting scope limited to protocol-allowed visible artifacts rather than reserved future or validation artifacts? | never |
| E06 | If categorical expansion is used, are omitted-category conventions, reference levels, and downstream dummy-variable dependencies documented? | never |

If a proposed preprocessing step is actually compensating for unresolved data quality, route the issue back to `D+` instead of masking it here.

**Research questions:**

- Which transformations preserve meaning across plausible later uses allowed by the protocol?
- When do rare levels, date encodings, or monotonic transforms clarify representation versus erase structure?
- Which candidate transformations are broadly defensible versus tightly tied to a later route or model family?
- Does any proposed preprocessing action signal an unresolved cleaning problem instead?
- Does any proposed transform need to be fit only from protocol-allowed visible artifacts?
- If categorical expansion is used, what omitted-level or reference-level convention keeps later use honest?

**Evaluation focus:**

The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle F: Derived Variables and Related Downstream-Safe Transformations

**Focus:** Optionally create only narrowly justified derived variables or related transforms that remain valid under the approved question and protocol.

This cycle is conditional. Skip it and log why if no justified derived variables are needed.

Stage-core permits only these classes of work:

- formulation-approved derived metrics
- protocol-explicit structural transforms
- low-regret measurement-fidelity fixes

Anything more analysis-shaped must be deferred to the route file or to `analyze`.

Before creating any derived variable or related transform, verify:

- the approved question still requires it
- `protocol` does not prohibit it
- the active route file does not narrow it away
- the change fits one of the three stage-core classes above
- the change does not widen the claim boundary

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| F01 | Are proposed derived variables justified by the approved question and protocol, and do they fit one of the three permitted stage-core classes? | never |
| F02 | Are derived variables compatible with question type, protocol, and the active route file? | never |
| F03 | For each retained derived variable, what is its formula, meaning, missingness, distribution, and interpretation risk? | never |

Do not treat feature engineering or analysis-shaped variable construction as the purpose of this stage.

**Research questions:**

- Are the proposed derived variables or transforms already approved in `formulate`, explicitly authorized by `protocol`, or defensible as low-regret measurement-fidelity fixes?
- What competing definitions exist, and do they push the work out of stage-core and into the route file or `analyze`?
- Does any proposed variable or transform create leakage, post-treatment problems, unsupported interpretation, or analysis-shaped drift?
- Should this proposal stay in `clean`, or should it be deferred downstream?

**Evaluation focus:**

The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycles G+: Preprocessing and Derived-Variable Follow-ups

Use a `G+` follow-up only when a material preprocessing or derived-variable issue remains unresolved after Cycle E or F.

A `G+` cycle must define:

- the unresolved representation issue
- why it materially matters for the approved question or later protocol-approved work
- what evidence or comparison is still needed
- what concrete decision the follow-up is meant to unlock

If the issue is really about upstream data quality or semantic validity, route it back to `D+` instead of keeping it in `G+`.

Each G+ cycle must define its own checklist items (G01, G02...) scoped to the specific unresolved issue.

## Ending the Cycle Loop

The cycle loop ends when:

- mandatory cycles `A`, `B`, `C`, and `E` are complete
- conditional Cycle `F` is completed or explicitly skipped with a logged reason in `03_cleaning.md` (e.g., "Cycle F skipped: no derived variables justified by the approved question and protocol")
- all approved `D+` and `G+` follow-ups are closed
- interactive mode: the user indicates the stage is ready for post-cycle validation
- auto mode: the mandatory cycles and approved follow-ups are complete, so the stage advances to stage-close review under `references/auto-mode.md`

Do not finalize because the stage "seems good enough." Require an explicit decision.

## Post-cycle Evaluation

After the cycle loop, move through four phases. Interactive mode waits for user review between phases. Auto mode follows `references/auto-mode.md` and pauses only on escalation triggers or the final stage-boundary approval.

Before each phase, verify the required state exists. If anything is missing, stop and tell the user exactly what is missing.

| Before | Required state |
|--------|----------------|
| Phase 1: Reproducibility | Cycle loop complete. Latest dataset fitness checkpoint complete. |
| Phase 2: Robustness | `notebooks/cleaning_functions.py` exists. Snapshot validation passed. Constraint specs exist. |
| Phase 3: PCS Review | Robustness outputs exist in the notebook. `## Instability Thresholds` exists in `03_cleaning.md`. |
| Phase 4: Finalization | `## PCS Assessment` section exists in `03_cleaning.md`. |

### Phase 1: Reproducibility

**Goal:** Freeze the notebook work into reusable functions and prove they reproduce the notebook outputs exactly.

**Inputs:**

- final notebook state after Cycles `A`, `B`, `C`, `E`, optional `F`, and any approved `D+` and `G+` follow-ups
- the active visibility set from `02_protocol.md`

**Required outputs:**

1. `notebooks/cleaning_functions.py` with:
   - `clean_data(visible_inputs, **judgment_call_params)` for cleaning transformations from Cycles `A` to `C` and `D+`
   - `preprocess_data(clean_outputs, **judgment_call_params, fit_params=None)` for preprocessing and derived-variable transformations from Cycles `E`, `F`, and `G+`
   - stable handling of the protocol-visible artifacts actually used in this project
   - a deterministic return signature documented in the file

2. Validation notebook cells that:
   - reload raw data plus protocol-defined visible artifacts
   - rerun `clean_data(...)`
   - compare the rerun outputs against the notebook-produced cleaned outputs
   - rerun `preprocess_data(...)` if preprocessing or derived-variable work was performed
   - fail loudly on mismatch

3. Snapshot artifacts saved under `notebooks/.snapshots/` only for validation:
   - `clean_snapshot.*` for the cleaned outputs
   - `preprocess_snapshot.*` only if Cycle `E` or `F` produced transformed outputs distinct from cleaning outputs

4. Constraint specs:
   - `notebooks/clean_constraints.json`
   - `notebooks/preprocess_constraints.json`

These artifacts are mandatory for every clean stage. If preprocessing or derived-variable work adds no distinct constraints, write an explicit identity or no-additional-constraints specification rather than omitting the artifact.

**Gate to proceed:**

- snapshot equality passes for the relevant outputs
- declared constraints with severity `error` all pass
- if either fails, fix the functions and rerun before moving on

**User review gate:** Present the reproducibility results to the user. Do not start Phase 2 until the user approves moving on.

### Phase 2: Robustness

**Goal:** Check whether the frozen cleaning pipeline is stable under reasonable judgment-call perturbations and, when protocol makes it meaningful, whether it transfers cleanly across protocol-defined artifacts.

**Inputs:**

- `notebooks/cleaning_functions.py`
- passed reproducibility and constraint checks
- question-critical variables from `03_cleaning.md`
- judgment call registry from `03_cleaning.md`
- active protocol mode and visibility rules from `02_protocol.md`

**Required outputs:**

1. `## Instability Thresholds` in `03_cleaning.md`. Claude proposes thresholds and the user approves or adjusts them before the rest of the phase runs.

2. **Protocol-conditioned transfer diagnostics** only when protocol makes them relevant and visible. Run them only if one or more of the following is true:
   - protocol defines restricted partitions that `clean` is allowed to inspect for this purpose
   - protocol defines temporal or group artifacts relevant to transfer checks
   - protocol defines external or secondary artifacts whose cleaned comparability must be assessed now
   - protocol defines later validation artifacts and allows clean-stage comparability checks

   If skipped, log why in `03_cleaning.md`.

   If run, scope diagnostics to the allowed artifacts and touched variables. Produce:
   - raw versus post-pipeline divergence table
   - artifact-specific transform-rate table
   - short interpretation cell
   - log block under `## Protocol-Conditioned Transfer Diagnostics`

   If protocol chose full-data or resampling-only logic with no restricted artifacts for this stage, do not hallucinate holdout transfer checks.

3. **Stability analysis** in `notebooks/stability_configurations.py` and notebook cells:
   - Layer 1 always: one-at-a-time perturbations for high-impact judgment calls
   - Layer 2 only when the user approves a fuller track or when protocol complexity makes interaction effects plausible
   - variable-level and question-level comparison metrics
   - output tables showing which judgment calls exceed thresholds
   - supporting plots only for threshold-crossing critical variables or artifacts

4. **One robustness summary** in `03_cleaning.md` that combines:
   - transfer verdict: pass / flagged / skipped
   - main unstable variables or artifacts
   - main risk-driving judgment calls
   - whether any issue is serious enough to reopen a cycle

**Gate to proceed:**

- thresholds approved by the user
- robustness outputs exist in the notebook
- every flagged issue has an explicit disposition: proceed, reopen a cycle, or acknowledge documented risk

**User review gate:** Present the robustness summary to the user. Do not start Phase 3 until the user approves moving on.

### Phase 3: PCS Review

**Goal:** Get one final review of the incremental risk introduced by cleaning and preprocessing, using the outputs of Phases 1 and 2.

**Inputs:**

- `01_formulation.md`
- `02_protocol.md`
- `03_cleaning.md`
- `03_cleaning.ipynb`

After the robustness outputs are complete under the active execution mode, dispatch a PCS review subagent:

```text
Agent(
  model="{subagent_model}",
  description="PCS review of clean stage",
  prompt="""
  You are a PCS reviewer for a Skeptic clean stage.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  2. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.md
  3. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.md
  4. {projects_root}/{project-name}/{notebooks_dir_name}/03_cleaning.ipynb

  Evaluate only the incremental risk introduced by cleaning and preprocessing.
  Do not restate the full formulation or protocol reviews.

  Use the approved instability thresholds in 03_cleaning.md.
  Use protocol-conditioned transfer diagnostics only if they were actually run.
  Treat failed declared-error constraints as a hard defect.

  Answer these questions:
  1. Predictability: acceptable or concern? Why?
  2. Stability: stable, conditionally stable, or unstable? Why?
  3. Which judgment call is the main risk driver, if any?
  4. Should the clean stage reopen a follow-up cycle? Yes or no, and why?

  Output format:

  PREDICTABILITY: ACCEPTABLE / CONCERN
  - [fact-based finding]

  STABILITY: STABLE / CONDITIONALLY STABLE / UNSTABLE
  - [fact-based finding]

  MAIN RISK DRIVER:
  - [judgment call or "none"]

  REOPEN FOLLOW-UP CYCLE: YES / NO
  - [why]
  """
)
```

**Gate to proceed:**

- PCS assessment appended to `03_cleaning.md` under `## PCS Assessment`
- interactive mode: the user chooses one of:
  - `Satisfied` -> proceed to Phase 4
  - `Valid concern` -> reopen the relevant `D+` or `G+` cycle
  - `Disagree` -> log the override and proceed
- auto mode: Claude records the PCS result, applies non-blocking fixes autonomously, and escalates only if the review exposes a blocking concern or the user rejects the stage at the stage boundary

The subagent advises. In auto mode, Claude records the result, applies non-blocking fixes autonomously, and escalates only for blocking concerns.

### Phase 4: Finalization

**Goal:** Close the stage cleanly after the active execution mode clears the PCS review or logs an override.

**Inputs:**

- approved or overridden PCS assessment
- all prior post-cycle outputs

**Required outputs:**

0. Delete the temporary snapshot artifacts under `notebooks/.snapshots/`.

1. Append a Cleaning Scorecard to `skeptic_documentation/metrics.md` under `## Cleaning`.

```markdown
### Cleaning Scorecard
| metric | value | source |
|--------|-------|--------|
| Checklist items answered | {answered}/{total} | cycle logs |
| Mandatory cycles completed | {n}/4 | cycle logs |
| Conditional Cycle F | {completed / skipped with reason} | cycle logs |
| Follow-up cycles (D+) | {n} ({list topics}) | cycle logs |
| Follow-up cycles (G+) | {n} ({list topics}) | cycle logs |
| Total iterations (all cycles) | {n} ({cycle}: {n}, ...) | cycle logs |
| Blocking failures total | {n across all cycles} | gate registry |
| Blocking failures resolved by iteration | {n} | gate registry |
| Blocking failures resolved by override | {n} ({list override reasons}) | gate registry |
| Snapshot match | {yes / no} | Phase 1 validation |
| Constraints passed (error severity) | {n}/{total} | clean_constraints.json |
| Constraints passed (warn severity) | {n}/{total} | clean_constraints.json |
| Judgment calls total | {n} | decision log |
| Judgment calls stable under perturbation | {n}/{tested} | Phase 2 stability |
| Transfer diagnostics | {pass / N flagged / skipped} | Phase 2 |
| PCS verdict | {from Phase 3 subagent} | Phase 3 |
| PCS user decision | {satisfied / valid concern acted on / override with reason} | Phase 3 |
```

2. Update `03_cleaning.md` with `## Summary` containing:
   - final visible artifact list after cleaning
   - final variable list after cleaning
   - final preprocessing and derived-variable outputs, if any
   - complete judgment-call inventory
   - constraint specs created
   - protocol-conditioned transfer diagnostics summary
   - stability verdict per critical variable or artifact
   - dataset fitness review
   - population-shift summary
   - assumptions and open questions carried forward

3. Update `README.md`:

```markdown
## Clean [COMPLETE]
Type: {question type}
Protocol mode: {data usage mode}
Visibility: {one-line summary of clean-stage visibility rules}
Cleaning: {one-line summary of key cleaning decisions}
Preprocessing: {one-line summary of applied low-regret transformations, or "none"}
Derived variables: {one-line summary, or "none"}
Population shift: {one-line summary}
Constraints: {constraint files created}
Functions: notebooks/cleaning_functions.py
Next: Examine - inspect cleaned data under protocol rules
```

4. Present the final artifacts to the user and state that the clean stage is ready to close.

**Gate to finish:**

- scorecard, summary, and README updates written
- temporary snapshot artifacts removed

## Dependency Notes

- `formulate` and `protocol` are mandatory dependencies for `clean`.
- `clean` reads the approved question from `formulate` and the data-usage and visibility rules from `protocol`.
- `clean` does not decide the protocol.
- `clean` does not lock the final executable analysis contract.
- `clean` may discover a protocol mismatch and force backtracking.
- `clean` may discover a formulation mismatch and force backtracking.
- `clean` must never widen the claim boundary.
- Route files may narrow or prohibit cleaning, preprocessing, or derived-variable actions. They may not widen this stage-core.
- The next stage is `examine`, not `eda`.
- `analyze` depends on approved outputs from `formulate`, `protocol`, `clean`, and `examine`.
