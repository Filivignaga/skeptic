---
name: analyze
description: Use after formulate, protocol, clean, and examine to lock one executable analysis contract within upstream constraints and execute it, producing auditable outputs for route-appropriate PCS evaluation without widening the claim boundary or self-revising based on result quality.
---

# /dslc:analyze - Analysis Contract Lock and Execution

**IMPORTANT:** Before executing, read `references/core-principles.md` from the parent `dslc` skill for shared conventions.

`core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

This file is the universal stage-core for `analyze`. It defines the contract-lock-then-execute workflow that applies across question types. Route files may narrow or prohibit actions. They may not widen this stage-core, the approved formulation, or the protocol contract.

`analyze` does not self-revise based on result quality. If sensitivity analyses or challengers diverge from the primary result, `analyze` documents that divergence. `evaluate` decides whether it constitutes instability. `analyze` handles execution failures only: convergence failure, degenerate output, computational infeasibility. Those are execution-viability problems, not result-quality judgments.

## Required Input

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` |

`analyze` requires completed `formulate`, `protocol`, `clean`, and `examine` stages. Do not start from partial upstream context.

## What Prior Outputs This Stage Reads

The stage reads:

- `dslc_documentation/01_formulation.md` - approved question, question type, target quantity or estimand, claim boundary, route candidates, unit of analysis, assumptions
- `dslc_documentation/02_protocol.md` - active route, data usage mode, visibility rules, frozen artifacts, leakage and forbidden-variable rules, validation logic, analyze contract-lock obligations, analyze claim limits, backtracking triggers
- `dslc_documentation/03_cleaning.md` - final visible artifact list, final variable list, population-shift summary, dataset fitness review, open questions, PCS assessment
- `dslc_documentation/04_examination.md` - support registry, analysis handoff, analysis constraints, fragility verdicts, active-route pressure, PCS assessment
- `dslc_documentation/metrics.md` - formulation, protocol, cleaning, and examination scorecards
- `notebooks/01_formulation.ipynb` - rationale trace for the approved question
- `notebooks/02_protocol.ipynb` - rationale trace for visibility, restriction, and validation rules
- `notebooks/03_cleaning.ipynb` - evidence for cleaned artifacts and cleaning judgments
- `notebooks/04_examination.ipynb` - evidence for support characterization and fragility verdicts
- `notebooks/cleaning_functions.py` - reproducible path back to cleaned artifacts when that file exists
- cleaned artifacts produced or named by `clean`
- protocol-defined artifacts under `data/`, `data/splits/`, or another path named in `02_protocol.md`
- `README.md` - confirms prior stage completion

Read all upstream outputs. Keep the approved question, protocol contract, cleaning summary, examination support registry, and analysis handoff in active context throughout the stage. These are not checkboxes. They are the constraints the contract must satisfy.

No additional user input is required if upstream stages are complete. If upstream outputs are incomplete, contradictory, or missing required restrictions, stop and repair the upstream stage. Do not invent analysis permissions around gaps.

## Route Resolution

Before Cycle A, do this in order:

1. Read `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `04_examination.md`, `metrics.md`, `01_formulation.ipynb`, `02_protocol.ipynb`, `03_cleaning.ipynb`, `04_examination.ipynb`, and `README.md`.
2. Resolve exactly one active route from upstream outputs. Use the confirmed question type in `01_formulation.md` and `02_protocol.md` as the anchor. If `02_protocol.md` contradicts it or does not collapse to one route for `analyze`, stop and reopen `protocol`.
3. Load exactly one stage-specific route file:

| Route | File |
|-------|------|
| `descriptive` | `references/routes/descriptive/analyze.md` |
| `exploratory` | `references/routes/exploratory/analyze.md` |
| `inferential` | `references/routes/inferential/analyze.md` |
| `predictive` | `references/routes/predictive/analyze.md` |
| `causal` | `references/routes/causal/analyze.md` |
| `mechanistic` | `references/routes/mechanistic/analyze.md` |

4. Keep that route context in memory for the rest of `analyze` and reuse it across cycles in the same chat.
5. If route context becomes ambiguous mid-stage, reread `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `04_examination.md`, and the same route file before proceeding.
6. If the active route cannot be resolved or the expected route file is missing, stop and route back upstream.

## Precondition Gate

Run this gate before anything else.

Verify all of the following:

- `dslc_documentation/01_formulation.md` exists
- `dslc_documentation/02_protocol.md` exists
- `dslc_documentation/03_cleaning.md` exists
- `dslc_documentation/04_examination.md` exists
- `dslc_documentation/metrics.md` exists
- `notebooks/01_formulation.ipynb` exists
- `notebooks/02_protocol.ipynb` exists
- `notebooks/03_cleaning.ipynb` exists
- `notebooks/04_examination.ipynb` exists
- `README.md` exists
- the cleaned artifacts named in `03_cleaning.md` exist, or `03_cleaning.md` provides a reproducible path for rebuilding them from allowed inputs

Verify `01_formulation.md` contains:

- `## Summary`
- `## Protocol Handoff`
- `## PCS Assessment`
- an approved question
- a question type
- a target quantity or estimand
- a claim boundary
- ordered route candidates
- a unit of analysis
- key assumptions

Verify `02_protocol.md` contains:

- `## Summary`
- `## Protocol Contract`
- `## Frozen Artifacts`
- `## PCS Assessment`
- a confirmed question type
- active route
- data usage mode
- explicit visibility rules for `analyze`
- frozen artifacts required or an explicit statement that none are required
- leakage relevance and forbidden-variable classes
- validation logic required later
- analyze contract-lock obligations
- analyze claim limits
- backtracking triggers

Verify `03_cleaning.md` contains:

- `## Summary`
- `## Dataset Fitness Review`
- `## PCS Assessment`
- final visible artifact list after cleaning
- final variable list after cleaning
- population-shift summary
- assumptions and open questions carried forward

Verify `04_examination.md` contains:

- `## Summary`
- `## Support Registry`
- `## Analysis Handoff`
- `## PCS Assessment`
- supported, weakly supported, and unsupported classification
- active-route pressure (stronger, weaker, unchanged, or no longer defensible)
- analysis constraints
- fragility verdicts (stable enough to inform contract lock, conditionally informative, too fragile to carry analysis-contract weight)

Resolve the active route from `01_formulation.md` plus `02_protocol.md`.

Verify the matching file `references/routes/{route}/analyze.md` exists.

Before Cycle A, derive and record the active visibility set for this stage:

- which cleaned artifacts are visible to `analyze`
- which protocol-created artifacts are visible to `analyze`
- which restricted artifacts are not visible
- what level of access is allowed for each visible artifact

Do not assume held-out artifacts are visible. If `protocol` does not authorize them for this stage, they are out of bounds.

If any required field, artifact, or restriction is missing or contradictory:

- stop
- tell the user exactly what is missing or inconsistent
- route back to `examine`, `clean`, `protocol`, or `formulate` as appropriate

Do not proceed with partial context.

## Guiding Principle

The goal of `analyze` is to lock one executable analysis contract within upstream constraints and execute it, producing auditable outputs for `evaluate`.

Use `analyze` to:

- translate the approved question, protocol contract, and examination handoff into one specific, executable analysis specification
- verify that the locked specification's assumptions hold on the actual data before execution
- execute the locked specification and record all outputs
- execute pre-specified sensitivity analyses and challenger alternatives
- document all deviations between the locked contract and actual execution
- package all outputs for `evaluate` without interpreting whether results are adequate

Do not use `analyze` to:

- redefine the approved question, claim boundary, or protocol visibility rules
- re-explore the data or treat contract lock as a second examination stage
- revive a route that `protocol` already ruled out
- self-revise based on result quality or sensitivity divergence
- choose which results are trustworthy -- that is `evaluate`'s job
- widen the claim boundary
- add post-hoc analyses after seeing primary results
- improvise route-specific permissions beyond the loaded route file and protocol contract

If no viable specification exists within upstream constraints, say so and route the project back upstream.

## Setup

Before Cycle A, create:

1. `notebooks/05_analysis.ipynb` with a header cell containing:
   - stage title
   - date
   - project name
   - approved question
   - question type
   - target quantity
   - claim boundary
   - active route
   - protocol mode
   - visibility rules
   - cleaned artifacts available for analysis
   - examination support summary (supported, weakly supported, unsupported)
   - analysis constraints from examination handoff
   - upstream dependency note: `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `04_examination.md`
   - note: "This notebook is stage-core only. The loaded route file may narrow or prohibit actions. This stage does not widen the claim boundary or self-revise based on result quality."

2. `dslc_documentation/05_analysis.md` with this initial structure:

```markdown
# Analyze: Analysis Contract and Execution

## Dataset
- Source: {raw data file(s)}
- Approved question: {from 01_formulation.md}
- Question type: {from 01_formulation.md}
- Target quantity: {from 01_formulation.md}
- Claim boundary: {from 01_formulation.md}
- Protocol mode: {from 02_protocol.md}
- Active route: {from 02_protocol.md}
- Visibility rules: {short summary from 02_protocol.md}
- Cleaned artifacts: {from 03_cleaning.md}
- Examination support: {one-line from 04_examination.md}
- Date started: {date}

## Upstream Contract
- Approved question: {from formulate}
- Question type: {from formulate}
- Target quantity: {from formulate}
- Claim boundary: {from formulate}
- Active route: {from protocol}
- Protocol mode: {from protocol}
- Visibility constraints: {from protocol}
- Support registry summary: {from examine}
- Analysis constraints: {from examine}

## Analysis Contract
Placeholder. Fill during Cycle A.

## Decision Log

## Deviation Register

## Evaluation Handoff

## PCS Assessment
```

The notebook header must state the approved question, question type, target quantity, claim boundary, active route, protocol mode, visibility rules, examination support summary, and analysis constraints explicitly. `analyze` starts only after those fields are written.

## Stage Map

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Contract Lock | Yes |
| B | Assumption Verification | Yes |
| C | Primary Execution | Yes |
| D | Sensitivity and Challenger Execution | Yes |
| E+ | Follow-up Execution | No |
| F | Results Assembly and Handoff | Yes |

Cycles A, B, C, D, and F are mandatory. E+ is a narrow follow-up window for execution failures, convergence issues, or computational degeneracy discovered during C or D. It is not a license for open-ended re-exploration.

## Execution Gates

Before each cycle, verify the required outputs from prior work exist. If anything is missing, stop and tell the user exactly what is missing.

| Before | Required state |
|--------|----------------|
| Cycle A | Precondition gate passed. Setup files exist. Active visibility set recorded. Route file loaded. |
| Cycle B | `05_analysis.md` contains `### Cycle A` log entry with a locked contract. `05_analysis.ipynb` has Cycle A outputs. User approved the contract. |
| Cycle C | `05_analysis.md` contains `### Cycle B` log entry. Assumptions verified and the locked assumption-failure policy was followed. |
| Cycle D | `05_analysis.md` contains `### Cycle C` log entry. Primary execution outputs exist in the notebook. |
| Cycle F | `05_analysis.md` contains `### Cycle C` and `### Cycle D` log entries. Any approved E+ follow-ups are closed. |
| Post-cycle Phase 1 | Mandatory cycle loop complete. User has indicated the stage is ready for post-cycle review. |

## Contract Template

The analysis contract locked in Cycle A must contain all of the following fields. Route overlays may add route-specific fields but cannot remove universal ones.

| Field | Description | Required |
|-------|-------------|----------|
| Estimand or target quantity | Exact thing being estimated, predicted, or characterized, refined from formulate | All routes |
| Method family | The specific algorithm, estimator, or analytical procedure | All routes |
| Primary specification | Exact variables, functional form, parameters, or configuration | All routes |
| Accuracy metric | How primary output quality is measured | Route-dependent |
| Perturbation plan | What will be perturbed, how, and which axes; route overlay defines specifics | All routes |
| Challenger alternatives | Pre-specified alternative methods as stress tests | All routes |
| Assumption-failure policy | Whether Cycle B is backtrack-only or amendment-allowed; if amendment-allowed, list the pre-approved narrowing fallback(s) | All routes |
| Missing-data rule | How missingness interacts with the locked method at execution time | All routes |
| Subgroup rule | Whether and how to stratify or pool | Route-dependent |
| Claim boundary as-narrowed | Claim boundary inherited from upstream, narrowed if examination flagged limitations | All routes |
| Backtracking triggers | Contract-level conditions that invalidate this specification | All routes |
| Visibility confirmation | Explicit confirmation of which artifacts are used and which are restricted | All routes |

Route-dependent fields are mandatory when the route overlay requires them and optional otherwise. Route overlays may add fields specific to their question type. Examples: causal routes add identification strategy; mechanistic routes add structural model specification; predictive routes add hyperparameter search space.

## Gate Condition Registry

Every evaluation gate has a stable ID used in cycle metrics. The evaluation subagent references these IDs in its structured output.

### Cycle A: Contract Lock

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `A-estimand-locked` | A01 | Estimand or target quantity is specified precisely enough to execute |
| `A-method-locked` | A02, A03, A04 | Method family and primary specification are concrete and executable |
| `A-perturbation-planned` | A05 | Perturbation plan specifies axes, types, and scope |
| `A-challengers-specified` | A06 | Challenger alternatives are pre-specified as stress tests, not open-ended exploration |
| `A-failure-policy-specified` | A07 | The contract specifies whether assumption failures require backtracking or allow named narrowing amendments |
| `A-claim-boundary-respected` | A10 | Contract narrows or preserves the claim boundary from upstream; does not widen |
| `A-visibility-confirmed` | A11 | Contract uses only protocol-approved artifacts and respects restricted ones |
| `A-backtracking-defined` | A08 | Contract-level backtracking triggers are explicit |
| `A-missing-data-specified` | A09 | Missing-data rule is specified for how missingness interacts with the locked method |
| `A-subgroup-specified` | A12 | Subgroup rule is specified when route-dependent |
| `A-support-informed` | A13 | Examination support registry informs each contract field |
| `A-route-overlay-stated` | A14 | Route overlay requirements and prohibitions are stated for each contract field |

### Cycle B: Assumption Verification

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `B-assumptions-checked` | B01, B02 | Route-required assumptions are verified against actual data |
| `B-failure-policy-followed` | B03, B04 | If assumptions failed, the locked assumption-failure policy was followed; any amendment is documented as a narrowing move |
| `B-contract-still-viable` | B05 | The contract, original or amended, remains executable after assumption checks |
| `B-no-widening` | B04 | Any amendment did not widen the claim boundary |

### Cycle C: Primary Execution

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `C-contract-followed` | C01, C02 | Execution followed the locked or amended contract without drift |
| `C-outputs-complete` | C03 | All specified primary outputs are present and documented |
| `C-computational-sound` | C04 | No unresolved convergence failures, numerical issues, or degenerate outputs |
| `C-visibility-respected` | C02 | Execution used only protocol-approved data; no forbidden artifacts touched |
| `C-seeds-recorded` | C05 | Random seeds and parameters are recorded for reproducibility |
| `C-execution-failure-handled` | C06 | If execution failed, the failure is documented as an execution-viability problem with E+ follow-up or backtracking triggered |
| `C-ready-for-sensitivity` | C07 | Outputs are confirmed complete and ready for Cycle D |

### Cycle D: Sensitivity and Challenger Execution

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `D-perturbation-executed` | D01, D02 | All perturbation axes from the contract are executed |
| `D-challengers-executed` | D03, D04 | All pre-specified challengers are executed |
| `D-outputs-separated` | D02, D04 | Primary, sensitivity, and challenger outputs are explicitly separated |
| `D-no-post-hoc` | D02, D04 | No sensitivity analyses or challengers were added after seeing primary results |
| `D-seeds-recorded` | D05 | Random seeds and parameters recorded for all sensitivity and challenger runs |
| `D-comparison-produced` | D06 | Comparison table is produced with raw comparison and no interpretation of divergence as instability |
| `D-execution-failure-handled` | D07 | If any perturbation or challenger could not execute, the failure is documented with E+ follow-up or backtracking triggered |
| `D-divergence-documented` | D08 | Material differences between primary and perturbation or challenger results are documented as findings for evaluate |

### Cycle F: Results Assembly and Handoff

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `F-deviation-register-complete` | F01 | Every deviation between contract and actual execution is documented with cause and impact |
| `F-outputs-packaged` | F02 | Primary, sensitivity, and challenger outputs are assembled in one evaluation-ready bundle |
| `F-no-interpretation` | F02 | Assembly does not contain result-quality judgments or claim-scope assertions |
| `F-claim-boundary-stated` | F03 | Final claim boundary as-narrowed through the stage is explicitly stated |
| `F-evaluate-ready` | F04, F05, F06 | The package contains everything `evaluate` needs without re-running the analysis |
| `F-no-result-judgments` | F07 | Assembly does not contain result-quality judgments or claim-scope assertions |
| `F-handoff-stated` | F08 | Explicit handoff statement that the next stage is evaluate |

## Cycle Protocol

Apply this protocol to every cycle.

### Step 0: Progress Indicator

At the start of each cycle, print:

`"Analyze stage: Cycle {X} ({focus}) - {mandatory/optional} - {ordinal} of 5 mandatory cycles"`

For post-cycle phases, print:

`"Analyze stage: Post-cycle Phase {N} ({name})"`

### Step 1: Setup and Execution

- Claude reads existing notebook outputs. Skip this only for Cycle A beyond the header.
- Claude reads `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, and `04_examination.md` before every cycle. Treat the approved question, question type, claim boundary, active route, protocol mode, visibility rules, analysis constraints, support registry, and prohibitions as hard constraints.
- Claude reuses the route context already loaded at stage start from `references/routes/{route}/analyze.md`.
- If route context becomes ambiguous, Claude rereads `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `04_examination.md`, and the same route file before proceeding.
- If the active route cannot be confirmed or the expected route file is missing, stop and reopen upstream. Do not guess.
- Claude identifies which cleaned and protocol-created artifacts the current cycle is allowed to use. If visibility is unclear, stop and reopen `protocol` rather than guessing.
- Claude writes notebook cells with markdown reasoning before code.
- Claude executes the notebook and presents key outputs to the user (see `core-principles.md` Notebook Execution).

### Step 2: Human Review

- Interactive mode: the user reviews the outputs presented by Claude, provides questions or concerns, and Claude responds before proceeding.
- Auto mode: replace this step with the self-review loop from `references/auto-mode.md`. Claude may self-correct within the configured budget, then proceeds without waiting unless an escalation trigger fires.

### Step 3: Subagent Review

Claude reads the notebook outputs, then dispatches two subagents in parallel.

**Research subagent:**

```text
Agent(
  description="Research for Analyze Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a methodological research assistant for a DSLC analyze stage.

  Context:
  - Approved question: "{approved question}"
  - Question type: {question type}
  - Target quantity: {target quantity}
  - Claim boundary: {claim boundary}
  - Active route: {route}
  - Protocol mode: {protocol mode}
  - Visibility rules: {visibility rules}
  - Examination support summary: {from 04_examination.md}
  - Analysis constraints from examine: {constraints}
  - Current notebook findings: {findings from this cycle}
  - User observations: {if any}

  Answer these research questions for Cycle {X} ({focus}):
  {insert cycle-specific research questions}

  Rules:
  - Stay inside the approved question, protocol, and active route.
  - Focus on methodological guidance, not domain discovery.
  - If a question does not apply, say "not applicable" with a one-line reason.
  - Cite sources for claims that would change a contract or execution decision.

  Return concise findings organized by research question.
  """
)
```

**Evaluation subagent:**

```text
Agent(
  description="Evaluation for Analyze Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a DSLC analyze-stage cycle.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/05_analysis.md
  2. {projects_root}/{project-name}/{notebooks_dir_name}/05_analysis.ipynb
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  4. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.md
  5. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.md
  6. {projects_root}/{project-name}/{docs_dir_name}/04_examination.md

  Cycle focus: {focus description}
  User observations: {if any}

  Applicable gates for this cycle:
  {list gate IDs and their depends_on checklist items}

  Before evaluating gates, verify that all checklist items for this cycle were
  answered with evidence in the notebook. If any checklist item was not answered,
  the gates that depend on it auto-fail.

  Task:
  1. For each checklist item in this cycle: verify it was answered with evidence
     in the notebook. If not, list the unanswered items and auto-fail dependent gates.
  2. Evaluate each applicable gate using notebook evidence.
  3. Answer cycle-specific evaluation questions from notebook evidence.
  4. Identify up to 3 findings that determine whether the cycle should pass.
  5. Flag any move that widens the claim boundary, violates protocol, adds post-hoc analyses, or drifts from the locked contract.
  6. Recommend: pass / iterate on {topic} / acknowledge gap / backtrack to {stage}.
  7. Read the Claim Boundary Registry from `metrics.md`. Verify that the locked
     contract and all execution outputs use only verbs from `verbs_allowed`,
     stay within `scope`, and respect `generalization_limit`. Any violation is
     a BLOCKING defect. If analysis narrows the claim, append to `narrowing_log`.

  Output format (follow this exact structure in order):

  EVALUATION: Cycle {X} - {focus}

  CHECKLIST VERIFICATION:
  For each checklist item in this cycle:
  - {item_id}: ANSWERED / NOT ANSWERED - [evidence location or gap]
  Auto-failed gates due to unanswered checklist items: [{gate_ids}] or "none"

  DEFECT SCAN:
  List every defect, gap, or weakness in this cycle's work. Minimum: 1 defect,
  or "No defects found" with a 2-sentence justification of why the work has
  no weaknesses (this justification is itself auditable).
  Categories to scan: contract drift, post-hoc analysis additions, claim-boundary
  widening, protocol violations, forbidden variable usage, unauthorized data
  access, unregistered specification changes.
  - Defect 1: [description with evidence]
  - Defect 2: [description with evidence]

  SEVERITY CLASSIFICATION:
  For each defect: BLOCKING (must fix before proceeding) or NON-BLOCKING
  (noted, acceptable for this cycle).
  - Defect 1: BLOCKING / NON-BLOCKING - [one-line reason]
  - Defect 2: BLOCKING / NON-BLOCKING - [one-line reason]

  GATE ASSESSMENTS:
  - {gate_id}: PASS / FAIL - [evidence] - depends_on: [{checklist_ids}]
  (list every applicable gate)

  Key findings:
  - [finding]
  - [finding]
  - [finding]

  Contract fidelity: {contract followed / drift detected / amendment needed}
  Claim boundary: {unchanged / narrowed / WIDENED (flag)}
  Gaps remaining: [list, or "none"]
  Recommended next step: pass / iterate / acknowledge gap / backtrack to {stage}
  Recommended follow-up cycle: [topic and why] / None

  VERDICT:
  PASS = zero BLOCKING defects, zero FAIL gates, and all checklist items answered.
  FAIL = one or more BLOCKING defects, FAIL gates, or unanswered checklist items
         with dependent gates.
  Verdict: [PASS/FAIL]
  Blocking defects: [count]
  Failed gates: [count]
  Unanswered checklist items with dependent gates: [count]

  Be objective. Not harsh, not lenient.
  """
)
```

### Step 4: Decision

When both subagents return, Claude synthesizes them into one cycle assessment. Do not present disconnected subagent reports as if they were the stage decision. Log the raw outputs for traceability.

Count the blocking failures from the evaluation subagent output: blocking defects plus gates with verdict FAIL. Then apply the decision matrix.

**Decision matrix:**

| blocking_failures | forward actions allowed | note |
|-------------------|------------------------|------|
| 0 | pass, iterate | cycle meets minimum bar |
| > 0 | iterate, acknowledge gap (with written justification) | pass is blocked until blocking failures are resolved or justified |

**Always-available actions (regardless of blocking_failures):**

- **Reopen examine** -> stop and reopen `examine`
- **Reopen protocol** -> stop and reopen `protocol`
- **Reopen formulate** -> stop and reopen `formulate` plus `protocol`
- **Data insufficient** -> request more data or archive
- **User override** -> user states the specific reason the FAIL is incorrect, logged as `override: {reason}`, forward actions unlock

Interactive mode: present the synthesized assessment to the user with the allowed actions from the matrix. The user decides. After every cycle, force an explicit decision. Do not silently continue.

Auto mode: apply the autonomous decision protocol from `references/auto-mode.md`, log the rationale, and continue without waiting unless an escalation trigger fires.

**Cycle A special rule:** Cycle A (Contract Lock) requires explicit user approval of the contract before Cycle B starts. The decision matrix applies, but passing Cycle A additionally requires explicit contract approval. Do not auto-finalize the contract without that explicit approval.

### Step 5: Log

Immediately after each cycle decision, append to `dslc_documentation/05_analysis.md`:

```markdown
### Cycle {X}: {Focus}
- **Visible artifacts used:** {artifact list}
- **What we did:** {notebook cells run, computations performed}
- **Research findings:** {key findings from research subagent}
- **Evaluation verdict:** PASS / FAIL
- **Checklist items answered:** {answered}/{total} for this cycle
- **Gate assessments:** {gate_id}: PASS/FAIL for each applicable gate
- **Blocking failures:** {count} (defects: {n}, failed gates: {n})
- **Decision matrix action:** {pass / iterate / acknowledge gap / override}
- **Contract state:** {locked / amended from {original} to {amended} / unchanged}
- **Deviations:** {none / list with cause}
- **Claim boundary:** {unchanged / narrowed to {new boundary} because {reason}}
- **Protocol check:** {within bounds / protocol mismatch / formulation mismatch}
- **Gaps:** {remaining gaps, if any}
- **Decision:** {pass / iterate / acknowledge gap / backtrack to {stage}}
```

Also append structured cycle metrics to `dslc_documentation/metrics.md`. Create the section `## Analysis` if it does not yet exist.

```markdown
**Cycle metrics:**
- iterations: {n}
- verdict: PASS/FAIL (on iteration {n})
- checklist_items: {answered}/{total}
- gates: [{gate_id}: PASS/FAIL, ...]
- blocking_failures: {n} (defects: {n}, failed_gates: {n})
- decision_matrix_action: {pass / iterate / acknowledge gap / override}
- research_sources_returned: {n}
- evaluation_verdict_aligned: yes/no/partial/indeterminate
- contract_amended: yes/no
- deviations: {n}
- claim_boundary_narrowed: yes/no
```

## Cycle A: Contract Lock

**Focus:** Translate the approved question, protocol contract, examination support registry, and analysis handoff into one executable analysis specification. Lock every material decision before execution begins.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| A01 | Is the estimand or target quantity stated precisely enough to execute without further specification decisions? | never |
| A02 | Is the method family identified with upstream evidence justifying the choice? | never |
| A03 | Is the primary specification (variables, functional form, parameters, configuration) fully concrete? | never |
| A04 | Is the accuracy metric defined (if route-dependent, is it required by the route overlay)? | route overlay does not require it |
| A05 | Is the perturbation plan specified with axes, types, and scope? | never |
| A06 | Are challenger alternatives pre-specified as structurally different stress tests (not cosmetic variation)? | never |
| A07 | Is the assumption-failure policy explicit (backtrack_only or amendment_allowed with named fallbacks)? | never |
| A08 | Are contract-level backtracking triggers explicit? | never |
| A09 | Is the missing-data rule specified for how missingness interacts with the locked method? | never |
| A10 | Is the claim boundary as-narrowed stated, preserving or narrowing (never widening) the upstream boundary? | never |
| A11 | Is visibility confirmation explicit, listing which artifacts are used and which are restricted? | never |
| A12 | Is the subgroup rule specified (if route-dependent, is it required by the route overlay)? | route overlay does not require it |
| A13 | Does the examination support registry inform each contract field (supported, weakly supported, unsupported)? | never |
| A14 | Are route overlay requirements and prohibitions stated for each contract field? | never |

Claude writes notebook cells using this default sequence:

1. Restate the approved question, question type, target quantity, claim boundary, active route, protocol mode, and visibility rules.
2. Restate the examination support registry: what the data supports, weakly supports, and does not support.
3. Restate analysis constraints and fragility verdicts from the examination handoff.
4. Draft the analysis contract using the contract template. For each field:
   - state the proposed value
   - state the upstream evidence justifying it
   - state what the route overlay requires or prohibits
5. Specify the perturbation plan. The route overlay defines what perturbation means for this route. The stage-core requires that a plan exists and specifies axes, types, and scope.
6. Specify challenger alternatives. These are pre-specified stress tests, not open-ended exploration. Each challenger must be structurally different enough from the primary to expose genuine weaknesses.
7. Specify the assumption-failure policy for Cycle B:
   - `backtrack_only`, or
   - `amendment_allowed` with named pre-approved narrowing fallback(s)
8. Specify contract-level backtracking triggers.
9. Present the complete contract to the user for approval.

Do not execute anything in this cycle. This cycle produces a locked specification. Execution begins in Cycle C after assumption verification in Cycle B.

Do not treat contract lock as a second examination stage. The examination handoff tells you what the data can support. The contract lock translates that into one executable specification within those constraints.

**Research questions:**

- What method families are standard for this question type and data profile, given the examination support registry?
- What are known limitations of the proposed primary method under conditions matching the visible data?
- What perturbation axes matter most for this route and domain?
- What challenger alternatives would expose genuine weaknesses rather than cosmetic variation?

The evaluation subagent checks:
1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail.
2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle B: Assumption Verification

**Focus:** Verify that the locked contract's assumptions hold on the actual cleaned data. If assumptions fail, follow the locked assumption-failure policy before execution begins.

The stage-core defines this cycle slot and the universal protocol. The loaded route overlay defines what assumptions must be checked for the active route and locked method. Do not duplicate or improvise route-specific assumption lists in stage-core.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| B01 | Are all route-required assumptions identified from the route overlay for the locked method? | never |
| B02 | Is each required assumption checked against actual cleaned, visible data with a reported verdict (pass, marginal, fail)? | never |
| B03 | If all assumptions passed, is the contract confirmed unchanged and ready for execution? | any assumption failed |
| B04 | If any assumption failed, was the locked assumption-failure policy followed (backtrack_only triggers backtrack; amendment_allowed invokes only named pre-approved narrowing fallback)? | all assumptions passed |
| B05 | If amended, is the amended contract still executable and the claim boundary not widened? | no amendment occurred |

Claude writes notebook cells using this default sequence:

1. State which assumptions the route overlay requires checking for the locked method.
2. Run each required assumption check on the actual cleaned, visible data.
3. For each assumption, report: pass, marginal, or fail.
4. If all assumptions pass: confirm the contract is unchanged and ready for execution.
5. If any assumption fails:
   - follow the locked assumption-failure policy
   - if the policy is `amendment_allowed`, invoke only the named pre-approved narrowing fallback, document the amendment, and verify the amended contract is still executable
   - if the policy is `backtrack_only`, or no named fallback remains viable, trigger backtracking to `protocol`

**Research questions:**

- What assumption violations are common for this method applied to this data profile?
- When assumption violations are found, what is the standard domain response -- transform, switch method, or proceed with caveats?
- Are the route-required assumption checks comprehensive for this specification?

The evaluation subagent checks:
1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail.
2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle C: Primary Execution

**Focus:** Execute the locked or amended contract. Record all outputs. Document any execution failures.

The stage-core requires that execution follows the locked contract, all outputs are documented, and all computational issues are recorded. The route overlay defines the internal execution sequence for this route.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| C01 | Is the contract being executed stated explicitly (method, specification, parameters, visible artifacts)? | never |
| C02 | Was execution performed on the approved visible data only, with no forbidden artifacts touched? | never |
| C03 | Are all specified primary outputs present and documented (point estimates, intervals, predictions, diagnostics, model parameters as applicable)? | never |
| C04 | Are computational diagnostics recorded (convergence status, runtime, numerical warnings, memory usage)? | never |
| C05 | Are random seeds and all parameters needed for exact reproduction recorded? | never |
| C06 | If execution failed, is the failure documented as an execution-viability problem (not a result-quality judgment) with E+ follow-up or backtracking triggered? | execution succeeded |
| C07 | Are outputs confirmed complete and ready for Cycle D (no interpretation of results in this cycle)? | never |

Claude writes notebook cells using this default sequence:

1. State the contract being executed: method, specification, parameters, visible artifacts.
2. Execute the locked specification on the approved visible data.
3. Record all outputs: point estimates, intervals, predictions, diagnostics, model parameters, or whatever the route and method produce.
4. Record computational diagnostics: convergence status, runtime, numerical warnings, memory usage when relevant.
5. Record random seeds and all parameters needed for exact reproduction.
6. If execution fails (convergence failure, degenerate output, computational infeasibility):
   - document the failure
   - this is an execution-viability problem, not a result-quality judgment
   - trigger E+ follow-up or backtracking as appropriate
7. If execution succeeds, confirm outputs are complete and ready for Cycle D.

Do not interpret results in this cycle. Do not assess whether the output is "good" or "bad." Execute, record, and move on.

**Research questions:**

- What execution diagnostics are standard for this method family?
- What failure modes are known for this method under conditions matching the data profile?
- Are the recorded computational diagnostics sufficient to distinguish completed execution from numerical or implementation failure?

The evaluation subagent checks:
1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail.
2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle D: Sensitivity and Challenger Execution

**Focus:** Execute the perturbation plan and challenger alternatives locked in the contract. Record all outputs. Separate primary, sensitivity, and challenger results explicitly.

The stage-core requires that all contract-specified perturbations and challengers are executed, outputs are separated, and nothing is added post-hoc. The route overlay defines what perturbation means for this route.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| D01 | Is the perturbation plan from the contract restated (axes, types, scope)? | never |
| D02 | Is each perturbation axis executed with outputs recorded separately from primary results? | never |
| D03 | Are the challenger alternatives from the contract restated? | never |
| D04 | Is each challenger executed with outputs recorded separately from primary and perturbation results? | never |
| D05 | Are random seeds and parameters recorded for all sensitivity and challenger runs? | never |
| D06 | Is a comparison table produced (primary vs each perturbation axis vs each challenger) with raw comparison and no interpretation of whether divergence constitutes instability? | never |
| D07 | If any perturbation or challenger could not execute, is the failure documented with E+ follow-up or backtracking triggered? | all executed successfully |
| D08 | If any perturbation or challenger produced materially different results, is it documented as a finding for evaluate (not revised, not interpreted as instability)? | no material differences |

Claude writes notebook cells using this default sequence:

1. State the perturbation plan from the contract: axes, types, scope.
2. Execute each perturbation axis. Record outputs separately from primary results.
3. State the challenger alternatives from the contract.
4. Execute each challenger. Record outputs separately from primary and perturbation results.
5. Record random seeds and parameters for all sensitivity and challenger runs.
6. Produce a comparison table: primary result versus each perturbation axis and each challenger. Report the raw comparison without interpreting whether divergence constitutes instability. That is `evaluate`'s job.
7. If any perturbation or challenger cannot execute (computational infeasibility, data limitation):
   - document the failure
   - trigger E+ follow-up or backtracking as appropriate
8. If a perturbation or challenger produces materially different results from the primary:
   - document it as a finding
   - do not revise the primary result
   - do not interpret whether this constitutes instability
   - flag it for `evaluate`

**Research questions:**

- What execution failure modes are common for these perturbation axes and challenger methods?
- Are the perturbation and challenger outputs recorded in a way that supports like-for-like comparison?
- Do any perturbation or challenger runs show diagnostic signs of execution artifact rather than completed execution?

The evaluation subagent checks:
1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail.
2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycles E+: Follow-up Execution

Use an E+ follow-up only when a material execution issue remains unresolved after Cycles C or D.

An E+ cycle must be narrow and issue-specific. Define only:

- the unresolved execution issue (convergence failure, degenerate output, computational infeasibility, missing-data cascade)
- why it materially affects the locked contract's viability
- what evidence is still needed
- what concrete resolution the follow-up targets

Each E+ cycle must define its own checklist items scoped to the specific execution failure. Use IDs starting with `E1xx` for the first follow-up, `E2xx` for the second, and so on. The checklist must cover: the specific failure being addressed, the evidence gathered, and whether the resolution restores contract viability.

Use E+ for issues such as:

- resolving a convergence failure by adjusting optimization parameters within the contract
- re-executing a challenger that hit a computational limit with adjusted settings
- investigating whether a degenerate output reflects a data problem or an algorithm problem
- re-running a perturbation axis that produced an execution artifact

Do not turn E+ into unrestricted re-exploration, result-quality assessment, or post-hoc analysis. If the issue is actually an examination, cleaning, protocol, or formulation mismatch, route back upstream.

## Cycle F: Results Assembly and Handoff

**Focus:** Assemble all outputs into a structured evaluation-ready package. Document all deviations. Hand off to `evaluate` without interpretation.

This cycle produces the structured handoff that `evaluate` must use when performing route-appropriate PCS review. It packages outputs. It does not judge them.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| F01 | Is the deviation register complete, systematically comparing the locked contract against actual execution with cause and impact for each deviation (or explicit "no deviations")? | never |
| F02 | Are primary, sensitivity, and challenger outputs assembled into one structured package with explicit separation maintained? | never |
| F03 | Is the claim boundary as-narrowed explicitly stated (narrower or equal to what entered analyze, never wider)? | never |
| F04 | Are contract amendments listed with triggers and confirmation of narrowing? | no amendments occurred |
| F05 | Are flags for evaluate listed (perturbation divergences, challenger contradictions, computational issues, claim-boundary narrowing, unresolved risks)? | never |
| F06 | Is the Evaluation Handoff section drafted with all required subsections (Contract Summary, Execution Summary, Deviation Register, Contract Amendments, Flags for Evaluate, Handoff Discipline)? | never |
| F07 | Does the assembly avoid result-quality judgments or claim-scope assertions? | never |
| F08 | Is there an explicit handoff statement that the next stage is evaluate? | never |

Claude writes notebook cells using this default sequence:

1. **Deviation Register** (mandatory first step). Systematically compare the locked contract against what actually executed. For each deviation:
   - what changed
   - whether the deviation was forced (execution failure) or chosen (assumption fallback)
   - cause
   - potential impact on error control and claim credibility
   - If no deviations: state "no deviations" explicitly.
2. Assemble primary outputs, sensitivity outputs, and challenger outputs into one structured package. Maintain explicit separation between primary, sensitivity, and challenger.
3. State the claim boundary as it stands after the full analysis. It may be narrower than what entered `analyze`. It must not be wider.
4. List contract amendments with triggers and confirmation of narrowing.
5. List flags for `evaluate`:
   - perturbation axes where outputs diverged materially
   - challengers where results contradicted primary
   - computational issues that may affect reliability
   - any claim-boundary narrowing that occurred during the stage
   - unresolved risks carried forward
6. Draft the `## Evaluation Handoff` section in `05_analysis.md`:

```markdown
## Evaluation Handoff

### Contract Summary
- Estimand or target quantity: {from contract}
- Method family and primary specification: {from contract}
- Perturbation plan: {what was planned}
- Challengers: {what was planned}
- Claim boundary as-narrowed: {final boundary}

### Execution Summary
- Primary outputs: {point estimates, intervals, predictions, diagnostics}
- Sensitivity outputs: {perturbation results by axis}
- Challenger outputs: {alternative method results}
- Computational issues: {list, or "none"}

### Deviation Register
- {deviation}: {forced/chosen} - {cause} - {potential impact}
- (or "no deviations")

### Contract Amendments
- {amendment}: {trigger} - {what changed} - {narrowing confirmed}
- (or "no amendments")

### Flags for Evaluate
- {perturbation axes where outputs diverged materially}
- {challengers where results contradicted primary}
- {computational issues that may affect reliability}
- {claim-boundary narrowing during analyze}
- {unresolved risks carried forward}

### Handoff Discipline
- Next stage: evaluate
- Do not treat analysis outputs as confirmed claims
- Do not treat challenger divergence as resolved -- evaluate must adjudicate
- Do not widen the claim boundary
```

7. End with an explicit handoff statement: next stage is `evaluate`. Do not treat the handoff itself as evaluation.

**Research questions:**

- What evaluation-ready packaging standards exist for this route and method family?
- Are there domain-standard benchmarks or baselines that contextualize the magnitude of results without making claims?

The evaluation subagent checks:
1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail.
2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Backtracking Trigger Registry

These are conditions discovered during `analyze` that force a return upstream. Separate from protocol-level backtracking triggers.

| Trigger | Discovered during | Return to |
|---------|-------------------|-----------|
| No viable specification exists within upstream constraints for this data profile and claim boundary | Cycle A | `examine` if support was overestimated, or `protocol` if constraints are too tight |
| Assumptions fail and the locked assumption-failure policy leaves no viable executable contract | Cycle B | `protocol` to revise what methods are admissible |
| Cleaned data has a structural problem not caught in `clean` or `examine` | Cycle C | `clean` |
| Perturbation plan cannot be executed due to data volume, structure, or computational limits | Cycle D | `protocol` to revise perturbation requirements, or contract amendment |
| Contract required protocol-forbidden data or visibility not caught in Cycle A | Any cycle | `protocol` |
| Question type or claim boundary needs widening to produce any meaningful result | Any cycle | `formulate` plus `protocol` |

All challengers producing materially different results from the primary is NOT a backtracking trigger. It is a finding that `analyze` documents and `evaluate` adjudicates. `analyze` does not self-revise based on result quality.

When backtracking occurs, preserve the earlier record and mark it as superseded. Do not pretend the earlier work never happened.

## Ending the Cycle Loop

The cycle loop ends when:

- mandatory cycles A, B, C, D, and F are complete
- all approved E+ follow-ups are closed
- interactive mode: the user indicates the stage is ready for post-cycle review
- auto mode: the mandatory cycles and approved follow-ups are complete, so the stage advances to stage-close review under `references/auto-mode.md`

Do not finalize because the stage "seems good enough." Require an explicit decision.

## Post-cycle Evaluation

After the cycle loop, move through three phases. Interactive mode waits for user review between phases. Auto mode follows `references/auto-mode.md` and pauses only on escalation triggers or the final stage-boundary approval.

| Before | Required state |
|--------|----------------|
| Phase 1: Reproducibility Verification | Cycle loop complete. `## Evaluation Handoff` has draft content. |
| Phase 2: PCS Readiness Review | Reproducibility re-run passed. Results confirmed in `05_analysis.md`. |
| Phase 3: Finalization | `## PCS Assessment` section exists in `05_analysis.md`. |

### Phase 1: Reproducibility Verification

**Goal:** Verify the entire analysis reproduces from cleaned artifacts plus protocol-defined frozen artifacts plus the locked contract.

This is a full re-run, not a structural check. If the analysis is too slow to re-run, that is a computability problem `evaluate` must know about.

Claude writes notebook cells that:

1. Start from cleaned artifacts and protocol-defined frozen artifacts.
2. Re-execute the full analysis pipeline: primary execution, all sensitivity axes, all challengers.
3. Compare re-run outputs against the originals.
4. Report for each output: exact match, numerical-tolerance match, or mismatch.

If mismatch: the stage cannot finalize. Debug the discrepancy before proceeding.

If the re-run passes: record the runtime and confirm reproducibility in `05_analysis.md`.

Required outputs in `05_analysis.md`:

- re-run status: pass or fail
- runtime
- any numerical tolerance applied and justification
- mismatch details if any

### Phase 2: PCS Readiness Review

After the reproducibility results are complete under the active execution mode, dispatch a PCS review subagent:

```text
Agent(
  description="PCS review of analyze stage",
  prompt="""
  You are a PCS reviewer for a DSLC analyze stage.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  2. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.md
  3. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.md
  4. {projects_root}/{project-name}/{docs_dir_name}/04_examination.md
  5. {projects_root}/{project-name}/{docs_dir_name}/05_analysis.md
  6. {projects_root}/{project-name}/{notebooks_dir_name}/05_analysis.ipynb

  Evaluate only the incremental risk introduced by analysis execution.
  Do not restate the full formulation, protocol, cleaning, or examination reviews.

  Answer these questions:

  1. PREDICTABILITY: Did execution produce outputs that evaluate can
     run reality checks against? Are primary and sensitivity outputs
     structured for comparison?

  2. STABILITY: Are perturbation and challenger outputs present and
     separated so evaluate can assess whether results survive
     reasonable alternatives? Were perturbation axes adequate for
     the route?

  3. COMPUTABILITY: Can another analyst reproduce the full analysis
     from the locked contract, cleaned artifacts, and notebook?
     Did the reproducibility re-run pass?

  4. CONTRACT FIDELITY: Did execution follow the locked contract?
     Are deviations documented with cause and impact?

  5. MAIN RISK DRIVER: What contract choice or execution choice
     introduced the most risk, if any?

  6. REOPEN CYCLE: Should analyze reopen a cycle or route back
     upstream? Yes or no, and why.

  Output format:

  PREDICTABILITY: ACCEPTABLE / CONCERN
  - [fact-based finding]

  STABILITY: ADEQUATE / CONCERN
  - [fact-based finding]

  COMPUTABILITY: ADEQUATE / CONCERN
  - [fact-based finding]

  CONTRACT FIDELITY: MAINTAINED / CONCERN
  - [fact-based finding]

  MAIN RISK DRIVER:
  - [choice or "none"]

  REOPEN CYCLE: YES / NO
  - [why]
  """
)
```

After the subagent returns:

1. Append the PCS assessment to `05_analysis.md` under `## PCS Assessment`.
2. Interactive mode: present the assessment to the user.
3. Interactive mode: user decides:
   - **Satisfied** -> proceed to Phase 3
   - **Valid concern** -> reopen the relevant cycle or route upstream
   - **Disagree** -> log the override and proceed
4. Auto mode: record the PCS assessment in the stage summary, apply non-blocking fixes autonomously, and escalate only if the review exposes a blocking concern or the user rejects the stage at the stage boundary.

The subagent advises. It does not silently widen scope or bypass a blocking concern.

### Phase 3: Finalization

After the PCS review clears, or the user overrides it:

1. Append an Analysis Scorecard to `dslc_documentation/metrics.md` under `## Analysis`.

```markdown
### Analysis Scorecard
| metric | value | source |
|--------|-------|--------|
| Checklist items answered | {answered}/{total} | cycle logs |
| Mandatory cycles completed | {n}/5 | cycle logs |
| Follow-up cycles (E+) | {n} ({list topics}) | cycle logs |
| Total iterations (all cycles) | {n} ({cycle}: {n}, ...) | cycle logs |
| Blocking failures total | {n across all cycles} | gate registry |
| Blocking failures resolved by iteration | {n} | gate registry |
| Blocking failures resolved by override | {n} ({list override reasons}) | gate registry |
| Contract amendments | {n} ({list}) | deviation register |
| Assumption checks passed | {n}/{total} | Cycle B output |
| Sensitivity divergences | {n} | Cycle D output |
| Challenger alternatives run | {n} | Cycle D output |
| Reproducibility verified | {yes / no} | Phase 1 |
| PCS verdict | {from PCS subagent} | Phase 2 |
| PCS user decision | {satisfied / valid concern acted on / override with reason} | Phase 2 |
```

2. Update `05_analysis.md` with `## Summary` containing:
   - locked contract summary (method, specification, key parameters)
   - contract amendments and their triggers
   - primary outputs
   - sensitivity and challenger outputs
   - deviation register
   - claim boundary as-narrowed
   - unresolved risks carried forward

3. Complete `## Evaluation Handoff` so it contains the full structured handoff as specified in Cycle F.

4. Update `README.md`:

```markdown
## Analyze [COMPLETE]
Type: {question type}
Active route: {route}
Method: {method family and primary specification, one line}
Contract amendments: {n, or "none"}
Deviations: {n, or "none"}
Claim boundary: {unchanged from examine / narrowed to {new boundary}}
Perturbation axes: {n} executed
Challengers: {n} executed
Reproducibility: pass - {runtime}
Next: Evaluate - route-appropriate PCS review of outputs and claims
```

5. Present the final artifacts to the user and state that the next stage is `evaluate`.

Do not send the user to `evaluate`, `communicate`, or back to `examine` unless the stage actually found a failure that requires backtracking.

## Dependency Notes

- `formulate`, `protocol`, `clean`, and `examine` are mandatory dependencies for `analyze`.
- `protocol` decides what `analyze` may see, what methods are admissible, and what the claim limits are.
- `examine` decides what the data can support and hands off analysis constraints, fragility verdicts, and route pressure.
- `analyze` locks one executable analysis contract within those constraints and executes it. It does not widen the claim boundary or self-revise based on result quality.
- Route files may narrow or prohibit actions. They may not widen this stage-core, the protocol contract, or the claim boundary.
- If the route file cannot be loaded, stop. That is missing architecture.
- `evaluate` depends on approved outputs from `formulate`, `protocol`, `clean`, `examine`, and `analyze`.
- The next stage is `evaluate`.
- `analyze` may narrow the claim boundary. It may not widen it.
- `analyze` may amend the contract in Cycle B only when the locked assumption-failure policy explicitly allows named pre-approved narrowing amendments. It may not redesign the contract after seeing results.
- `analyze` may reveal that upstream stages must be reopened. If that happens, preserve the audit trail and route back explicitly.
- Put reusable functions in companion `.py` or `.json` files when they must survive across stages.
