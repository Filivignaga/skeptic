---
name: evaluate
description: Use after formulate, protocol, clean, examine, and analyze to adjudicate whether outputs and claims survive route-appropriate PCS checks, rendering per-claim survival verdicts that gate what communicate may package.
---

# /skeptic:evaluate - Route-Appropriate PCS Evaluation

**IMPORTANT:** Before executing, read `references/core-principles.md` from the parent `skeptic` skill for shared conventions.

`core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

This file is the universal stage-core for `evaluate`. It defines the adjudication workflow that applies across question types. Route files may narrow or prohibit actions. They may not widen this stage-core, the approved formulation, or the protocol contract.

`evaluate` does not re-execute analysis. It does not generate new claims. It does not package findings for an audience. It receives the locked outputs from `analyze` and renders per-claim survival verdicts under PCS. `analyze` explicitly defers three things to `evaluate`: whether sensitivity/challenger divergence constitutes instability, whether results are trustworthy, and which claims survive. `communicate` receives only claims that survived `evaluate`.

## Required Input

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` |

`evaluate` requires completed `formulate`, `protocol`, `clean`, `examine`, and `analyze` stages. Do not start from partial upstream context.

## What Prior Outputs This Stage Reads

The stage reads:

- `skeptic_documentation/01_formulation.md` - approved question, question type, target quantity or estimand, claim boundary, route candidates, unit of analysis, assumptions
- `skeptic_documentation/02_protocol.md` - active route, data usage mode, visibility rules, frozen artifacts, leakage and forbidden-variable rules, validation logic, analyze contract-lock obligations, analyze claim limits, backtracking triggers
- `skeptic_documentation/03_cleaning.md` - final visible artifact list, final variable list, population-shift summary, dataset fitness review, open questions, PCS assessment
- `skeptic_documentation/04_examination.md` - support registry, analysis handoff, analysis constraints, fragility verdicts, active-route pressure, PCS assessment
- `skeptic_documentation/05_analysis.md` - analysis contract, deviation register, evaluation handoff (contract summary, execution summary, sensitivity outputs, challenger outputs, flags for evaluate), claim boundary as-narrowed, PCS assessment
- `skeptic_documentation/metrics.md` - formulation, protocol, cleaning, examination, and analysis scorecards, plus the Claim Boundary Registry
- `notebooks/01_formulation.ipynb` - rationale trace for the approved question
- `notebooks/02_protocol.ipynb` - rationale trace for visibility, restriction, and validation rules
- `notebooks/03_cleaning.ipynb` - evidence for cleaned artifacts and cleaning judgments
- `notebooks/04_examination.ipynb` - evidence for support characterization and fragility verdicts
- `notebooks/05_analysis.ipynb` - evidence for contract lock, assumption verification, primary execution, sensitivity execution, challenger execution, and results assembly
- `notebooks/cleaning_functions.py` - reproducible path back to cleaned artifacts when that file exists
- cleaned artifacts produced or named by `clean`
- protocol-defined artifacts under `data/`, `data/splits/`, or another path named in `02_protocol.md`
- `README.md` - confirms prior stage completion

Read all upstream outputs. Keep the approved question, protocol contract, cleaning summary, examination support registry, analysis contract, evaluation handoff, claim boundary as-narrowed, and Claim Boundary Registry in active context throughout the stage. These are not checkboxes. They are the constraints the evaluation must satisfy.

No additional user input is required if upstream stages are complete. If upstream outputs are incomplete, contradictory, or missing required sections, stop and repair the upstream stage. Do not invent evaluation permissions around gaps.

## Route Resolution

Before Cycle A, do this in order:

1. Read `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `04_examination.md`, `05_analysis.md`, `metrics.md`, `01_formulation.ipynb`, `02_protocol.ipynb`, `03_cleaning.ipynb`, `04_examination.ipynb`, `05_analysis.ipynb`, and `README.md`.
2. Resolve exactly one active route from upstream outputs. Use the confirmed question type in `01_formulation.md` and `02_protocol.md` as the anchor. If `02_protocol.md` contradicts it or does not collapse to one route for `evaluate`, stop and reopen `protocol`.
3. Load exactly one stage-specific route file:

| Route | File |
|-------|------|
| `descriptive` | `references/routes/descriptive/evaluate.md` |
| `exploratory` | `references/routes/exploratory/evaluate.md` |
| `inferential` | `references/routes/inferential/evaluate.md` |
| `predictive` | `references/routes/predictive/evaluate.md` |
| `causal` | `references/routes/causal/evaluate.md` |
| `mechanistic` | `references/routes/mechanistic/evaluate.md` |

4. Keep that route context in memory for the rest of `evaluate` and reuse it across cycles in the same chat.
5. If route context becomes ambiguous mid-stage, reread `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `04_examination.md`, `05_analysis.md`, and the same route file before proceeding.
6. If the active route cannot be resolved or the expected route file is missing, stop and route back upstream.

## Precondition Gate

Run this gate before anything else.

Verify all of the following:

- `skeptic_documentation/01_formulation.md` exists
- `skeptic_documentation/02_protocol.md` exists
- `skeptic_documentation/03_cleaning.md` exists
- `skeptic_documentation/04_examination.md` exists
- `skeptic_documentation/05_analysis.md` exists
- `skeptic_documentation/metrics.md` exists
- `notebooks/01_formulation.ipynb` exists
- `notebooks/02_protocol.ipynb` exists
- `notebooks/03_cleaning.ipynb` exists
- `notebooks/04_examination.ipynb` exists
- `notebooks/05_analysis.ipynb` exists
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
- explicit visibility rules
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
- fragility verdicts

Verify `05_analysis.md` contains:

- `## Analysis Contract`
- `## Deviation Register`
- `## Evaluation Handoff`
- `## PCS Assessment`
- contract summary (estimand, method family, primary specification, perturbation plan, challengers, claim boundary as-narrowed)
- execution summary (primary outputs, sensitivity outputs, challenger outputs, computational issues)
- deviation register entries or an explicit "no deviations" statement
- contract amendments or an explicit "no amendments" statement
- flags for evaluate
- handoff discipline statement

Verify `metrics.md` contains `## Claim Boundary Registry` with:

- `claim_type`
- `scope`
- `target_quantity`
- `verbs_allowed`
- `verbs_forbidden`
- `evidence_ceiling`
- `generalization_limit`
- `narrowing_log`

Resolve the active route from `01_formulation.md` plus `02_protocol.md`.

Verify the matching file `references/routes/{route}/evaluate.md` exists.

If any required field, artifact, or restriction is missing or contradictory:

- stop
- tell the user exactly what is missing or inconsistent
- route back to `analyze`, `examine`, `clean`, `protocol`, or `formulate` as appropriate

Do not proceed with partial context.

## Guiding Principle

The goal of `evaluate` is to adjudicate whether analysis outputs and claims survive route-appropriate PCS checks, rendering per-claim survival verdicts that gate what `communicate` may package.

Use `evaluate` to:

- verify that analysis outputs address the approved question within the approved claim boundary
- compare analysis outputs against examination-stage support expectations; if a result materially reverses the sign or magnitude that `examine` made plausible, explain why or route back upstream
- adjudicate whether sensitivity and challenger divergence from `analyze` constitutes instability
- execute the route-appropriate predictability reality check specified by `protocol`
- stress-test results against threats to validity using route-required formal tools plus construct validity checks, bias inversion, and tightly-scoped expert falsification when feasible
- render per-claim survival verdicts: survived, survived with caveats, did not survive
- determine whether backtracking is required
- produce the structured handoff that `communicate` receives

Do not use `evaluate` to:

- re-execute analysis or fit new models
- generate new claims beyond what the analysis contract was designed to support
- widen the claim boundary
- add post-hoc analyses after seeing results
- choose between methods or specifications
- package findings for an audience or recommend actions
- re-clean data or re-examine distributions
- revise the approved question, protocol, or route
- improvise route-specific permissions beyond the loaded route file and protocol contract

Implications and recommendations belong to `communicate`. `evaluate` may synthesize whether the evidence is defended, threatened, or fatal, but it does not turn that synthesis into audience-facing advice.

If no claims survive, say so and route the project back upstream. Do not manufacture survivable claims from insufficient evidence.

## Setup

Before Cycle A, create:

1. `notebooks/06_evaluation.ipynb` with a header cell containing:
   - stage title
   - date
   - project name
   - approved question
   - question type
   - target quantity
   - claim boundary as-narrowed (from analyze)
   - active route
   - protocol mode
   - analysis contract summary (method family, primary specification)
   - perturbation plan summary
   - challenger list
   - flags for evaluate (from analyze handoff)
   - upstream dependency note: `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `04_examination.md`, `05_analysis.md`
   - note: "This notebook is stage-core only. The loaded route file may narrow or prohibit actions. This stage does not re-execute analysis, widen the claim boundary, or generate new claims."

**The evaluate notebook is not optional.** Unlike a documentation-only stage, evaluate must contain executable verification cells that programmatically confirm reproducibility and claim compliance. At minimum, the notebook must:
- re-verify SHA-256 hashes of all protocol-frozen artifacts
- re-load and re-compute at least one key metric from each analysis output to confirm reproducibility
- programmatically check that the claim boundary was not widened (compare `claim_boundary_registry.yaml` against communicated claims if available)
- document all PCS checks with executable evidence, not just prose assertions

A `06_evaluation.md` without a corresponding executed `06_evaluation.ipynb` is a blocking defect at the stage boundary. The stage-boundary validator Check 4 enforces this.

2. `skeptic_documentation/06_evaluation.md` with this initial structure:

```markdown
# Evaluate: Route-Appropriate PCS Evaluation

## Dataset
- Source: {raw data file(s)}
- Approved question: {from 01_formulation.md}
- Question type: {from 01_formulation.md}
- Target quantity: {from 01_formulation.md}
- Claim boundary as-narrowed: {from 05_analysis.md}
- Protocol mode: {from 02_protocol.md}
- Active route: {from 02_protocol.md}
- Analysis contract: {method family and primary specification from 05_analysis.md}
- Perturbation plan: {from 05_analysis.md}
- Challengers: {from 05_analysis.md}
- Date started: {date}

## Upstream Contract
- Approved question: {from formulate}
- Question type: {from formulate}
- Target quantity: {from formulate}
- Claim boundary as-narrowed: {from analyze}
- Active route: {from protocol}
- Protocol mode: {from protocol}
- Validation logic required: {from protocol}
- Support registry summary: {from examine}
- Analysis contract summary: {from analyze}
- Flags for evaluate: {from analyze}

## Evaluation Plan

## Decision Log

## Claim Survival Registry

## Communicate Handoff

## PCS Assessment
```

The notebook header must state the approved question, question type, target quantity, claim boundary as-narrowed, active route, analysis contract summary, perturbation plan, challengers, and flags for evaluate explicitly. `evaluate` starts only after those fields are written.

## Stage Map

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Intake audit and evaluation plan | Yes |
| B | Stability adjudication | Yes |
| C | Predictability adjudication | Yes |
| D | Threats to validity | Yes |
| E+ | Follow-up investigation | No |
| F | Claim survival determination | Yes |
| G | Evaluation assembly and handoff | Yes |

Cycles A, B, C, D, F, and G are mandatory. E+ is a narrow follow-up window for ambiguities from B, C, or D that must be resolved before claim survival in F. It is not a license for re-analysis or open-ended exploration.

## Execution Gates

Before each cycle, verify the required outputs from prior work exist. If anything is missing, stop and tell the user exactly what is missing.

| Before | Required state |
|--------|----------------|
| Cycle A | Precondition gate passed. Setup files exist. Route file loaded. |
| Cycle B | `06_evaluation.md` contains `### Cycle A` log entry with an evaluation plan. `06_evaluation.ipynb` has Cycle A outputs. |
| Cycle C | `06_evaluation.md` contains `### Cycle B` log entry with stability verdicts. |
| Cycle D | `06_evaluation.md` contains `### Cycle C` log entry with predictability verdicts. |
| Cycle F | `06_evaluation.md` contains `### Cycle B`, `### Cycle C`, and `### Cycle D` log entries. Any approved E+ follow-ups are closed. |
| Cycle G | `06_evaluation.md` contains `### Cycle F` log entry with claim survival verdicts. User approved the claim survival registry. |
| Post-cycle Phase 1 | Mandatory cycle loop complete. User has indicated the stage is ready for post-cycle review. |

## Gate Condition Registry

Every evaluation gate has a stable ID used in cycle metrics. The evaluation subagent references these IDs in its structured output.

### Cycle A: Intake Audit and Evaluation Plan

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `A-handoff-complete` | A01, A02 | All required sections and fields from the analyze evaluation handoff are present |
| `A-flags-inventoried` | A03 | Every flag from analyze's evaluation handoff is explicitly acknowledged |
| `A-divergence-triaged` | A04 | First-pass triage of sensitivity and challenger divergence is documented |
| `A-plan-derived` | A05, A06 | Evaluation plan is derived from upstream contracts, not invented ad hoc |
| `A-route-checks-identified` | A06 | Route-specific checks from the loaded route file are enumerated |
| `A-outputs-accounted` | A07 | All primary, sensitivity, and challenger outputs are present and accounted for |

### Cycle B: Stability Adjudication

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `B-perturbation-axes-covered` | B01, B02 | Every perturbation axis from the analyze contract is adjudicated |
| `B-challengers-adjudicated` | B01, B03 | Every challenger from the analyze contract is adjudicated |
| `B-divergence-classified` | B02, B03, B05 | Each divergence is classified as acceptable variation, instability requiring caveat, or instability requiring backtracking |
| `B-judgment-call-weighted` | B04 | Judgment-call perturbation axes are weighted alongside data perturbation axes, not dismissed |
| `B-verdict-grounded` | B06 | Stability verdicts reference specific notebook evidence from analyze, not assertions |
| `B-backtracking-assessed` | B07 | If any claim is unstable, whether backtracking is required or instability can be carried as a caveat is assessed |

### Cycle C: Predictability Adjudication

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `C-reality-check-executed` | C01, C02 | The protocol-specified reality check is executed on actual data in the notebook |
| `C-protocol-match` | C01 | The reality check matches what protocol specified, not a substitute |
| `C-visibility-respected` | C02 | If held-out data is unsealed, it is authorized by protocol for this stage |
| `C-reality-check-compared` | C03 | Reality-check outputs are compared against primary analysis outputs |
| `C-verdict-grounded` | C04, C05 | Predictability verdict references specific notebook outputs, not assertions |

### Cycle D: Threats to Validity

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `D-formal-tools-applied` | D01, D02, D03 | Route-specific formal tools are applied where the route overlay requires them |
| `D-construct-validity-checked` | D05 | Whether the operationalized measure captured the intended concept is explicitly assessed |
| `D-bias-inversion-executed` | D04 | The adversarial thought experiment is documented: assume incorrect, reason backward to identify plausible systematic errors |
| `D-expert-falsification-attempted` | D06 | Expert falsification is attempted or the gap is documented with justification |
| `D-threats-grounded` | D01, D02, D03, D04, D05, D06 | Validity verdicts reference specific evidence, not speculation |
| `D-validity-verdicted` | D07 | For each threat assessed, a validity verdict is rendered (defended, threatened, or fatal) |
| `D-examine-aligned` | D08 | Examination-stage support expectations are compared against the primary result, including direction and magnitude |
| `D-scale-translated` | D09 | Key magnitudes are translated into human-relevant or scientific-scale units before verdicts are rendered |
| `D-variance-compared` | D10 | Variation from cleaning or preprocessing judgment calls is compared against sampling or resampling variance |
| `D-blind-comparison` | D11 | Rival outputs or alternative summaries are compared under masked or blinded labels when feasible |

### Cycle F: Claim Survival Determination

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `F-every-claim-verdicted` | F01, F02 | Every claim the analysis contract was designed to support has a verdict |
| `F-no-survived-contradicts-fail` | F03 | No "survived" verdict contradicts a FAIL from Cycles B, C, or D |
| `F-caveats-explicit` | F02 | Every "survived with caveats" verdict has explicit caveats stated |
| `F-boundary-respected` | F04, F05 | No claim exceeds the claim boundary as-narrowed from analyze |
| `F-dead-claims-stated` | F02 | Claims that did not survive are explicitly listed with reasons |
| `F-narrowing-logged` | F06 | If the final claim boundary is narrower, the narrowing is appended to the Claim Boundary Registry narrowing_log |
| `F-registry-presented` | F07 | Claim Survival Registry is produced and presented to the user for explicit approval |
| `F-interpretation-synthesized` | F08 | A concise overall interpretation synthesis ties stability, predictability, validity, and examine-stage support together without audience framing |

### Cycle G: Evaluation Assembly and Handoff

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `G-registry-complete` | G01 | Claim survival registry is complete and internally consistent |
| `G-handoff-complete` | G02, G03, G04, G05, G06, G07 | Communicate handoff contains all required sections |
| `G-no-audience-framing` | G07 | Handoff contains no audience framing, narrative suggestions, hedging language, or recommendations |
| `G-limitations-mandatory` | G04 | Mandatory limitations for communicate are explicitly listed |
| `G-boundary-final` | G06 | Final claim boundary is explicitly stated |
| `G-handoff-stated` | G08 | Explicit handoff statement that the next stage is communicate |

## Cycle Protocol

Apply this protocol to every cycle.

### Step 0: Progress Indicator

At the start of each cycle, print:

`"Evaluate stage: Cycle {X} ({focus}) - {mandatory/optional} - {ordinal} of 6 mandatory cycles"`

For post-cycle phases, print:

`"Evaluate stage: Post-cycle Phase {N} ({name})"`

### Step 1: Setup and Execution

- Claude reads existing notebook outputs. Skip this only for Cycle A beyond the header.
- Claude reads `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `04_examination.md`, `05_analysis.md`, and `metrics.md` before every cycle. Treat the approved question, question type, claim boundary as-narrowed, active route, protocol validation logic, cleaning-side population and measurement constraints, analysis contract, flags for evaluate, and Claim Boundary Registry as hard constraints.
- Claude reuses the route context already loaded at stage start from `references/routes/{route}/evaluate.md`.
- If route context becomes ambiguous, Claude rereads `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `04_examination.md`, `05_analysis.md`, `metrics.md`, and the same route file before proceeding.
- If the active route cannot be confirmed or the expected route file is missing, stop and reopen upstream. Do not guess.
- Claude identifies what evaluation work the current cycle must produce.
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
  description="Research for Evaluate Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a methodological research assistant for a Skeptic evaluate stage.

  Context:
  - Approved question: "{approved question}"
  - Question type: {question type}
  - Target quantity: {target quantity}
  - Claim boundary as-narrowed: {claim boundary}
  - Active route: {route}
  - Protocol mode: {protocol mode}
  - Analysis contract: {method family and primary specification}
  - Flags for evaluate: {flags from analyze handoff}
  - Current notebook findings: {findings from this cycle}
  - User observations: {if any}

  Answer these research questions for Cycle {X} ({focus}):
  {insert cycle-specific research questions}

  Rules:
  - Stay inside the approved question, protocol, and active route.
  - Focus on methodological adjudication guidance, not domain discovery.
  - If a question does not apply, say "not applicable" with a one-line reason.
  - Cite sources for claims that would change an evaluation verdict.

  Return concise findings organized by research question. Include the URL for every resource cited.
  """
)
```

**Evaluation subagent:**

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Evaluate Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a Skeptic evaluate-stage cycle.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/06_evaluation.md
  2. {projects_root}/{project-name}/{notebooks_dir_name}/06_evaluation.ipynb
  3. {projects_root}/{project-name}/{docs_dir_name}/05_analysis.md
  4. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  5. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.md
  6. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.md
  7. {projects_root}/{project-name}/{docs_dir_name}/04_examination.md
  8. {projects_root}/{project-name}/{docs_dir_name}/metrics.md

  Cycle focus: {focus description}
  User observations: {if any}

  Before evaluating gates, verify that all checklist items for this cycle were
  answered with evidence in the notebook. If any checklist item was not answered,
  the gates that depend on it auto-fail.

  Claim Boundary Registry check:
  Read the Claim Boundary Registry from `metrics.md`. Verify that this cycle's
  adjudication uses only verbs from `verbs_allowed`, stays within `scope`,
  respects `generalization_limit`, and appends to `narrowing_log` if evaluation
  narrows the claim boundary. Any widening is a BLOCKING defect.

  Applicable gates for this cycle:
  {list gate IDs}

  Evaluation focus for Cycle {X} ({focus}):
  The evaluation subagent checks:
  1. For each checklist item: was it answered with evidence in the notebook?
     If not, dependent gates auto-fail.
  2. For each gate where depends_on includes items from this cycle: does the
     answer satisfy the condition?

  Task:
  1. Verify each checklist item for this cycle was answered with evidence.
  2. Evaluate each applicable gate using notebook evidence, auto-failing gates
     whose depends_on checklist items were not answered.
  3. Identify up to 3 findings that determine whether the cycle should pass.
  4. Flag any move that widens the claim boundary, re-executes analysis, generates new claims, or adds post-hoc checks not in the evaluation plan.
  5. Treat any Claim Boundary Registry violation as a BLOCKING defect.
  6. Recommend: pass / iterate on {topic} / acknowledge gap / backtrack to {stage}.

  Output format:

  EVALUATION: Cycle {X} - {focus}
  Verdict: PASS / FAIL
  Justification: [state facts, not opinions]

  Checklist coverage:
  - {item_id}: ANSWERED / NOT ANSWERED - [evidence cell or gap]
  (list every checklist item for this cycle)

  Gate assessments:
  - {gate_id}: PASS / FAIL - [evidence] - depends_on: [{item_ids}]
  (list every applicable gate)

  Key findings:
  - [finding]
  - [finding]
  - [finding]

  Claim boundary: {unchanged / narrowed / WIDENED (flag)}
  Gaps remaining: [list, or "none"]
  Recommended next step: pass / iterate / acknowledge gap / backtrack to {stage}
  Recommended follow-up cycle: [topic and why] / None

  Adversarial stance: Assume the work contains errors. Actively try to
  falsify each gate rather than confirm it. For each gate marked PASS,
  state the specific failure mode you checked and ruled out. If after
  genuinely adversarial scrutiny you find zero issues, name at least 3
  specific failure modes you tested and ruled out. Do not fabricate
  findings to meet a quota. Be objective, not harsh, not lenient.
  """
)
```

### Step 4: Decision

When both subagents return, Claude synthesizes them into one cycle assessment. Do not present disconnected subagent reports as if they were the stage decision. Log the raw subagent outputs inside the stage's decision log (the main `0X_{stage}.md` document) under a `### Cycle {X} raw subagent outputs` subsection. The research subagent's output must include the URLs for every resource it cites.

Count the blocking failures from the evaluation subagent output: blocking defects plus gates with verdict FAIL. Then apply the decision matrix.

**Decision matrix:**

| blocking_failures | forward actions allowed | note |
|-------------------|------------------------|------|
| 0 | pass, iterate | cycle meets minimum bar |
| > 0 | iterate, acknowledge gap (with written justification) | pass is blocked until blocking failures are resolved or justified |

**Always-available actions (regardless of blocking_failures):**

- **Reopen analyze** -> stop and reopen `analyze`
- **Reopen examine** -> stop and reopen `examine`
- **Reopen protocol** -> stop and reopen `protocol`
- **Reopen formulate** -> stop and reopen `formulate` plus `protocol`
- **User override** -> user states the specific reason the FAIL is incorrect, logged as `override: {reason}`, forward actions unlock

Interactive mode: present the synthesized assessment to the user via the **AskUserQuestion** tool, offering the allowed actions from the matrix as selectable options. Do not invoke any other tool until the user answers. The answer is the only valid trigger for continuing.

Auto mode: apply the autonomous decision protocol from `references/auto-mode.md`, log the rationale, and continue without waiting unless an escalation trigger fires.

**Cycle F special rule:** Interactive mode requires explicit user approval of the claim survival registry before Cycle G begins. Auto mode logs the registry, runs any bounded auto-iteration needed, and defers human approval to the stage-boundary summary unless an escalation trigger fires.

### Step 5: Log

Immediately after each cycle decision, append to `skeptic_documentation/06_evaluation.md`:

```markdown
### Cycle {X}: {Focus}
- **What we inspected:** {notebook cells run, outputs reviewed}
- **Checklist coverage:** {answered}/{total} items answered with evidence
- **Research findings:** {key findings from research subagent}
- **Evaluation verdict:** PASS / FAIL
- **Gate assessments:** {gate_id}: PASS/FAIL for each applicable gate
- **Blocking failures:** {n} ({list gate_ids that failed, or "none"})
- **Overrides:** {list override reasons, or "none"}
- **Stability verdict:** {stable / conditionally stable / unstable, per claim or axis where applicable}
- **Predictability verdict:** {adequate / marginal / inadequate, where applicable}
- **Validity verdict:** {defended / threatened / fatal, where applicable}
- **Claim boundary:** {unchanged / narrowed to {new boundary} because {reason}}
- **Gaps:** {remaining gaps, if any}
- **Decision:** {pass / iterate / acknowledge gap / backtrack to {stage}}

#### Cycle {X} raw subagent outputs

##### Research subagent
{verbatim output, including every source URL}

##### Evaluation subagent
{verbatim output, including DEFECT SCAN, SEVERITY CLASSIFICATION, GATE ASSESSMENTS, Alternatives considered, Gaps, Protocol implications, Recommended follow-up, VERDICT}
```

Also append structured cycle metrics to `skeptic_documentation/metrics.md`. Create the section `## Evaluation` if it does not yet exist.

```markdown
**Cycle metrics:**
- iterations: {n}
- verdict: PASS/FAIL (on iteration {n})
- checklist_coverage: {answered}/{total}
- gates: [{gate_id}: PASS/FAIL, ...]
- blocking_failures: {n}
- overrides: {n} ({list reasons, or "none"})
- research_sources_returned: {n}
- evaluation_verdict_aligned: yes/no/partial/indeterminate
- claims_assessed: {n}
- backtracking_triggered: none/analyze/examine/clean/protocol/formulation+protocol
```

If the claim boundary narrows in this cycle, append an entry to the Claim Boundary Registry `narrowing_log` in `metrics.md` with: cycle, prior boundary, new boundary, and rationale. `evaluate` may tighten the registry. It may not loosen it.

**Raw-subagent-outputs rule.** The `#### Cycle {X} raw subagent outputs` subsection is mandatory. The evaluation subagent auto-fails the cycle if that subsection is missing, empty, or contains paraphrased rather than verbatim output. The research subagent's raw output must include every source URL it cites.

**Cycle-state invariant.** After Step 5, the notebook, the stage document (`0X_{stage}.md`), `metrics.md`, and the README must all agree on the same "active cycle" pointer. Each cycle begins by verifying this invariant and ends by restoring it: the log entry for Cycle {X} and its metrics row are appended, the README stage-status line is updated to reflect Cycle {X}'s outcome, and only then may Cycle {X+1} work begin in the notebook.

## Cycle A: Intake Audit and Evaluation Plan

**Focus:** Verify that `analyze` produced a complete evaluation-ready package, inventory all flags, triage divergence, and derive the evaluation plan from upstream contracts.

This cycle does not adjudicate. It maps the territory before adjudication begins.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| A01 | Is the approved question, question type, target quantity, claim boundary as-narrowed, active route, and protocol mode restated from upstream? | never |
| A02 | Is the full evaluation handoff from `05_analysis.md` loaded and displayed (contract summary, execution summary, deviation register, contract amendments, flags for evaluate)? | never |
| A03 | Is every flag from the analyze handoff inventoried with: what it is, which claim it affects, and which evaluation cycle (B, C, or D) will address it? | never |
| A04 | Is first-pass divergence triage documented for each perturbation axis and each challenger (minor / notable / major)? | never |
| A05 | Is the evaluation plan derived from upstream contracts (protocol validation logic, claim ceiling, perturbation axes, challengers, route-specific checks)? | never |
| A06 | Are all route-specific checks from the loaded route file enumerated and mapped to cycles B, C, and D? | never |
| A07 | Are all primary outputs, sensitivity outputs, and challenger outputs present and accounted for? | never |
| A08 | Are all deviations in the analyze deviation register checked against the formulation pre-registration prohibited-use list? Any deviation that enables a prohibited use is a BLOCKING defect. | never |

Claude writes notebook cells using this default sequence:

1. Restate the approved question, question type, target quantity, claim boundary as-narrowed, active route, and protocol mode.
2. Load and display the full evaluation handoff from `05_analysis.md`: contract summary, execution summary, deviation register, contract amendments, and flags for evaluate.
3. Verify completeness: are all primary outputs present? All sensitivity outputs? All challenger outputs? Is the deviation register present? Is the claim boundary as-narrowed explicitly stated?
4. Inventory every flag from the analyze handoff. For each flag, state: what it is, which claim it affects, and which evaluation cycle (B, C, or D) will address it.
5. Perform first-pass divergence triage: for each perturbation axis and each challenger, compute the magnitude of divergence from the primary result. Classify each as: minor (within expected range), notable (warrants close examination in B), or major (likely instability signal).
6. Derive the evaluation plan from upstream contracts:
   - from `protocol`: what validation logic is required, what the claim ceiling is
   - from the analysis contract: what perturbation axes exist, what challengers exist
   - from the route overlay: what route-specific checks are required
   - produce a checklist of all evaluation checks this stage must perform, mapped to cycles B, C, and D
7. Write the `## Evaluation Plan` section in `06_evaluation.md`.

Do not render stability, predictability, or validity verdicts in this cycle. Inventory and plan only.

**Research questions:**

- What evaluation standards are typical for this route and method family?
- What divergence magnitudes are considered concerning versus routine for this method applied to similar data profiles?
- Are there known evaluation pitfalls specific to this analysis approach?

## Cycle B: Stability Adjudication

**Focus:** Adjudicate whether sensitivity and challenger divergence from `analyze` constitutes instability that undermines claims.

`analyze` Cycle D produced sensitivity outputs (perturbation axes) and challenger outputs but explicitly did not interpret whether divergence constitutes instability. That judgment happens here. The verdict is grounded in the actual notebook outputs from `analyze`, not hypothetical scenarios.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| B01 | Are all perturbation axes and challengers from the analysis contract explicitly stated as being adjudicated? | never |
| B02 | For each perturbation axis, is the direction of change, magnitude of change, whether the qualitative conclusion changes, and whether the claim boundary needs narrowing documented? | never |
| B03 | For each challenger, is it documented whether it contradicts the primary conclusion, the magnitude and direction of disagreement, and whether disagreement is structural or parametric? | never |
| B03a | If formulate's Cycle D identified competing operationalizations that diverged, are they represented in the challenger set? If not, document the gap as a caveat on claim stability. | never |
| B04 | Are judgment-call perturbation axes weighted alongside data perturbation axes (not dismissed as less important)? | never |
| B05 | Is the convergence/divergence framework applied: convergent results strengthen, divergent results diagnosed as genuine instability vs. known limitation vs. execution artifact? | never |
| B06 | For each claim, is a stability verdict rendered (stable / conditionally stable / unstable) with specific notebook evidence? | never |
| B07 | If any claim is unstable, is there an assessment of whether backtracking is required or whether instability can be carried as a caveat? | no claim is unstable |

Claude writes notebook cells using this default sequence:

1. State which perturbation axes and challengers from the analysis contract are being adjudicated.
2. For each perturbation axis, load the sensitivity outputs from `05_analysis.ipynb` and compute:
   - direction of change relative to primary
   - magnitude of change relative to primary
   - whether the qualitative conclusion changes
   - whether the claim boundary would need narrowing
3. For each challenger, load the challenger outputs from `05_analysis.ipynb` and compute:
   - whether the challenger contradicts the primary conclusion
   - magnitude and direction of disagreement
   - whether the disagreement is structural (different method, different conclusion) or parametric (same direction, different magnitude)
4. Weight judgment-call perturbation axes alongside data perturbation axes. Do not dismiss judgment-call sensitivity as less important than sampling sensitivity. Both contribute to total uncertainty.
5. Apply the convergence/divergence framework:
   - convergent results (primary and alternatives agree): strengthen the claim
   - divergent results (primary and alternatives disagree): diagnose whether divergence reflects genuine instability, a known method limitation, or an execution artifact
6. For each claim the analysis contract was designed to support, render a stability verdict:
   - **stable**: conclusions survive all perturbation axes and challengers
   - **conditionally stable**: conclusions survive most perturbations but are sensitive to specific axes; caveats required
   - **unstable**: conclusions change materially under reasonable perturbations; claim must be downgraded or killed
7. If any claim is unstable, assess whether backtracking is required or whether the instability can be carried as an explicit caveat.

All challengers producing different results is NOT a backtracking trigger. It is a finding that informs the stability verdict. Only render instability as a backtracking trigger when the divergence invalidates the primary conclusion across the claim boundary.

**Research questions:**

- What stability thresholds are standard for this route and method family?
- What magnitude of perturbation divergence is typical versus concerning in published work with similar data profiles?
- How do domain standards treat judgment-call perturbation versus data perturbation uncertainty?
- Do any perturbation or challenger results suggest an execution artifact rather than genuine sensitivity?

## Cycle C: Predictability Adjudication

**Focus:** Execute the route-appropriate predictability reality check specified by `protocol` and render a predictability verdict.

Predictability is not always held-out prediction. It is the route-appropriate reality check that `protocol` specified. The check is grounded in actual data and notebook outputs.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| C01 | Is the specific predictability check that `protocol` specified for this project explicitly stated? | never |
| C02 | Is the specified check executed on actual data in the notebook (with visibility rules respected if held-out data is unsealed)? | never |
| C03 | Are reality-check outputs compared against primary analysis outputs? | never |
| C04 | Is it assessed whether the primary finding holds on the reality-check data or procedure, whether magnitude is consistent or shifts materially, and whether calibration is adequate (where relevant)? | never |
| C05 | For each claim, is a predictability verdict rendered (adequate / marginal / inadequate)? | never |

Claude writes notebook cells using this default sequence:

1. State what predictability check `protocol` specified for this project. This may be:
   - held-out or temporal validation performance (predictive routes)
   - refreshed-data replication or external corroboration (descriptive routes)
   - resampling consistency or bootstrap stability (inferential routes)
   - perturbation-based pattern persistence (exploratory routes)
   - falsification or placebo tests (causal routes)
   - simulation-based validation or boundary-condition checks (mechanistic routes)
   - another protocol-specified reality check
2. Execute the specified check on actual data in the notebook. If held-out data must be unsealed, verify that `protocol` authorizes unsealing at this stage.
3. Compare the reality-check outputs against the primary analysis outputs.
4. Assess whether the result passes the reality check:
   - does the primary finding hold on the reality-check data or procedure?
   - is the magnitude consistent or does it shift materially?
   - is calibration adequate (for routes where calibration matters)?
5. For each claim, render a predictability verdict:
   - **adequate**: reality check passed; result reemerges in the new scenario
   - **marginal**: reality check partially passed; some aspects hold, others are weaker
   - **inadequate**: reality check failed; result does not reemerge

**Research questions:**

- What predictability benchmarks exist for this route and domain?
- What baseline performance or replication rates are considered adequate for similar projects?
- Are there known calibration pitfalls for this method family?
- When the protocol-specified reality check is not held-out prediction, what standards exist for the chosen check type?

## Cycle D: Threats to Validity

**Focus:** Stress-test results against threats that could make the findings wrong or misleading, even though the analysis executed successfully.

This cycle is distinct from `analyze` Cycle B (assumption verification). `analyze` Cycle B checked whether model assumptions hold on actual data before execution. Cycle D asks: given that execution succeeded, what could still make the result wrong? This covers construct validity drift, route-specific formal validity tools, bias inversion, and expert falsification.

Cycle D has two phases: formal route-specific tools and qualitative adversarial review.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| D01 | Are the formal tools required by the route overlay for this route explicitly stated? | never |
| D02 | Is each required formal tool executed on actual data in the notebook? | route overlay requires no formal tools |
| D03 | For each formal tool, is the output documented with: what was tested, what the output was, and what it implies for claim survival? | route overlay requires no formal tools |
| D04 | Bias inversion: enumerate against ROBINS-I seven domains (confounding, participant selection, exposure classification, protocol departure, missing data, outcome measurement, reporting selection) plus immortal-time, Berkson, and positivity-violation; for each domain record plausibility (present / absent / unknown), direction, and whether it is fatal, threatening, or defended. | never |
| D05 | Is construct validity assessed: does the operationalized measure still capture the intended concept after the full pipeline, or did the measurement chain drift? | never |
| D06 | Is expert falsification attempted (using only already-executed challengers, protocol-specified outputs, or conceptual critique) or is the gap documented with justification? | never |
| D07 | For each threat assessed, is a validity verdict rendered (defended / threatened / fatal)? | never |
| D08 | Is the examination-stage support expectation compared against the primary result, including direction and magnitude, and are any reversals explained? | never |
| D09 | Are key magnitudes translated into human-relevant or scientific-scale units before verdicts are rendered? | never |
| D10 | Is variation induced by cleaning or preprocessing judgment calls compared against sampling or resampling variance? | never |
| D11 | When rival outputs or alternative summaries are compared, are masked or blinded labels used when feasible to reduce confirmation bias? | never |

**Phase 1: Formal route-specific tools.** The route overlay defines which tools apply. Claude writes notebook cells that:

1. State which formal tools the route overlay requires for this route. Examples:
   - Causal: E-values, Gamma-bounds, Cinelli-Hazlett robustness values for sensitivity to unmeasured confounding
   - Inferential: specification sensitivity, uncertainty calibration assessment
   - Predictive: calibration slope, reliability diagrams, drift assessment
   - Descriptive: aggregation stability, denominator integrity under alternative definitions
   - Exploratory: alternative representation stability, triangulation across methods
   - Mechanistic: structural identifiability, practical identifiability, parameter plausibility
2. Execute each required tool on actual data in the notebook.
3. For each tool, document: what was tested, what the output was, and what it implies for claim survival.

**Phase 2: Qualitative adversarial review.** Claude writes notebook cells that:

4. Execute the bias inversion thought experiment: assume the primary result is incorrect. Reason backward to identify what systematic error (selection bias, confounding, measurement mismatch, recall bias, survivorship bias, or another plausible error) would produce the observed result. Assess the plausibility of each candidate error given the data, design, and upstream audit trail.
5. Assess construct validity: does the operationalized measure from `formulate` still capture the intended concept after the full pipeline? Did the measurement chain from formulate through analyze hold together, or did it drift?
6. Attempt expert falsification when feasible, but keep it inside evaluation scope: use only already-executed challengers, protocol-specified falsification outputs, or conceptual critique from a domain expert. Do not invent a new analysis path, new estimate, or post-hoc specification. If no domain expert is available, document the gap explicitly.
7. Compare the primary result against the support expectations from `examine` and describe whether the sign and magnitude remain within what the support registry suggested was plausible.
8. Convert the key effect size or difference into human-relevant units before final verdicts so the interpretation stays on the scientific scale.
9. Compare variance attributable to cleaning and preprocessing judgment calls against sampling or resampling variance, and flag when upstream choices dominate uncertainty.
10. When comparing rival outputs or summaries, use masked or blinded labels when feasible so confirmation bias does not decide the winner.

For each threat assessed, render a validity verdict:
- **defended**: the threat was assessed and does not undermine the claim
- **threatened**: the threat is plausible and requires a caveat on the claim
- **fatal**: the threat is strong enough to kill the claim or trigger backtracking

**Research questions:**

- What known confounders, biases, or validity threats exist for this domain, question type, and method family?
- What systematic errors are most plausible given the data-generating process and collection method?
- What construct validity evidence exists for the operationalized measures?
- When similar studies have produced incorrect conclusions, what was the root cause?

## Cycles E+: Follow-up Investigation

Use an E+ follow-up only when a material ambiguity from Cycles B, C, or D must be resolved before rendering claim survival verdicts in Cycle F.

An E+ cycle must be narrow and issue-specific. Define only:

- the unresolved ambiguity from B, C, or D
- why it materially affects claim survival
- what evidence is still needed
- what concrete resolution the follow-up targets

Use E+ for issues such as:

- clarifying whether a specific stability concern changes the qualitative conclusion or only the magnitude
- resolving whether a marginal predictability result tips to adequate or inadequate with one additional check
- requesting domain-expert input on a specific validity threat
- disentangling an execution artifact from genuine instability

Do not turn E+ into re-analysis, unrestricted exploration, or post-hoc testing. If the issue requires new analysis computation, backtrack to `analyze`. If the issue is a cleaning, protocol, or formulation problem, route back upstream.

E+ cycles follow the same cycle protocol. They must end with an explicit decision and immediate logging.

Each E+ cycle must define its own checklist items scoped to the specific follow-up topic. Use IDs in the format F{n}01, F{n}02, etc. (e.g., F101, F102 for the first follow-up; F201, F202 for the second). Add the corresponding gates and depends_on links to the cycle log.

## Cycle F: Claim Survival Determination

**Focus:** Synthesize verdicts from Cycles B, C, and D into final per-claim survival verdicts.

This is the core adjudication decision of the Skeptic. The user must explicitly approve the claim survival registry before the stage can proceed to Cycle G.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| F01 | Is a claim adjudication table built with one row per claim (claim description, stability verdict, predictability verdict, validity verdict, deviation impact, overall survival verdict)? | never |
| F02 | Is the survival logic applied correctly: survived (all dimensions pass), survived with caveats (conditional dimensions with explicit caveats), did not survive (any fatal dimension)? | never |
| F03 | Is consistency verified: no "survived" verdict contradicts a FAIL gate from Cycles B, C, or D? | never |
| F04 | Is the claim boundary verified against the analyze handoff and Claim Boundary Registry (no widening, no forbidden verbs, no scope expansion)? | never |
| F05 | Is the final claim boundary stated as it stands after evaluation (may be narrower, never wider)? | never |
| F06 | If the final claim boundary is narrower, is the narrowing appended to the Claim Boundary Registry `narrowing_log`? | claim boundary did not narrow |
| F07 | Is the `## Claim Survival Registry` produced in `06_evaluation.md` and presented to the user for explicit approval? | never |
| F08 | Is a concise overall interpretation synthesis written that ties stability, predictability, validity, and examine-stage support together without audience framing or recommendations? | never |
| F09 | Do surviving claims speak to the stakeholder decision and candidate actions named in formulate A06, or has the claim drifted to a different decision? | never |

Claude writes notebook cells using this default sequence:

1. Build a claim adjudication table with one row per claim the analysis contract was designed to support. Columns:
   - claim description
   - stability verdict from Cycle B (stable / conditionally stable / unstable)
   - predictability verdict from Cycle C (adequate / marginal / inadequate)
   - validity verdict from Cycle D (defended / threatened / fatal)
   - deviation impact from analyze handoff (none / minor / material)
   - overall survival verdict
2. Apply the survival logic:
   - **survived**: stability is stable, predictability is adequate, validity is defended, no material deviations. The claim passes to communicate without caveats.
   - **survived with caveats**: one or more dimensions show conditional stability, marginal predictability, or a non-fatal validity threat. The claim passes to communicate, but the specific caveats are mandatory and cannot be dropped by communicate. State each caveat explicitly.
   - **did not survive**: any dimension shows instability, inadequate predictability, or a fatal validity threat. The claim does not pass to communicate except as an explicitly acknowledged limitation.
3. Verify consistency: no "survived" verdict may contradict a FAIL gate from Cycles B, C, or D. If a gate failed in an earlier cycle but the cycle still passed (e.g., user acknowledged the gap), the claim must be "survived with caveats" at minimum, with the gap carried as a caveat.
4. Verify claim boundary against both the analyze handoff and the Claim Boundary Registry: no claim may exceed the claim boundary as-narrowed from analyze, expand `scope`, loosen `generalization_limit`, or use verbs outside `verbs_allowed`. If a claim requires widening to survive, it does not survive.
5. State the final claim boundary as it stands after evaluation. It may be narrower than what entered `evaluate`. It must not be wider.
6. If the final claim boundary is narrower than the one that entered `evaluate`, append the narrowing to the Claim Boundary Registry `narrowing_log` in `metrics.md` and tighten the registry fields to match the final boundary.
7. Produce the `## Claim Survival Registry` in `06_evaluation.md`.
8. Present the full registry to the user for explicit approval.
9. Write a short overall interpretation synthesis that states what the evaluated evidence supports, what it does not support, and what the examine-stage support implied before any audience framing.

**Research questions:**

- How are PCS-style claim verdicts typically structured in published veridical data science work?
- What precedents exist for downgrading claims based on partial instability or marginal predictability?
- What conventions exist for distinguishing claims that survived from claims that survived with caveats?

**Cycle F PCS checkpoint.** Before locking verdicts, record one line each: (P) do survival verdicts align with what protocol's validation logic would predict for this evidence profile? (C) would reversing any single adjudication decision change a verdict from survived to survived-with-caveats (or vice versa)? (S) is every verdict traceable to specific notebook outputs from cycles B, C, and D with no assertion-only reasoning? Stability FAIL → re-adjudicate or downgrade the affected verdict.

## Cycle G: Evaluation Assembly and Handoff

**Focus:** Package all evaluation verdicts into the structured handoff for `communicate`. Document limitations. Hand off without audience framing.

This cycle produces the structured handoff that `communicate` must use. It packages verdicts. It does not frame them for an audience.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| G01 | Is the final claim survival registry from Cycle F assembled? | never |
| G02 | For each surviving claim (with or without caveats), is a one-paragraph evidence summary produced citing specific notebook outputs and cycle verdicts? | never |
| G03 | For each claim that did not survive, is a one-line reason produced? | no claims failed to survive |
| G04 | Are mandatory limitations compiled (caveats, acknowledged gaps, validity threats, data limitations, scope restrictions from narrowing)? | never |
| G05 | Are unresolved risks carried forward compiled? | never |
| G06 | Is the final claim boundary stated? | never |
| G07 | Is the `## Communicate Handoff` section drafted in `06_evaluation.md` with all required subsections and handoff discipline? | never |
| G08 | Does the handoff end with an explicit handoff statement that the next stage is `communicate`? | never |

Claude writes notebook cells using this default sequence:

1. Assemble the final claim survival registry from Cycle F.
2. For each surviving claim (with or without caveats), produce a one-paragraph evidence summary citing the specific notebook outputs and cycle verdicts that support it.
3. For each claim that did not survive, produce a one-line reason.
4. Compile mandatory limitations that `communicate` must disclose. These are not optional for `communicate` to drop. They include:
   - caveats from "survived with caveats" claims
   - stability concerns that were carried as acknowledged gaps
   - validity threats that were documented but not fully resolved
   - data limitations surfaced across the pipeline
   - scope restrictions from claim-boundary narrowing
5. Compile unresolved risks carried forward.
6. State the final claim boundary.
7. Draft the `## Communicate Handoff` section in `06_evaluation.md`:

```markdown
## Communicate Handoff

### Claim Survival Registry
- {claim}: {survived / survived with caveats / did not survive} - {one-line evidence summary}
(list every claim)

### Final Claim Boundary
{claim boundary as-final after all narrowing through the full pipeline}

### Per-Dimension Summaries
- Stability: {overall stability summary with per-claim detail where relevant}
- Predictability: {what reality check was applied, whether it passed}
- Threats to validity: {what was tested, what survived, what remains uncertain}

### Mandatory Limitations
- {limitation}: {evidence} - {communicate may not drop this}
(list every mandatory limitation)

### Unresolved Risks
- {risk}: {what is unknown and why}
(list, or "none")

### Handoff Discipline
- Next stage: communicate
- Communicate may package only claims that survived evaluation
- Claims that did not survive may appear only as explicitly acknowledged limitations
- Caveats on survived-with-caveats claims are mandatory -- communicate may not drop them
- Do not widen the claim boundary
- Do not generate recommendations or action items -- that is communicate's job
- Do not frame findings for a specific audience -- that is communicate's job
```

8. End with an explicit handoff statement: next stage is `communicate`. Do not treat the handoff itself as communication.

**Research questions:**

- What evaluation-to-communication packaging standards exist for this route?
- What information does communicate typically need to properly contextualize caveated claims?

## Research Question Guidance

Research questions in `evaluate` must support adjudication, not replace it.

Ask research questions that:

- clarify what divergence magnitudes or stability thresholds are standard for this route and method
- provide benchmarks for predictability or reality-check performance
- identify known validity threats, confounders, or biases for this domain
- contextualize the analysis outputs against published findings or domain expectations
- inform whether an observed pattern is a genuine finding or a known artifact

Do not ask:

- generic literature review questions unrelated to the specific outputs being evaluated
- method-selection questions (the method is locked in the analysis contract)
- questions that assume a different route or question type
- questions that require re-executing analysis to answer

## Backtracking Trigger Registry

These are conditions discovered during `evaluate` that force a return upstream.

| Trigger | Discovered during | Return to |
|---------|-------------------|-----------|
| All claims fail stability -- no claim survives perturbation across the analysis contract | B | `analyze` to revise perturbation plan or contract, or `protocol` if validation logic is wrong |
| Predictability check fails materially -- reality check contradicts the primary result | C | `analyze` if execution was sound but result does not match reality, or `protocol` if the reality check itself was mis-specified |
| Validity threat is fatal -- unmeasured confounder plausibly explains the entire result, or construct validity has drifted beyond repair | D | `formulate` plus `protocol` if the question was unanswerable with this data, or `analyze` if a different specification might survive |
| Deviation impact invalidates results -- deviations documented in the analyze deviation register materially compromised the analysis | A | `analyze` to re-execute with corrected contract |
| No claims survive evaluation at all | F | `protocol` to reassess what claims are achievable, or `formulate` if the question itself is unanswerable |
| Claim boundary must widen to produce any meaningful communication | F | `formulate` plus `protocol` -- widening is never allowed within `evaluate` |

All challengers producing materially different results from the primary is NOT a backtracking trigger. It is a finding that informs the stability verdict in Cycle B. `evaluate` does not backtrack based on result quality alone.

When backtracking occurs, preserve the earlier record and mark it as superseded. Do not pretend the earlier work never happened.

## Ending the Cycle Loop

The cycle loop ends when:

- mandatory cycles A, B, C, D, F, and G are complete
- all approved E+ follow-ups are closed
- interactive mode: the user explicitly approved the claim survival registry in Cycle F
- interactive mode: the user indicates the stage is ready for post-cycle review
- auto mode: the mandatory cycles and approved follow-ups are complete, so the stage advances to stage-close review under `references/auto-mode.md`

Do not finalize because the stage "seems good enough." Require an explicit decision.

## Post-cycle Evaluation

After the cycle loop, move through two phases. Interactive mode waits for user review between phases. Auto mode follows `references/auto-mode.md` and pauses only on escalation triggers or the final stage-boundary approval.

| Before | Required state |
|--------|----------------|
| Phase 1: Evaluation Integrity Check | Cycle loop complete. `## Claim Survival Registry` and `## Communicate Handoff` have draft content. |
| Phase 2: Finalization | Integrity check passed. Results confirmed in `06_evaluation.md`. |

### Phase 1: Evaluation Integrity Check

**Goal:** Verify that the evaluation itself is internally consistent and did not introduce bias, miss flags, or silently widen the claim boundary.

This is a mechanical consistency audit, not a meta-PCS review. `evaluate` is itself the PCS gate; it does not need to be adjudicated by another PCS layer.

Dispatch an integrity check subagent:

```text
Agent(
  model="{subagent_model}",
  description="Evaluation integrity check",
  prompt="""
  You are an integrity auditor for a Skeptic evaluate stage.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/06_evaluation.md
  2. {projects_root}/{project-name}/{notebooks_dir_name}/06_evaluation.ipynb
  3. {projects_root}/{project-name}/{docs_dir_name}/05_analysis.md
  4. {projects_root}/{project-name}/{docs_dir_name}/metrics.md

  Perform these mechanical checks:

  1. COMPLETENESS: Does every claim from the analysis contract
     (listed in 05_analysis.md ## Analysis Contract and ## Evaluation Handoff)
     have exactly one verdict in the Claim Survival Registry?
     List any missing claims.

  2. CONSISTENCY: Does any "survived" verdict contradict a FAIL
     gate from Cycles B, C, or D? Cross-reference each survived
     claim against all gate assessments in the cycle logs.
     List any contradictions.

  3. FLAG COVERAGE: Was every flag from the analyze evaluation
     handoff (05_analysis.md ## Evaluation Handoff ### Flags for Evaluate)
     explicitly addressed in at least one cycle log?
     List any unaddressed flags.

  4. BOUNDARY INTEGRITY: Is the final claim boundary in the
     Communicate Handoff equal to or narrower than both (a) the claim
     boundary as-narrowed that entered evaluate from analyze and
     (b) the Claim Boundary Registry scope/generalization_limit in metrics.md?
     Flag if wider.

  5. REGISTRY DISCIPLINE: If evaluation narrowed the claim boundary,
     was the Claim Boundary Registry `narrowing_log` updated with the
     new boundary and rationale? List any missing updates.

  6. SCOPE DISCIPLINE: Does any cycle log or notebook cell contain
     evidence of re-analysis, new claim generation, post-hoc testing,
     audience framing, or method comparison? Flag any violations.

  7. CHECKLIST COVERAGE: For each cycle, were all checklist items
     answered with evidence? List any unanswered items and the gates
     that depend on them.

  Output format:

  COMPLETENESS: PASS / FAIL
  - [missing claims, if any]

  CONSISTENCY: PASS / FAIL
  - [contradictions, if any]

  FLAG COVERAGE: PASS / FAIL
  - [unaddressed flags, if any]

  BOUNDARY INTEGRITY: PASS / FAIL
  - [widening evidence, if any]

  REGISTRY DISCIPLINE: PASS / FAIL
  - [missing narrowing-log updates, if any]

  SCOPE DISCIPLINE: PASS / FAIL
  - [violations, if any]

  CHECKLIST COVERAGE: PASS / FAIL
  - [unanswered items and dependent gates, if any]

  OVERALL: PASS / FAIL
  - [summary]
  """
)
```

After the subagent returns:

1. Present the integrity check results to the user.
2. If any check FAILS:
   - identify the specific cycle that introduced the problem
   - reopen that cycle to fix the issue
   - do not proceed to Phase 2
3. If all checks PASS: proceed to Phase 2.

The integrity check catches bookkeeping errors and confirmation-bias leakage. It does not re-adjudicate the substance of the verdicts.

### Phase 2: Finalization

After the integrity check passes:

1. **Evaluation Scorecard (mandatory first item).** Append to `skeptic_documentation/metrics.md` under `## Evaluation`.

```markdown
### Evaluation Scorecard
| metric | value | source |
|--------|-------|--------|
| Checklist items answered | {answered}/{total} | cycle logs |
| Mandatory cycles completed | {n}/6 | cycle logs |
| Follow-up cycles (E+) | {n} ({list topics}) | cycle logs |
| Total iterations (all cycles) | {n} ({cycle}: {n}, ...) | cycle logs |
| Blocking failures total | {n across all cycles} | gate registry |
| Blocking failures resolved by iteration | {n} | gate registry |
| Blocking failures resolved by override | {n} ({list override reasons}) | gate registry |
| Claims evaluated | {n} | Cycle F output |
| Claims survived | {n} | Cycle F output |
| Claims survived with caveats | {n} | Cycle F output |
| Claims did not survive | {n} | Cycle F output |
| Stability verdict | {stable / conditionally stable / unstable} | Cycle B output |
| Predictability verdict | {acceptable / concern} | Cycle C output |
| Threats to validity identified | {n} | Cycle D output |
| Backtracking triggered | {none / analyze / examine / protocol / formulate} | cycle logs |
| Integrity check passed | {yes / no} | Phase 1 |
```

2. **If evaluation narrowed the claim boundary, sync the Claim Boundary Registry in `metrics.md`.** Update `scope`, `generalization_limit`, and any newly forbidden verbs so the registry matches the final boundary recorded in `06_evaluation.md`. Preserve the prior state in `narrowing_log`.

3. **Update `06_evaluation.md`** with `## Summary` containing:
   - final claim survival registry
   - per-dimension summaries (stability, predictability, validity)
   - mandatory limitations
   - unresolved risks
   - backtracking events, if any
   - integrity check result

4. **Complete `## Communicate Handoff`** with the full structured handoff as defined in Cycle G.

5. **Update `## PCS Assessment`** with: "This stage is the PCS adjudication. The integrity check verified internal consistency. See the Claim Survival Registry for per-claim PCS verdicts."

6. **Update `README.md`:**

```markdown
## Evaluate [COMPLETE]
Type: {question type}
Active route: {route}
Claims assessed: {n}
Claims survived: {n} ({n} with caveats)
Claims did not survive: {n}
Stability: {one-line summary}
Predictability: {one-line summary}
Main limitations: {one-line summary of mandatory limitations}
Next: Communicate - package only claims that survived evaluation
```

6. Read `README.md` and quote the `## Evaluate [COMPLETE]` block verbatim in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete — return to the README-update step. Only then present the final artifacts to the user and state that the next stage is `communicate`.

## Dependency Notes

- `formulate`, `protocol`, `clean`, `examine`, and `analyze` are mandatory dependencies for `evaluate`.
- `protocol` defines what validation logic `evaluate` must apply and what the claim ceiling is.
- `analyze` produces the locked outputs that `evaluate` adjudicates. `evaluate` does not modify or re-execute them.
- `evaluate` audits `analyze` against the commitments made in `protocol` and the analysis contract locked inside `analyze`.
- Route files may narrow or prohibit evaluation actions. They may not widen this stage-core, the protocol contract, or the claim boundary.
- If the route file cannot be loaded, stop. That is missing architecture.
- `communicate` depends on approved outputs from `evaluate`. `communicate` may package only claims that survived evaluation.
- The next stage is `communicate`.
- `evaluate` may narrow the claim boundary. It may not widen it.
- `evaluate` may trigger backtracking to any upstream stage. If that happens, preserve the audit trail and route back explicitly.
- If question type, target quantity, or claim boundary needs changing, reopen `formulate` and `protocol`.
- `evaluate` does not choose methods, generate claims, re-execute analysis, or package findings for an audience.
