---
name: examine
description: Use after formulate, protocol, and clean to inspect what the cleaned, protocol-visible data can actually support, without defaulting to predictive EDA or crossing into final analysis.
---

# /skeptic:examine - Data Examination and Support Characterization

**IMPORTANT:** Before executing, read `references/core-principles.md` from the parent `skeptic` skill for shared conventions.

`core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

This file is the universal stage-core for `examine`. It defines the post-clean examination workflow that applies across question types. Route files may narrow or prohibit actions. They may not widen this stage-core, the approved formulation, or the protocol contract.

`examine` is the canonical replacement for legacy `eda`. Do not import the old predictive-first assumptions into this stage. Do not assume there is always an outcome variable, always a predictor set, always a split-based comparison, or always a downstream supervised model to support.

## Required Input

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` |

`examine` requires completed `formulate`, `protocol`, and `clean` stages. Do not start from partial upstream context.

## What Prior Outputs This Stage Reads

The stage reads:

- `skeptic_documentation/01_formulation.md` - approved question, question type, target quantity or estimand, claim boundary, route candidates, unit of analysis, assumptions
- `skeptic_documentation/02_protocol.md` - active route, data usage mode, visibility rules, frozen artifacts, leakage and forbidden-variable rules, validation logic, examine prohibitions, backtracking triggers
- `skeptic_documentation/03_cleaning.md` - final visible artifact list, final variable list, population-shift summary, dataset fitness review, open questions, PCS assessment
- `skeptic_documentation/metrics.md` - formulation, protocol, and cleaning scorecards
- `notebooks/01_formulation.ipynb` - rationale trace for the approved question
- `notebooks/02_protocol.ipynb` - rationale trace for visibility, restriction, and validation rules
- `notebooks/03_cleaning.ipynb` - evidence for cleaned artifacts and cleaning judgments
- `notebooks/cleaning_functions.py` - reproducible path back to cleaned artifacts when that file exists
- cleaned artifacts produced or named by `clean`
- protocol-defined artifacts under `data/`, `data/splits/`, or another path named in `02_protocol.md`
- `README.md` - confirms prior stage completion

No additional user input is required if upstream stages are complete. If upstream outputs are incomplete, contradictory, or missing required restrictions, stop and repair the upstream stage. Do not invent examination permissions around gaps.

## Route Resolution

Before Cycle A, do this in order:

1. Read `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `metrics.md`, `01_formulation.ipynb`, `02_protocol.ipynb`, `03_cleaning.ipynb`, and `README.md`.
2. Resolve exactly one active route from upstream outputs. Use the confirmed question type in `01_formulation.md` and `02_protocol.md` as the anchor. If `02_protocol.md` contradicts it or does not collapse to one route for `examine`, stop and reopen `protocol`.
3. Load exactly one stage-specific route file:

| Route | File |
|-------|------|
| `descriptive` | `references/routes/descriptive/examine.md` |
| `exploratory` | `references/routes/exploratory/examine.md` |
| `inferential` | `references/routes/inferential/examine.md` |
| `predictive` | `references/routes/predictive/examine.md` |
| `causal` | `references/routes/causal/examine.md` |
| `mechanistic` | `references/routes/mechanistic/examine.md` |

4. Keep that route context in memory for the rest of `examine` and reuse it across cycles in the same chat.
5. If route context becomes ambiguous mid-stage, reread `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, and the same route file before proceeding.
6. If the active route cannot be resolved or the expected route file is missing, stop and route back upstream.

## Precondition Gate

Run this gate before anything else.

Verify all of the following:

- `skeptic_documentation/01_formulation.md` exists
- `skeptic_documentation/02_protocol.md` exists
- `skeptic_documentation/03_cleaning.md` exists
- `skeptic_documentation/metrics.md` exists
- `notebooks/01_formulation.ipynb` exists
- `notebooks/02_protocol.ipynb` exists
- `notebooks/03_cleaning.ipynb` exists
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
- explicit visibility rules for `examine`
- frozen artifacts required or an explicit statement that none are required
- leakage relevance and forbidden-variable classes
- validation logic required later
- major `examine` prohibitions
- backtracking triggers

Verify `03_cleaning.md` contains:

- `## Summary`
- `## Dataset Fitness Review`
- `## PCS Assessment`
- final visible artifact list after cleaning
- final variable list after cleaning
- population-shift summary
- assumptions and open questions carried forward

Resolve the active route from `01_formulation.md` plus `02_protocol.md`.

Verify the matching file `references/routes/{route}/examine.md` exists.

Before Cycle A, derive and record the active visibility set for this stage:

- which cleaned artifacts are visible to `examine`
- which protocol-created artifacts are visible to `examine`
- which restricted artifacts are not visible
- what level of access is allowed for each visible artifact

Do not assume held-out artifacts are visible. If `protocol` does not authorize them for this stage, they are out of bounds.

If any required field, artifact, or restriction is missing or contradictory:

- stop
- tell the user exactly what is missing or inconsistent
- route back to `clean`, `protocol`, or `formulate` as appropriate

Do not proceed with partial context.

## Guiding Principle

The goal of `examine` is to characterize what the cleaned, protocol-visible data can actually support.

Use examination to:

- characterize distributions, support, coverage, ranges, and basic structure
- inspect relationships, dependencies, subgroup differences, heterogeneity, and temporal or grouped structure where relevant
- review anomalies, edge cases, sparse regions, contradictions, and support failures
- identify tensions that later `analyze` must take seriously when locking the executable contract
- downgrade confidence when patterns are fragile under reasonable examination choices
- clarify what later `analyze` must take seriously inside the active route without selecting the final contract

Treat `01_formulation.md` route candidates as upstream history, not live permissions. Before Cycle A, resolve exactly one active route from upstream outputs and load its stage-specific route file. If `02_protocol.md` does not collapse to one route or contradicts `01_formulation.md`, stop and reopen `protocol`.

Do not use examination to:

- run generic predictive EDA
- assume response-versus-predictor framing
- choose the final estimator, model family, or analysis contract
- prove a claim
- widen the claim boundary
- override protocol visibility rules
- perform unrestricted exploration outside the approved question and protocol

If the data cannot support the approved question inside the approved claim boundary, say so and route the project back upstream.

## Setup

Before Cycle A, create:

1. `notebooks/04_examination.ipynb` with a header cell containing:
   - stage title
   - date
   - project name
   - approved question
   - question type
   - target quantity
   - claim boundary
   - protocol mode
   - visibility rules
   - cleaned artifacts available for examination
   - upstream dependency note: `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`
   - note: "This notebook is stage-core only. The loaded route file may narrow or prohibit actions. This stage does not choose the final analysis contract or widen the claim boundary."

2. `skeptic_documentation/04_examination.md` with this initial structure:

```markdown
# Examine: Data Examination and Support Characterization

## Dataset
- Source: {raw data file(s)}
- Approved question: {from 01_formulation.md}
- Question type: {from 01_formulation.md}
- Target quantity: {from 01_formulation.md}
- Claim boundary: {from 01_formulation.md}
- Protocol mode: {from 02_protocol.md}
- Visibility rules: {short summary from 02_protocol.md}
- Cleaned artifacts available for examination: {artifact list from 03_cleaning.md and 02_protocol.md}
- Date started: {date}

## Upstream Contract
- Approved question: {from formulate}
- Question type: {from formulate}
- Target quantity: {from formulate}
- Claim boundary: {from formulate}
- Formulation route candidates: {from formulate}
- Active route: {from protocol}
- Protocol mode: {from protocol}
- Visibility constraints: {from protocol}

## Decision Log

## Support Registry

## Analysis Handoff

## PCS Assessment
```

The notebook header must state the approved question, question type, target quantity, claim boundary, protocol mode, visibility rules, and cleaned artifacts available for examination explicitly. `examine` starts only after those fields are written.

## Stage Map

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Support and distribution audit | Yes |
| B | Structural relationships and heterogeneity | Yes |
| C | Anomalies, contradictions, and support gaps | Yes |
| D+ | Follow-up examinations | No |
| E | Design handoff synthesis | Yes |

Cycles `A`, `B`, `C`, and `E` are mandatory. `D+` is a narrow follow-up window, not a standing obligation.

## Execution Gates

Before each cycle, verify the required outputs from prior work exist. If anything is missing, stop and tell the user exactly what is missing.

| Before | Required state |
|--------|----------------|
| Cycle A | Precondition gate passed. Setup files exist. Active visibility set recorded. |
| Cycle B | `04_examination.md` contains `### Cycle A` log entry. `04_examination.ipynb` has Cycle A outputs. |
| Cycle C | `04_examination.md` contains `### Cycle B` log entry. `04_examination.ipynb` has Cycle B outputs. |
| Cycle E | `04_examination.md` contains `### Cycle A`, `### Cycle B`, and `### Cycle C` log entries. Any approved `D+` cycles that materially affect interpretation are closed. |
| Post-cycle evaluation | Mandatory cycle loop complete. User has indicated the stage is ready for post-cycle review. |

## Gate Condition Registry

Every evaluation gate has a stable ID used in cycle metrics. The evaluation subagent references these IDs in its structured output.

| gate_id | cycle | depends_on | condition |
|---------|-------|------------|-----------|
| `A-visibility-confirmed` | A | A01 | The stage identifies exactly which cleaned and protocol-created artifacts `examine` may inspect |
| `A-support-profiled` | A | A02 | Distributions, coverage, ranges, support, schema sanity, and count reconciliation are characterized for question-critical structures in visible artifacts |
| `A-subgroup-presence-mapped` | A | A03 | Relevant subgroup, time, cluster, or hierarchy presence is characterized without overclaiming |
| `A-startup-checklist-complete` | A | A06 | EDA startup checks, including representative subsample use when appropriate, are completed before deeper examination |
| `A-scope-respected` | A | A01, A02, A03, A04, A05, A06 | Examination stays inside approved question, protocol, and active route-file restrictions |
| `B-relationship-views-justified` | B | B01 | Relationship and dependence views are chosen because they are meaningful under the question and protocol, not by predictive default |
| `B-heterogeneity-assessed` | B | B02, B03 | Subgroup differences, temporal or grouped structure, and heterogeneity are reviewed when relevant |
| `B-no-final-analysis` | B | B01, B02, B03, B04 | Cycle B does not choose the final route, estimator, or claim beyond the approved boundary |
| `B-route-pressure-stated` | B | B05 | Route-relevant pressures for later analyze-stage contract lock are stated explicitly without selecting the contract |
| `B-visual-heuristics-justified` | B | B06 | Plot families, encodings, alternative views, and summary-statistic choices are justified by variable type and visible structure |
| `B-subsample-justified` | B | B07 | A representative subsample is used when the full artifact is too dense for meaningful first-pass visual reasoning |
| `C-anomalies-reviewed` | C | C01 | Anomalies, contradictions, sparse regions, and edge cases are inventoried and interpreted carefully |
| `C-support-gaps-stated` | C | C04 | Support failures relative to the approved question and claim boundary are explicit |
| `C-fragility-checked` | C | C02, C03 | Apparent structures that matter for later analyze-stage contract lock are checked under reasonable examination perturbations |
| `C-backtracking-assessed` | C | C05 | The cycle explicitly assesses whether `clean`, `protocol`, or `formulate` must reopen |
| `C-stop-rule-stated` | C | C07 | The cycle explicitly states whether further exploration would be material or merely redundant |
| `E-handoff-complete` | E | E01, E02, E03, E04 | The analysis handoff states what the data can support, what it weakly supports, and what remains unsupported |
| `E-route-candidates-updated` | E | E02 | Route candidates are marked stronger, weaker, or unchanged with reasons |
| `E-analysis-constraints-stated` | E | E03 | Analysis constraints and unresolved risks are concrete enough for the next stage |
| `E-no-contract-selection` | E | E04, E05 | The handoff informs `analyze` without selecting the final analysis contract |

## Cycle Protocol

Apply this protocol to every cycle.

### Step 0: Progress Indicator

At the start of each cycle, print:

`"Examine stage: Cycle {X} ({focus}) - {mandatory/optional} - {ordinal} of 4 mandatory cycles"`

For post-cycle phases, print:

`"Examine stage: Post-cycle Phase {N} ({name})"`

### Step 1: Setup and Execution

- Claude reads existing notebook outputs. Skip this only for Cycle A beyond the header.
- Claude reads `01_formulation.md`, `02_protocol.md`, and `03_cleaning.md` before every cycle. Treat the approved question, question type, target quantity, claim boundary, active route, protocol mode, visibility rules, and prohibitions as hard constraints.
- Claude reuses the route context already loaded at stage start from `references/routes/{route}/examine.md`.
- If route context becomes ambiguous, Claude rereads `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, and the same route file before proceeding.
- If the active route cannot be confirmed or the expected route file is missing, stop and reopen upstream. Do not guess.
- Claude identifies which cleaned and protocol-created artifacts the current cycle is allowed to inspect. If visibility is unclear, stop and reopen `protocol` rather than guessing.
- Claude identifies which examination moves are meaningful for the approved question and which are out of scope.
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
  model="{subagent_model}",
  description="Research for Examine Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a research assistant for a Skeptic examine stage.

  Context:
  - Approved question: "{approved question}"
  - Question type: {question type}
  - Target quantity: {target quantity}
  - Claim boundary: {claim boundary}
  - Protocol mode: {protocol mode}
  - Examine-stage visibility rules: {visibility rules}
  - Visible artifacts used in this cycle: {artifact list}
  - Current notebook findings: {specific findings from this cycle}
  - User observations: {user observations if any}

  Answer these research questions for Cycle {X} ({focus}):
  {insert cycle-specific research questions}

  Rules:
  - Stay inside the approved question, protocol, and visible data.
  - Ask only domain questions that clarify observed structure, anomalies, subgroup patterns, dependencies, measurement artifacts, or support limitations.
  - Do not do generic literature review unrelated to what is visible in the notebook.
  - If a question does not apply, say "not applicable" and give a one-line reason.
  - Cite sources only for claims that would change how the examination is interpreted or how later analysis should respond.

  Return concise findings with sources, organized by research question.
  Focus on information that changes support characterization, fragility assessment, or analysis constraints.
  """
)
```

**Evaluation subagent:**

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Examine Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a Skeptic examine-stage cycle.

  Before evaluating gates, verify that all checklist items for this cycle were answered with evidence in the notebook. If any checklist item was not answered, the gates that depend on it auto-fail.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/04_examination.md
  2. {projects_root}/{project-name}/{notebooks_dir_name}/04_examination.ipynb
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  4. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.md
  5. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.md

  Cycle focus: {focus description}
  User observations: {user observations if any}

  Applicable gates for this cycle:
  {list applicable gate IDs from the Gate Condition Registry}

  Evaluate checklist coverage and gates for Cycle {X} ({focus}):
  The evaluation subagent checks:
  1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail.
  2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

  Task:
  1. Evaluate each applicable gate using notebook evidence.
  2. Answer the cycle-specific evaluation questions directly from notebook evidence.
  3. Identify up to 3 findings that determine whether the cycle should pass.
  4. Flag any move that exceeds protocol, overreads exploratory structure, widens the claim boundary, or drifts into final analysis.
  5. Recommend whether to pass, iterate, acknowledge a gap, reopen clean, reopen protocol, or reopen formulate plus protocol.
  6. Read the Claim Boundary Registry from `metrics.md`. Verify that no
     examination finding, support characterization, or handoff statement uses
     verbs from `verbs_forbidden` or asserts scope beyond `scope`. If
     examination weakens support, recommend narrowing the registry.

  Output format (follow this exact structure in order):

  EVALUATION: Cycle {X} - {focus}

  CHECKLIST COVERAGE:
  - {item_id}: ANSWERED / NOT ANSWERED - [evidence or gap]
  (list every checklist item for this cycle)

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Your job is to actively falsify each gate
  and checklist answer rather than confirm them. For each gate you mark PASS,
  you must state the specific failure mode you tested and ruled out.
  Categories to scan: unstated assumptions, overread exploratory patterns,
  claim-boundary violations, protocol-visibility violations, support claims
  not backed by notebook evidence, drift into final analysis.
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
  - {gate_id}: PASS / FAIL - [evidence] - depends_on: {item_ids}
  - {gate_id}: PASS / FAIL - [evidence] - depends_on: {item_ids}
  (list every applicable gate)

  Cycle-specific findings:
  - [criterion]: [fact-based answer with notebook evidence]
  - [criterion]: [fact-based answer with notebook evidence]

  Key findings:
  - [finding]
  - [finding]
  - [finding]

  Design implications:
  - [constraint or pressure]
  - [constraint or pressure]

  Gaps remaining: [list, or "none"]
  Recommended next step: pass / iterate on {topic} / acknowledge gap / reopen clean / reopen protocol / reopen formulate plus protocol
  Recommended follow-up cycle: [topic and why] / None

  VERDICT:
  PASS = zero BLOCKING defects and zero FAIL gates.
  FAIL = one or more BLOCKING defects or FAIL gates.
  Verdict: [PASS/FAIL]
  Blocking defects: [count]
  Failed gates: [count]
  Unanswered checklist items: [count]

  Be objective. Not harsh, not lenient.
  """
)
```

### Step 4: Decision

When both subagents return, Claude synthesizes them into one cycle assessment. Do not present disconnected subagent reports as if they were the stage decision. Log the raw outputs for traceability.

Do not fabricate certainty. If the evidence shows the data cannot support the approved question inside the approved boundary, surface it.

Count the blocking failures from the evaluation subagent output: blocking defects plus gates with verdict FAIL. Then apply the decision matrix.

**Decision matrix:**

| blocking_failures | forward actions allowed | note |
|-------------------|------------------------|------|
| 0 | pass, iterate | cycle meets minimum bar |
| > 0 | iterate, acknowledge gap (with written justification) | pass is blocked until blocking failures are resolved or justified |

**Always-available actions (regardless of blocking_failures):**

- **Reopen clean** -> stop and reopen `clean`
- **Reopen protocol** -> stop and reopen `protocol`
- **Reopen formulate** -> stop and reopen `formulate` plus `protocol`
- **Data insufficient** -> request more data or archive
- **User override** -> user states the specific reason the FAIL is incorrect, logged as `override: {reason}`, forward actions unlock

Interactive mode: present the synthesized assessment to the user with the allowed actions from the matrix. The user decides. After every cycle, force an explicit decision. Do not silently continue.

Auto mode: apply the autonomous decision protocol from `references/auto-mode.md`, log the rationale, and continue without waiting unless an escalation trigger fires.

### Step 5: Log

Immediately after each cycle decision, append to `skeptic_documentation/04_examination.md`:

```markdown
### Cycle {X}: {Focus}
- **Visible artifacts used:** {artifact list}
- **What we inspected:** {notebook cells run, structures examined}
- **Research findings:** {key findings from the research subagent}
- **Evaluation verdict:** PASS / FAIL
- **Key findings:** {up to 3 findings from the evaluation subagent}
- **Support implications:** {what now appears well supported / weakly supported / unsupported}
- **Support Registry update:** {entries added or revised under `## Support Registry`}
- **Route implications:** {whether the active route looks supported, weakened, or invalidated}
- **Protocol check:** {within bounds / cleaning mismatch found / protocol mismatch found / formulation mismatch found}
- **Tensions or contradictions:** {none / explicit list}
- **Analysis consequences:** {what later analyze-stage contract lock must take seriously}
- **Decision:** {pass / iterate / acknowledge gap / cleaning mismatch / protocol mismatch / formulation mismatch / data insufficient}
```

Also append structured cycle metrics to `skeptic_documentation/metrics.md`. Create the section `## Examination` if it does not yet exist.

```markdown
**Cycle metrics:**
- iterations: {n}
- verdict: PASS/FAIL (on iteration {n})
- gates: [{gate_id}: PASS/FAIL, ...]
- checklist_items_answered: {n}/{total}
- research_sources_returned: {n}
- evaluation_verdict_aligned: yes/no/partial/indeterminate
- route-candidate-update: stronger/weaker/unchanged/mixed
- backtracking-triggered: none/clean/protocol/formulation+protocol
```

## Cycle A: Support and Distribution Audit

**Focus:** Characterize support, coverage, ranges, subgroup presence, basic structural facts, and the EDA startup conditions in the cleaned, visible artifacts.

This cycle stays universal. Do not default to response-versus-predictor framing.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| A01 | Which cleaned artifacts are visible and what are their dimensions? | never |
| A02 | What is the support, coverage, observed range, sparsity, schema sanity, and count reconciliation for question-critical structures? What top/bottom rows, missing codes, or obvious value patterns deserve a first-pass look? | never |
| A03 | What subgroup, time, cluster, or hierarchy presence exists and is it balanced, thin, or absent? | no subgroups relevant to approved question |
| A04 | What appears well supported, weakly supported, and unsupported? | never |
| A05 | Is the Support Registry in 04_examination.md updated with Cycle A findings? | never |
| A06 | If the visible artifact is large or dense, has a representative subsample been selected for initial inspection and do the counts still reconcile against the full artifact? | never |

Do not treat this cycle as a cleaning rerun. Use the cleaned artifacts as the input state unless a mismatch forces backtracking.

**Research questions:**

- What domain ranges, support expectations, or coverage patterns matter for interpreting the visible structures?
- Do observed sparse regions, subgroup absences, or range limits reflect domain reality, measurement design, or likely extraction artifacts?
- Which observed support limitations are routine for this data source, and which are genuine warnings for the approved question?
- If the visible artifact is large, what representative subsample is sufficient for first-pass manual inspection without hiding important structure?

**Evaluation focus:**

The evaluation subagent checks:
1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail.
2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle B: Structural Relationships and Heterogeneity

**Focus:** Inspect relationships, dependencies, subgroup differences, temporal or grouped structure, and heterogeneity only where meaningful under the approved question and protocol.

Do not assume there is an outcome variable. Do not assume variable importance or target association is the main lens.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| B01 | Which relationship views are meaningful for the approved question and which are out of scope? | never |
| B02 | What visible dependence and structure exists (pairwise, multivariate, subgroup contrasts, temporal, grouped, clustered, repeated-measure, or hierarchical)? | never |
| B03 | What heterogeneity exists across meaningful subgroups, time windows, or groups? | no heterogeneity dimensions relevant to approved question |
| B04 | What do reasonable alternative summaries, stratified views, or dependence diagnostics show without crossing into final analysis? | never |
| B05 | What route-relevant pressures (dependence, subgroup imbalance, temporal structure, support fragmentation) exist for later analyze-stage contract lock? | never |
| B06 | Which plot families, encodings, and summary statistics best match the variable types and visible structure, and what alternative display confirms or weakens the same story? | never |
| B07 | Is the exploratory view still too dense for direct inspection, or does the current sample size support a smaller representative subsample for clearer visual reasoning? | never |

Do not evaluate routes that `protocol` already ruled out. Do not revive them through examination language.

Do not choose the final route. Do not choose the final estimator. Do not convert a visually suggestive pattern into a confirmed claim.

**Research questions:**

- What domain mechanisms, data-collection features, or measurement conventions could explain the visible relationships or subgroup differences?
- Are the observed dependence or heterogeneity patterns consistent with known structure in similar data, or are they likely to be artifact-sensitive?
- Which visible structural features materially constrain later analysis choices or interpretation language?
- Which summary statistics are actually informative for this structure, and which are just decorative?
- If a plot is the first useful pass, what simpler plot or subsample should come before a more elaborate one?

**Evaluation focus:**

The evaluation subagent checks:
1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail.
2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle C: Anomalies, Contradictions, and Support Gaps

**Focus:** Inspect anomalies, contradictions, sparse regions, unstable patterns, and support failures that threaten the approved question, claim boundary, or later active-route execution.

This cycle must explicitly ask whether the data can support the intended claim boundary.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| C01 | What anomalies, contradictions, sparse regions, extreme values, inconsistent signals, and measurement artifacts exist? | never |
| C02 | Do patterns that matter for analyze-stage contract lock survive reasonable examination perturbations (alternative binning, scales, subgroup definitions, aggregation windows)? | never |
| C03 | Which patterns are stable enough to inform contract lock, which are conditionally informative, and which are too fragile? | never |
| C04 | Can the visible data support the approved question and claim boundary as stated, and does the active route now look materially weaker or invalid? | never |
| C05 | Is backtracking required (reopen clean, protocol, or formulate plus protocol)? | never |
| C06 | Is the Support Registry in 04_examination.md updated with contradictions, support failures, fragile patterns, and route-relevant warnings? | never |
| C07 | Has exploration reached a sensible stopping point, or would another pass materially change the support picture instead of just adding redundant views? | never |

Do not bury failure. If support fails, say it clearly.

**Research questions:**

- What domain explanations, collection artifacts, or measurement issues could explain the observed anomalies or contradictions?
- Which sparse regions or unstable subgroup patterns are likely substantive versus procedural?
- Do the observed tensions indicate the question is too broad, the protocol too permissive, or the cleaned artifacts too weak for the intended claim boundary?
- At what point do further plots, summaries, or subgroup slices stop adding material information?

**Evaluation focus:**

The evaluation subagent checks:
1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail.
2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycles D+: Follow-up Examinations

Use a `D+` follow-up only when a material examination issue remains unresolved after Cycles A-C.

A `D+` cycle must be narrow and issue-specific. Define only:

- the unresolved structure, anomaly, contradiction, or support question
- why it materially matters for the approved question or active route
- what evidence is still needed
- what concrete decision the follow-up is meant to unlock for `analyze`

Each D+ cycle must define its own checklist items (D01, D02...) scoped to the specific follow-up topic.

Use `D+` for issues such as:

- clarifying whether a subgroup pattern is real or support-driven
- checking whether a dependence pattern survives a reasonable alternative view
- resolving whether a support gap materially weakens one route candidate
- disentangling a likely measurement artifact from a substantive structure

Do not turn `D+` into unrestricted extra exploration. If the issue is actually a cleaning, protocol, or formulation mismatch, route back upstream.

## Examination Practice Guidance

### EDA Startup Checklist
Use this as the default first-pass inspection sequence in Cycle A and any large-data follow-up:
- verify schema, types, and visible artifact dimensions
- inspect a representative subsample if the data is large or dense
- reconcile counts against expectations from upstream stages
- inspect top and bottom rows or equivalent representative slices
- identify missing-value codes, suspicious sentinels, and obvious value anomalies
- note whether any observation grain, key, or join structure looks inconsistent

### Exploratory Visualization Heuristics
Use the simplest plot that can answer the visible question.
- Choose displays by variable type and relationship type, not by habit.
- Prefer plots that preserve individual observations when summaries could hide structure.
- Compare at least one alternative view before treating a pattern as stable.
- Use a smaller representative subsample when the full data density makes a plot unreadable.
- Treat raw points, agreement plots, and simple stratified views as first-pass tools before more elaborate encodings.

### Summary Statistics Guidance
Use summary statistics to describe what the visible data appears to do, not to replace the visual inspection.
- Mean and SD are useful when the distribution is roughly symmetric and outlier-sensitive summaries are acceptable.
- Median and IQR are safer when skew or outliers matter.
- Mode is useful when the most common category or value matters.
- SEM is a precision summary, not a substitute for SD.
- If a summary statistic hides the shape of the distribution, pair it with a plot instead of relying on it alone.

### Stopping Rules For Exploration
Stop or hand off when one of these is true:
- the same support picture keeps repeating across reasonable views
- further plots only restate the same structure
- the question is supported enough to define the next analysis contract
- the question is not supportable without new data, new protocol, or upstream changes
- the remaining work would become final-analysis logic rather than examination logic

## Cycle E: Analysis Handoff Synthesis

**Focus:** Synthesize the examination into constraints for `analyze`.

This cycle produces the structured handoff that `analyze` must use when locking the executable contract. It informs the contract. It does not choose it.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| E01 | What does the consolidated support matrix show as supported, weakly supported, and unsupported? | never |
| E02 | Which parts of the active route now look stronger, weaker, unchanged, or no longer defensible? | never |
| E03 | What analysis constraints (support limitations, heterogeneity, dependence, temporal structure, anomaly pressures, fragility warnings, visibility and protocol constraints) exist for analyze? | never |
| E04 | Does the Analysis Handoff in 04_examination.md state supported aspects, weakly supported aspects, route pressure, analysis constraints, unresolved risks, and open issues? | never |
| E05 | Does the handoff end with an explicit statement that the next stage is analyze, without treating examination patterns as confirmed findings? | never |

**Research questions:**

- Which observed structures, support limitations, or anomaly patterns require domain-aware caution in later analyze-stage contract lock?
- Which parts of the active route are most sensitive to the visible support limitations or structural tensions?
- What domain questions remain open that analyze must respect rather than silently resolve?

**Evaluation focus:**

The evaluation subagent checks:
1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail.
2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Research Question Guidance

Research questions in `examine` must clarify the visible data, not replace it.

Ask research questions that:

- clarify observed structure
- explain anomalies or contradictions
- interpret subgroup patterns or heterogeneity
- interpret visible dependencies or support fragmentation
- explain measurement artifacts or support limitations
- identify which summary statistics are informative and which are misleading
- ask whether a representative subsample is sufficient before scaling up to the full artifact
- determine whether another exploratory pass would change the support picture or only add redundancy

Do not ask:

- generic literature review questions unrelated to the visible data
- final method-selection questions
- questions that assume predictive framing unless the approved route family and question actually require it

## Evaluation Question Guidance

Evaluation in `examine` must ask whether the stage stayed inside its boundary.

Always check:

- whether the examination stayed within protocol visibility and evidence rules
- whether it overread exploratory structure
- whether it surfaced analysis-contract-relevant constraints
- whether it stayed inside the approved claim boundary
- whether follow-up or backtracking is required
- whether the cycle stopped at a sensible exploratory boundary rather than drifting into final analysis

Do not use evaluation to turn examination into final analysis.

## Ending the Cycle Loop

The cycle loop ends when:

- mandatory cycles `A`, `B`, `C`, and `E` are complete
- all approved `D+` follow-ups are closed
- interactive mode: the user indicates the stage is ready for post-cycle review
- auto mode: the mandatory cycles and approved follow-ups are complete, so the stage advances to stage-close review under `references/auto-mode.md`

Do not finalize because the stage "seems good enough." Require an explicit decision.

## Post-cycle Evaluation

After the cycle loop, move through three phases. Interactive mode waits for user review between phases. Auto mode follows `references/auto-mode.md` and pauses only on escalation triggers or the final stage-boundary approval.

| Before | Required state |
|--------|----------------|
| Phase 1: Fragility Review | Cycle loop complete. `## Support Registry` and `## Analysis Handoff` have draft content. |
| Phase 2: PCS Review | Fragility review outputs exist in the notebook and are summarized in `04_examination.md`. |
| Phase 3: Finalization | `## PCS Assessment` section exists in `04_examination.md`. |

### Phase 1: Fragility Review

**Goal:** Check whether the structures that will influence analyze-stage contract lock are stable enough to carry analysis-contract weight.

This is not final analysis. This is a PCS-style check on the examination framing itself.

Use only protocol-visible artifacts. Review only patterns or tensions that materially affect the handoff.

Required outputs in the notebook and `04_examination.md`:

- a table of analysis-contract-relevant patterns or tensions
- the reasonable examination alternatives used to challenge each one
- a verdict for each item:
  - stable enough to inform analyze-stage contract lock
  - conditionally informative
  - too fragile to carry analysis-contract weight
- the downstream consequence for `analyze`

Questions this phase must answer:

- Which visible structures remain stable under reasonable examination choices?
- Which structures are fragile enough that `analyze` must treat them as tentative?
- Did examination framing itself introduce meaningful incremental risk?

If a pattern collapses under reasonable alternatives, downgrade it. Do not let it survive into `analyze` as if it were solid.

### Phase 2: PCS Review

After the fragility outputs are complete under the active execution mode, dispatch a PCS review subagent:

```text
Agent(
  model="{subagent_model}",
  description="PCS review of examine stage",
  prompt="""
  You are a PCS reviewer for a Skeptic examine stage.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  2. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.md
  3. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.md
  4. {projects_root}/{project-name}/{docs_dir_name}/04_examination.md
  5. {projects_root}/{project-name}/{notebooks_dir_name}/04_examination.ipynb

  Evaluate only the incremental risk introduced by examination.
  Do not restate the full formulation, protocol, or cleaning reviews.

  Answer these questions:
  1. Predictability: did examination characterize what the visible data can support, or did it overread first-pass patterns?
  2. Stability: which analysis-contract-relevant structures remained stable under reasonable examination alternatives, and which did not?
  3. Computability: is the support characterization and handoff documented clearly enough that another analyst could follow it?
  4. Main risk driver: what examination choice or framing choice introduced the most risk, if any?
  5. Reopen cycle: should the examine stage reopen a cycle or route back upstream? Yes or no, and why?

  Output format:

  PREDICTABILITY: ACCEPTABLE / CONCERN
  - [fact-based finding]

  STABILITY: STABLE / CONDITIONALLY STABLE / UNSTABLE
  - [fact-based finding]

  COMPUTABILITY: ADEQUATE / CONCERN
  - [fact-based finding]

  MAIN RISK DRIVER:
  - [examination choice or "none"]

  REOPEN CYCLE: YES / NO
  - [why]
  """
)
```

After the subagent returns:

1. Append the PCS assessment to `04_examination.md` under `## PCS Assessment`.
2. Interactive mode: present the assessment to the user.
3. Interactive mode: user decides:
   - **Satisfied** -> proceed to Phase 3
   - **Valid concern** -> reopen the relevant cycle or route upstream
   - **Disagree** -> log the override and proceed
4. Auto mode: record the PCS assessment in the stage summary, apply non-blocking fixes autonomously, and escalate only if the review exposes a blocking concern or the user rejects the stage at the stage boundary.

The subagent advises. It does not silently widen scope or bypass a blocking concern.

### Phase 3: Finalization

After the PCS review clears, or the user overrides it:

1. Append an Examination Scorecard to `skeptic_documentation/metrics.md` under `## Examination`.

### Examination Scorecard
| metric | value | source |
|--------|-------|--------|
| Checklist items answered | {answered}/{total} | cycle logs |
| Mandatory cycles completed | {n}/4 | cycle logs |
| Follow-up cycles (D+) | {n} ({list topics}) | cycle logs |
| Total iterations (all cycles) | {n} ({cycle}: {n}, ...) | cycle logs |
| Blocking failures total | {n across all cycles} | gate registry |
| Blocking failures resolved by iteration | {n} | gate registry |
| Blocking failures resolved by override | {n} ({list override reasons}) | gate registry |
| Support registry entries | {n} | Cycle A/B/C output |
| Fragile items (from post-cycle review) | {n}/{total} | Phase 1 |
| Route pressure | {stronger / weaker / unchanged / mixed} | Cycle E handoff |
| Backtracking triggered | {none / clean / protocol / formulate+protocol} | cycle logs |
| PCS verdict | {from PCS subagent} | Phase 2 |
| PCS user decision | {satisfied / valid concern acted on / override with reason} | Phase 2 |

2. Update `04_examination.md` with `## Summary` containing:
   - final visible artifact list used in examination
   - support registry
   - stable, conditional, and fragile patterns
   - what inside the active route looks stronger or weaker
   - analysis constraints
   - unresolved risks
   - open issues carried forward

3. Complete `## Analysis Handoff` so it ends with a strong handoff to `analyze`. The section must state:
   - what the data appears able to support
   - what assumptions or risks became more serious
   - what inside the active route looks stronger or weaker
   - what analysis constraints emerged
   - what unresolved issues remain
   - next stage: `analyze`
   - do not widen the claim boundary during contract lock

4. Update `README.md`:

```markdown
## Examine [COMPLETE]
Type: {question type}
Protocol mode: {data usage mode}
Visibility: {one-line summary of examine-stage visibility rules}
Support: {one-line summary of what the data appears able to support}
Main tensions: {one-line summary of the main support gaps or anomalies}
Route pressure: {one-line summary of what inside the active route looks stronger or weaker}
Next: Analyze - lock and execute the analysis under protocol constraints
```

5. Present the final artifacts to the user and state that the next stage is `analyze`.
