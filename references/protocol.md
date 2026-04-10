---
name: protocol
description: Use after formulate to lock the project rules of the game before clean starts. Second stage of the Skeptic.
---

# /skeptic:protocol - Project Rules of the Game

**IMPORTANT:** Before executing, read `references/core-principles.md` from the parent `skeptic` skill for shared conventions.

`core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Required Input

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` |

## What Prior Outputs This Stage Reads

The stage reads:
- `skeptic_documentation/01_formulation.md` - approved question, question type, target quantity, claim boundary, route candidates, assumptions, protocol handoff
- `skeptic_documentation/metrics.md` - formulation scorecard
- `notebooks/01_formulation.ipynb` - cycle evidence and rationale trace
- `README.md` - confirms formulate completion

No new user inputs are required if formulate is complete. If the formulate handoff is incomplete or contradictory, stop and repair formulate first. Do not invent protocol rules around missing upstream decisions.
If formulate did not establish a usable problem framing, success criteria, or prior-art implications, stop and repair formulate first.

## Route Resolution

Before Cycle A, do this in order:

1. Read `01_formulation.md`, `metrics.md`, `01_formulation.ipynb`, and `README.md`.
2. Resolve exactly one active route from `01_formulation.md`. Use the approved question type as the primary route signal. Use the ordered route candidates and protocol handoff only to confirm that the question type was recorded coherently.
3. Load exactly one stage-specific route file:

| Route | File |
|-------|------|
| `descriptive` | `references/routes/descriptive/protocol.md` |
| `exploratory` | `references/routes/exploratory/protocol.md` |
| `inferential` | `references/routes/inferential/protocol.md` |
| `predictive` | `references/routes/predictive/protocol.md` |
| `causal` | `references/routes/causal/protocol.md` |
| `mechanistic` | `references/routes/mechanistic/protocol.md` |

4. Keep that route context in memory for the rest of `protocol` and reuse it across cycles in the same chat.
5. If route context becomes ambiguous mid-stage, reread the upstream outputs and the same route file before proceeding.
6. If the active route cannot be resolved or the expected route file is missing, stop and route back to `/skeptic:formulate`.

## What This Stage Does

This stage defines how the approved question may be answered.

This stage must:
- resolve exactly one active route from formulate outputs and use the loaded route file to narrow protocol decisions
- choose the project-level data usage mode
- decide whether frozen artifacts are required, and create them here if required
- define admissible evidence logic for later stages
- define leakage relevance and forbidden variable classes
- decide whether confounding, identification, time order, grouping, hierarchy, or interference materially constrain the project
- define the validation logic and uncertainty expectations later stages must honor
- define stage prohibitions and backtracking triggers
- produce `skeptic_documentation/02_protocol.md` and `notebooks/02_protocol.ipynb`

This stage must not:
- choose the exact estimator, model, or algorithm
- write the final analysis contract
- replace `analyze`'s contract lock
- hardcode predictive assumptions into universal rules

## Precondition Gate

Verify these files exist before doing anything else:
- `skeptic_documentation/01_formulation.md`
- `skeptic_documentation/metrics.md`
- `notebooks/01_formulation.ipynb`
- `README.md`

Verify `01_formulation.md` contains all of the following:
- `## Summary`
- `## Protocol Handoff`
- `## PCS Assessment`
- an approved question
- a question type
- a target quantity or estimand
- a claim boundary
- ordered route candidates
- key assumptions
- success criteria, baseline, and error-cost asymmetry
- prior-art implications for scope or project order
- if inferential or causal, hypothesis structure or an explicit note that it is not needed

Verify `## Protocol Handoff` contains, at minimum:
- recommended data-usage considerations
- whether future unseen-data validation seems relevant
- whether confounding or identification is likely central
- whether time ordering matters
- whether grouping or hierarchy matters
- whether monitoring or refresh context matters
- whether the route family seems stable or still uncertain
- unresolved protocol questions
- whether the question framing is already useful or still needs revision
- whether prior art changes scope, assumptions, or project order
- whether any hypothesis structure should be carried forward for inferential or causal work

Resolve the active route from the approved question type in `01_formulation.md`.

Verify the matching file `references/routes/{route}/protocol.md` exists.

If any check fails:
- stop
- tell the user which required fields are missing or contradictory
- route back to `/skeptic:formulate`

Do not proceed with partial context. `protocol` is not allowed to guess around a missing formulation.

## Setup

Before Cycle A, create:

1. `notebooks/02_protocol.ipynb` with a header cell containing:
   - stage title
   - date
   - project name
   - approved question
   - active question type
   - upstream dependency note: `01_formulation.md`
   - note: "This notebook defines the project rules of the game before clean and examine."

2. `skeptic_documentation/02_protocol.md` with this initial structure:

```markdown
# Protocol: Project Rules of the Game

## Dataset
- Sources: {data source names or manifest from formulate stage}
- Approved question: {from 01_formulation.md}
- Question type: {from 01_formulation.md}
- Target quantity: {from 01_formulation.md}
- Claim boundary: {from 01_formulation.md}
- Date started: {date}

## Intake Extract

## Decision Log

## Protocol Contract

## Frozen Artifacts

## PCS Assessment
```

3. If Cycle B chooses frozen artifacts, create them under `data/splits/` during this stage. Do not defer frozen partitions, manifests, or restricted-visibility artifacts to `clean`.

## Cycle Structure

The protocol stage progresses through mandatory cycles. Do not skip A-D. Keep the number of mandatory cycles small. Each cycle uses the same notebook workflow, dual-subagent review, explicit user decision, and immediate logging.

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Handoff audit from formulate | Yes |
| B | Data-usage mode decision | Yes |
| C | Evidence, validation, and risk rules | Yes |
| D | Stage prohibitions and backtracking triggers | Yes |
| E+ | Follow-ups for unresolved protocol questions | No |

## Data Usage Mode Registry

Treat every mode below as a live candidate when relevant. Do not default to splits. Do not default to full-data analysis. Decide.

| Mode | When it is often justified | When it is often wrong | Typical frozen artifacts if chosen |
|------|----------------------------|------------------------|------------------------------------|
| `full_data` | descriptive, exploratory, some inferential, some causal, some mechanistic work where no restricted unseen-data check is needed and the claim boundary does not depend on held-out performance | when later claims depend on unseen-data performance, temporal generalization, group transfer, or restricted visibility | none |
| `frozen_holdout_split` | predictive work or any project needing a final untouched partition for reality checks | when data is too small, temporal order dominates, groups must stay intact, or holdout logic would be performative rather than evidential | `partition_index.csv`, optionally materialized split files |
| `temporal_split` | forecasting, monitoring, drift-sensitive prediction, any setting where future must stay future | when timestamps are not meaningful or later than the target by construction | `temporal_cutoffs.json`, `partition_index.csv` |
| `group_split` | repeated measures, hierarchy, institution or subject transfer, panel or cluster dependence | when grouping does not constrain the claim or groups are too fragmented to support the split | `group_partition_index.csv`, `group_split_rules.json` |
| `rolling_validation` | forecasting, repeated deployment checks, streaming or refreshed-data contexts | when the project is static and rolling windows add ceremony without evidential value | `rolling_windows.json` |
| `external_validation` | a distinct external dataset is central to the allowed claim | when no truly external frame exists or harmonization is too weak to support the comparison | `external_validation_manifest.md` or machine-readable equivalent |
| `resampling_only` | inferential, descriptive, exploratory, causal, or mechanistic work where stability and uncertainty come from resampling, not held-out partitions | when unseen-data deployment performance is central | none |
| `cross_fitting_authorized` | only when later method families may require cross-fitting or sample-splitting to avoid overfitting nuisance components | when no plausible later method needs it | none by default; create concrete fold artifacts here only if they can be justified independently of the exact downstream analysis contract |
| `hybrid` | more than one mode is genuinely required, such as temporal holdout plus within-training resampling | when hybridity is just a hedge against making a real protocol choice | artifacts for each approved component |

If a frozen mode is chosen:
- write the exact artifact names and restrictions into `02_protocol.md`
- create the artifacts now
- log deterministic creation logic, seeds, cutoffs, and identifiers
- store splits only as partition metadata or equivalent split-definition artifacts; the raw source remains canonical

If no frozen mode is chosen:
- say that explicitly
- say why no frozen artifacts are required

## Route Pressure Reference

Use the already loaded route file plus this table to guide Cycle B and Cycle C. These are decision pressures, not defaults.

| Question type | Protocol pressure | Validation emphasis | Common non-default outcome |
|---------------|-------------------|---------------------|----------------------------|
| Descriptive | define reporting frame, denominators, and measurement scope | coverage checks, denominator integrity, refreshed-extract comparison when relevant | no split may be correct |
| Exploratory | protect against overreading search results | perturbation stability, triangulation, explicit hypothesis-generating boundary | full-data plus resampling may be correct |
| Inferential | protect the population claim and dependence structure | sampling logic, uncertainty calibration, design-aware checks | resampling only may be correct |
| Predictive | protect unseen-data performance claims | holdout, temporal, group, rolling, or external validation as justified | frozen artifacts are often required |
| Causal | protect identification and treatment timing | design diagnostics, falsification, overlap, sensitivity, interference checks | no split may be correct even when validation is still strict |
| Mechanistic | protect structural assumptions and identifiability | simulation checks, calibration, boundary-condition checks, out-of-regime failure checks | external or simulation-based validation may matter more than holdout |

## Gate Condition Registry

Every evaluation gate has a stable ID used in cycle metrics. The evaluation subagent references these IDs in its structured output.

| gate_id | cycle | depends_on | condition |
|---------|-------|------------|-----------|
| `A-formulate-complete` | A | A01, A02 | Required formulate sections and fields exist |
| `A-extract-complete` | A | A02, A03 | Exact protocol-relevant fields are extracted from formulate |
| `A-boundary-clear` | A | A03, A04 | Question type, target quantity, and claim boundary are coherent enough for protocol work |
| `A-prematurity-assessed` | A | A05, A06 | Ambiguities that make protocol premature are explicitly surfaced |
| `B-modes-compared` | B | B01, B02 | Plausible data-usage modes are compared, not implied |
| `B-full-data-assessed` | B | B03 | Full-data analysis is explicitly evaluated as a serious option when plausible |
| `B-mode-chosen` | B | B04 | One working data-usage mode or justified hybrid is chosen |
| `B-frozen-artifacts-resolved` | B | B05, B06, B07 | Frozen artifacts are either created now or explicitly ruled unnecessary |
| `B-route-family-confirmed` | B | B08 | Exactly one active route is resolved at protocol level without locking the final analysis contract |
| `C-leakage-ruled` | C | C01, C02, C03 | Leakage relevance and forbidden variable classes are explicitly decided |
| `C-confounding-ruled` | C | C04 | Confounding or identification centrality is explicitly decided |
| `C-structure-ruled` | C | C05 | Time order, grouping, hierarchy, and interference relevance are explicitly decided |
| `C-validation-ruled` | C | C06 | Later validation logic is specified at the right level |
| `C-uncertainty-framed` | C | C07 | High-level uncertainty expectations are stated |
| `D-prohibitions-stated` | D | D01 | Major downstream prohibitions are explicit |
| `D-clean-bounds-stated` | D | D02 | `clean` constraints are explicit |
| `D-examine-bounds-stated` | D | D03 | `examine` constraints are explicit |
| `D-analyze-contract-bounds-stated` | D | D04 | `analyze` contract-lock obligations and limits are explicit |
| `D-analyze-bounds-stated` | D | D05 | `analyze` claim limits are explicit |
| `D-backtracking-defined` | D | D06 | Backtracking triggers and return paths are explicit |

**Decision rule:** Gates about centrality do not require that a topic be central. They require that the topic be decided. "Not central" is a valid PASS if justified.

## Cycle Protocol

This protocol applies to every cycle.

### Step 0: Progress Indicator

At the start of each cycle, print:
`"Protocol stage: Cycle {X} ({focus}) - {mandatory/optional} - {ordinal} of {total mandatory} mandatory cycles"`

### Step 1: Setup and Execution

- Claude reads existing notebook outputs. Skip this only for Cycle A.
- Claude reads `01_formulation.md` before every cycle. The approved question, question type, and protocol handoff remain the contract anchor.
- Claude identifies what the current cycle must decide.
- Claude writes notebook markdown plus code cells.
- If the cycle requires frozen artifacts, Claude writes the cells that create them during this stage.
- Claude executes the notebook and presents key outputs to the user (see `core-principles.md` Notebook Execution).

### Step 2: Human Review

- Interactive mode: the user reviews the outputs presented by Claude, provides questions or concerns, and Claude responds before proceeding.
- Auto mode: replace this step with the self-review loop from `references/auto-mode.md`. Claude may self-correct within the configured budget, then proceeds without waiting unless an escalation trigger fires.

### Step 3: Subagent Review

Claude reads the notebook outputs.

Then dispatches two subagents in parallel.

**Research subagent:**
```text
Agent(
  model="{subagent_model}",
  description="Domain and methods research for Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a domain and methods research assistant for a Skeptic protocol stage.

  Context:
  - Approved question: "{approved question}"
  - Question type: {question type}
  - Target quantity: {target quantity}
  - Claim boundary: {claim boundary}
  - Formulate handoff: {protocol-relevant facts from 01_formulation.md}
  - Current cycle findings: {summary of notebook outputs for this cycle}
  - User observations: {user's questions or observations, if any}

  Answer these research questions for Cycle {X} ({focus}):
  {insert cycle-specific research questions}

  Return concise findings with sources, organized by question.
  Focus on facts that materially change:
  - data usage rules
  - validation logic
  - leakage rules
  - identification or confounding constraints
  - stage prohibitions
  - backtracking triggers

  Do not choose a final estimator or model.
  """
)
```

**Evaluation subagent:**
```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a Skeptic protocol cycle.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.md
  2. {projects_root}/{project-name}/{notebooks_dir_name}/02_protocol.ipynb
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md

  Cycle focus: {cycle focus description}
  User observations: {user's questions or observations, if any}

  Claim Boundary Registry check:
  Read the Claim Boundary Registry from `metrics.md`. Verify that protocol
  decisions do not widen `scope`, loosen `generalization_limit`, or remove
  entries from `verbs_forbidden`. If the registry does not yet exist (first
  protocol cycle), skip this check.

  Produce this structured output (follow this exact structure in order):

  EVALUATION: Cycle {X} - {focus}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Your job is to actively falsify each gate
  and checklist answer rather than confirm them. For each gate you mark PASS,
  you must state the specific failure mode you tested and ruled out.
  Categories to scan: unstated assumptions, missing edge cases, unverifiable
  criteria, logical gaps, protocol rules that are too vague to enforce,
  decisions deferred without justification, constraint gaps.
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

  CHECKLIST COVERAGE:
  For each checklist item in this cycle: was it answered with evidence in
  the notebook? If not, dependent gates auto-fail.
  - {item_id}: ANSWERED / NOT ANSWERED - [evidence reference or gap]

  GATE ASSESSMENTS (use gate IDs from the Gate Condition Registry for this cycle):
  For each gate where depends_on includes items from this cycle: does the
  answer satisfy the condition?
  - {gate_id}: PASS / FAIL - [evidence from notebook outputs, referencing checklist items from depends_on]
  - {gate_id}: PASS / FAIL - [evidence from notebook outputs, referencing checklist items from depends_on]
  (list every gate for this cycle, not just failures)

  Alternatives considered:
  - Current approach: [description] -> Score: [1-10] - [one-line justification]
  - Alt 1: [different protocol choice] -> Score: [1-10] - [one-line justification]
  - Alt 2: [different protocol choice] -> Score: [1-10] - [one-line justification]

  Required protocol decisions:
  - [decision]
  - [decision]

  Missing information: [list, or "none"]
  Downstream implications: [what clean, examine, or analyze must now obey]
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

When both subagents return, Claude synthesizes them into one unified assessment. Combine research findings with evaluation results into one cycle summary. Log the raw subagent outputs in the decision log for traceability.

Do not fabricate certainty. If the evidence shows `protocol` cannot yet lock the rules of the game:
- request missing collection or design metadata
- narrow the claim boundary
- reopen `formulate`
- archive the project with reasons

Count the blocking failures from the evaluation subagent output: blocking defects plus gates with verdict FAIL. Then apply the decision matrix.

**Decision matrix:**

| blocking_failures | forward actions allowed | note |
|-------------------|------------------------|------|
| 0 | pass, iterate | cycle meets minimum bar |
| > 0 | iterate, acknowledge gap (with written justification) | pass is blocked until blocking failures are resolved or justified |

**Always-available actions (regardless of blocking_failures):**

- **Reopen formulate** -> stop and reopen `formulate` plus `protocol`
- **Data insufficient** -> request more data or archive
- **User override** -> user states the specific reason the FAIL is incorrect, logged as `override: {reason}`, forward actions unlock

Interactive mode: present the synthesized assessment to the user with the allowed actions from the matrix. The user decides. After every cycle, force an explicit decision. Do not silently continue.

Auto mode: apply the autonomous decision protocol from `references/auto-mode.md`, log the rationale, and continue without waiting unless an escalation trigger fires.

### Step 5: Log

Immediately after each cycle decision, append to `skeptic_documentation/02_protocol.md`:

```markdown
### Cycle {X}: {Focus}
- **What we inspected:** [notebook cells run, artifacts reviewed or created]
- **Research findings:** [key domain or methods context from research subagent]
- **Evaluation verdict:** PASS / FAIL
- **Alternatives considered:** [from evaluation subagent, with scores]
- **Protocol decisions made:** [decisions made this cycle]
- **Required artifacts:** [created this cycle / none required / deferred is not allowed if they belong to protocol]
- **Downstream implications:** [what later stages must now obey]
- **Gaps:** [remaining gaps, if any]
- **Decision:** [pass / iterate / acknowledge gap / premature - with reasoning]
```

Also append structured cycle metrics to `skeptic_documentation/metrics.md`. Create the file if it does not exist, starting with `# Skeptic Metrics`, then `## Protocol`.

Every cycle logs the same base fields.

```markdown
**Cycle metrics:**
- iterations: {n}
- verdict: PASS/FAIL (on iteration {n})
- gates: [{gate_id}: PASS/FAIL, ...]
- checklist_coverage: {answered}/{total} [{item_id}: ANSWERED/NOT ANSWERED, ...]
- research_sources_returned: {n}
- evaluation_verdict_aligned: yes/no/partial/indeterminate
- frozen_artifacts_required: yes/no
- unresolved_protocol_risks: {n}
- blocking_failures: {n} (resolved_by_iteration: {n}, resolved_by_override: {n})
```

## Cycle A: Handoff Audit from Formulate

**Focus:** Verify that formulate produced enough structure to make protocol decisions without guessing.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| A01 | Are all required formulate sections present (Summary, Protocol Handoff, PCS Assessment)? | never |
| A02 | Are all required fields extractable: approved question, question type, target quantity, claim boundary, route candidates, unit of analysis, target population, key assumptions, protocol handoff facts, unresolved protocol questions? | never |
| A03 | Are there contradictions between Summary and Protocol Handoff? | never |
| A04 | Is each required field present, partial, or missing (intake completeness)? | never |
| A05 | Are unresolved ambiguities classified as protocol-safe, protocol-blocking, or formulate-level contradiction? | never |
| A06 | What is the minimum set of decisions this stage must produce before clean can start? | never |

**Research questions:**
- For this question type and data context, what upstream ambiguities would usually make protocol premature?
- What study-design or evidence constraints are commonly decisive before cleaning begins for similar projects?
- Are there domain facts that would change whether held-out validation, temporal restrictions, or identification logic matter?

**Evaluation focus:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

**Step 4 addition:** After the standard decision, produce an intake summary that states:
- confirmed approved question
- confirmed question type
- confirmed target quantity
- confirmed claim boundary
- current route candidates
- protocol blockers
- protocol-safe unresolved risks

If protocol blockers remain, do not start Cycle B.

## Cycle B: Data-Usage Mode Decision

**Focus:** Choose how later stages may access data. Decide whether frozen artifacts are required. Create them here if required.

This cycle is where the project chooses among `full_data`, frozen partitions, rolling windows, external validation, resampling-only logic, cross-fitting authorization, or another justified mode. Do not assume splits. Do not assume no split.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| B01 | Which data-usage modes are plausible candidates for this project? | never |
| B02 | For each plausible mode, how does it score on: match to question type, target quantity, claim boundary, time structure, grouping/hierarchy, deployment/reporting context, and main risk? | never |
| B03 | Is full-data analysis a serious candidate? When is it correct and when would it be a mistake for this project? | never |
| B04 | What is the chosen working data-usage mode (or justified hybrid)? | never |
| B05 | Are frozen artifacts required? If yes, what are the exact output paths? | never |
| B06 | If frozen artifacts are created: what is the deterministic creation logic, random seed, row/group identifier logic, restriction rules, and access rules per artifact? | no frozen artifacts required |
| B07 | If no frozen artifacts are required, why not? | frozen artifacts required |
| B08 | Is exactly one active route resolved at protocol level without locking the final analysis contract? | never |

**Hard constraints for Cycle B:**
- Frozen artifacts that belong to protocol must be created here, not later in `clean`.
- Split logic must not depend on downstream model performance.
- Partition logic must not use future information unless the approved mode requires future separation by construction.
- If identifiers are needed to freeze visibility, log the identifier strategy explicitly.
- If a hybrid mode is chosen, each component must have a separate rationale.
- Protocol may authorize future cross-fitting without materializing fold files. Create cross-fit folds here only if the folds are justified independently of the exact downstream analysis contract.

**Research questions:**
- Which data-usage and validation patterns are standard for similar question types and data-generating processes?
- When is full-data analysis the correct choice for similar projects?
- When do temporal, group-based, external, or rolling validation schemes become necessary?
- When is cross-fitting worth authorizing now even though the final method family is not yet selected?

**Evaluation focus:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

**Step 4 addition:** After the standard decision, state:
- active route: exactly one active route
- chosen data-usage mode
- frozen artifacts required: yes/no
- exact artifact list
- visibility restrictions
- rejected alternatives and why

## Cycle C: Evidence, Validation, and Risk Rules

**Focus:** Define the high-level evidence logic later stages must respect.

This cycle decides what counts as leakage, whether confounding or identification are central, whether time order matters, whether grouping, hierarchy, or interference matter, what validation logic later stages must satisfy, and what uncertainty expectations apply.

This cycle does not choose the final estimator or model. It sets the admissible evidence ceiling that `analyze` must later lock and execute.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| C01 | Is leakage central, possible but limited, or irrelevant to the allowed claim? | never |
| C02 | What are the forbidden variable classes (post-outcome, post-treatment, future information, direct target proxies, label echoes, denominator-defined artifacts, variables unavailable in deployment/reporting frame)? | never |
| C03 | Are there project-specific leakage vectors beyond the standard classes? | never |
| C04 | Is confounding or identification central, secondary, or not relevant? | never |
| C05 | Does time order matter? Does grouping, hierarchy, or interference constrain later work? | never |
| C06 | What validation logic must later stages satisfy (denominator integrity, resampling stability, holdout scoring, temporal backtesting, group-transfer checks, external corroboration, placebo/falsification checks, overlap/sensitivity checks, simulation-based validation)? | never |
| C07 | What are the high-level uncertainty expectations (interval estimates, calibration uncertainty, sensitivity bands, perturbation ranges, simulation envelopes, or "uncertainty not central")? | never |

**Hard constraints for Cycle C:**
- "Leakage irrelevant" is allowed only if the claim boundary genuinely makes leakage irrelevant.
- "No split needed" does not mean "no validation needed."
- "Confounding not central" does not mean "all comparison language is safe."
- Validation logic must be stated in a way later stages can implement without rewriting protocol.
- Uncertainty expectations must stay high-level. Do not choose a final inferential procedure here.

**Research questions:**
- What constitutes leakage, target proxies, post-treatment adjustment, or forbidden conditioning in this domain?
- What evidence patterns are accepted for this question type?
- What validation logic is typically required for similar claims?
- What high-level uncertainty statements are credible for similar analyses?

**Evaluation focus:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

**Step 4 addition:** After the standard decision, write a one-page protocol rule summary covering:
- leakage relevance
- forbidden variables
- confounding or identification centrality
- time-order relevance
- grouping, hierarchy, interference relevance
- validation logic required later
- uncertainty expectations
- claim boundary

## Cycle D: Stage Prohibitions and Backtracking Triggers

**Focus:** Define what downstream stages may not do, and define when the workflow must return upstream.

This cycle turns the protocol rules into explicit constraints on `clean`, `examine`, and `analyze`.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| D01 | What are the major downstream prohibitions across all stages? | never |
| D02 | What may clean not do (changing frozen partitions, using restricted artifacts, inventing proxy targets, changing analyzable population, deciding validation logic)? | never |
| D03 | What may examine not do (using restricted holdouts, treating exploratory patterns as confirmed, changing route/validation, pulling forbidden variables)? | never |
| D04 | What must analyze respect at contract-lock time (question type, claim boundary, data-usage mode, frozen artifacts, leakage/confounding/structure constraints, validation logic, uncertainty expectations)? | never |
| D05 | What must analyze not claim beyond (claims beyond boundary, performance claims without validation, causal language without identification, mechanistic claims from fit alone, inferential generalization beyond target population)? | never |
| D06 | What are the backtracking triggers and return paths (different mode needed, frozen artifacts impossible, cleaned data changes population, examination reveals stronger constraints, analyze needs unauthorized route/claims/variables, validation logic fails)? | never |

**Minimum backtracking triggers to assess:**
- later work needs a different data-usage mode than protocol approved
- frozen artifacts are impossible to create cleanly
- cleaned data materially changes the analyzable population or removes required variables
- examination shows time order, grouping, interference, or identification matters more than protocol allowed
- analyze needs a route family or claim class outside the active or admissible route-family set approved by protocol
- analysis requires forbidden variables or unauthorized data visibility
- evaluation shows the allowed claim does not survive the approved validation logic

**Research questions:**
- What downstream protocol violations are common for this kind of project?
- What findings would most clearly mean the project must reopen protocol?
- What failure modes are usually mistaken for harmless implementation detail but actually widen the claim?

**Evaluation focus:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

**Step 4 addition:** After the standard decision, state:
- clean prohibitions
- examine prohibitions
- analyze contract-lock obligations
- analyze claim limits
- backtracking triggers and return paths

## Follow-up Cycles

After the mandatory cycles, additional cycles are triggered by:
1. Claude proposes one based on unresolved issues in A-D
2. The evaluation subagent recommends one
3. The user requests one

Keep follow-up cycles narrow. Examples:
- resolving whether full-data or resampling-only logic is enough
- clarifying whether an external validation frame is real or nominal
- resolving whether confounding is central or just a secondary caution
- clarifying a disputed leakage definition
- resolving whether group structure requires restricted visibility

Follow-up cycles use the same protocol. They must end with an explicit decision and immediate logging.

## Ending the Cycle Loop

The loop ends when:
- all mandatory cycles are complete
- all approved follow-up cycles are resolved or skipped
- any required frozen artifacts have been created
- interactive mode: the user explicitly approves the protocol contract
- auto mode: the stage summary and approval gate defined in `references/auto-mode.md` are complete

Do not finalize because the stage "seems clear enough." Finalization requires explicit stage-close discipline.

## PCS Review

After the stage is ready to close under the active execution mode, dispatch a PCS review subagent:

```text
Agent(
  model="{subagent_model}",
  description="PCS review of protocol stage",
  prompt="""
  You are a PCS reviewer for a Skeptic protocol stage.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  2. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.md
  3. {projects_root}/{project-name}/{notebooks_dir_name}/02_protocol.ipynb

  Evaluate whether protocol adequately defines how the approved question may be answered.

  PREDICTABILITY:
  - Does the chosen data-usage mode match the allowed claim and reality check?
  - Are validation requirements strong enough for the allowed claim without forcing the wrong template?
  - Are external, temporal, or deployment-context realities handled when they materially matter?

  STABILITY:
  - Could a different but still reasonable protocol choice materially change the allowed claim?
  - Are leakage, confounding, identification, time order, grouping, and interference handled explicitly enough to prevent hidden instability?
  - If full-data analysis was approved, is that choice defended rather than assumed?

  COMPUTABILITY:
  - Are frozen artifacts, if any, created and documented?
  - Are prohibitions and backtracking triggers explicit enough for later stages to execute reproducibly?
  - Could another analyst tell what data they may use and what they may not do?

  Produce an objective assessment. For each lens, state:
  - What holds up well
  - What is uncertain or risky
  - Specific recommendations, if any

  Keep it concise.
  """
)
```

After the subagent returns:
1. Append the PCS assessment to `02_protocol.md` under `## PCS Assessment`.
2. Interactive mode: present the assessment to the user.
3. Interactive mode: user decides:
   - **Satisfied** -> proceed to finalization
   - **Valid concern** -> return to the cycle loop
   - **Disagree** -> log the override and proceed
4. Auto mode: record the PCS assessment in the stage summary, apply non-blocking fixes autonomously, and escalate only if the review exposes a blocking concern or the user rejects the stage at the stage boundary.

The subagent advises. It does not silently widen scope or bypass a blocking concern.

## Finalization

After the PCS review clears, or the user overrides it:

0. If frozen artifacts were required but were not created during Cycle B, stop. The stage is incomplete.

1. **Protocol Scorecard (mandatory - first item in finalization).** Append to `skeptic_documentation/metrics.md` under `## Protocol`.

```markdown
### Protocol Scorecard
| metric | value | source |
|--------|-------|--------|
| Checklist items answered | {answered}/{total} | cycle logs |
| Mandatory cycles completed | {n}/{total mandatory} | cycle logs |
| Follow-up cycles | {n} ({list topics}) | cycle logs |
| Total iterations (all cycles) | {n} ({cycle}: {n}, ...) | cycle logs |
| Blocking failures total | {n across all cycles} | gate registry |
| Blocking failures resolved by iteration | {n} | gate registry |
| Blocking failures resolved by override | {n} ({list override reasons}) | gate registry |
| Data usage mode locked | {mode} | Cycle B/C output |
| Route confirmed | {route} | Cycle output |
| Validation logic specified | {yes/no} | protocol contract |
| Backtracking triggers defined | {n} | protocol contract |
```

2. **Update `02_protocol.md`** - add `## Summary` and complete `## Protocol Contract` with:
   - confirmed question type
   - active route: exactly one active route
   - approved question
   - target quantity or estimand
   - claim boundary
   - data usage mode
   - whether frozen artifacts are required
   - exact frozen artifact list, or an explicit statement that none are required
   - leakage relevance and forbidden variable classes
   - whether confounding or identification are central
   - whether time order matters
   - whether grouping, hierarchy, or interference matter
   - validation logic required later
   - uncertainty expectations at a high level
   - major stage prohibitions
   - backtracking triggers
   - unresolved risks carried into `clean` or `analyze`

3. **Update `README.md`:**
   ```markdown
   ## Protocol [COMPLETE]
   Type: {question type}
   Active route: {exactly one active route}
   Data usage mode: {mode}
   Frozen artifacts: {artifact list, or "none required"}
   Validation logic: {one-line summary}
   Next: Clean - auditable data pipeline under protocol rules
   ```

4. Tell the user the protocol stage is complete and the next stage is `clean`.

## Dependency Notes

- `protocol` is the mandatory dependency for both `clean` and `examine`.
- `protocol` defines how the approved question may be answered. `analyze` later locks one executable analysis contract within these rules.
- `protocol` may conceptually load route logic from the approved question type, but it does not choose the final estimator, model family, or executable analysis contract.
- If later work changes the question type, target quantity, or claim boundary, reopen both `formulate` and `protocol`.
- If later work needs different visibility rules, validation logic, or forbidden-variable rules, reopen `protocol`.
