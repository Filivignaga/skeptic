---
name: communicate
description: Use after formulate, protocol, clean, examine, analyze, and evaluate to package only claims that survived evaluation for the intended audience, without upgrading claims, widening the claim boundary, or introducing new analysis.
---

# /skeptic:communicate - Communication of Evaluated Results

**IMPORTANT:** Before executing, read `references/core-principles.md` from the parent `skeptic` skill for shared conventions.

`core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

`communicate` is the terminal stage of the Skeptic. There is no downstream stage to catch errors introduced here. Every fidelity violation -- claim inflation, caveat suppression, boundary widening, misleading visualization, narrative overreach -- goes directly to the audience and into production.

`communicate` does not re-analyze data. It does not re-evaluate claims. It does not generate new claims. It receives the structured handoff from `evaluate` and packages only the claims that survived, with their mandatory caveats and limitations, for the intended audience and use context.

`communicate` does not load route-specific overlay files. The route-specific constraints were enforced in `formulate` through `evaluate`. The evaluate handoff contains all route-relevant information the communication needs.

## Required Input

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` |

`communicate` requires completed `formulate`, `protocol`, `clean`, `examine`, `analyze`, and `evaluate` stages. Do not start from partial upstream context.

## What Prior Outputs This Stage Reads

The stage reads:

- `skeptic_documentation/01_formulation.md` - approved question, question type, target quantity or estimand, claim boundary, unit of analysis, assumptions
- `skeptic_documentation/02_protocol.md` - active route, data usage mode, validation logic
- `skeptic_documentation/03_cleaning.md` - final variable list, population-shift summary
- `skeptic_documentation/04_examination.md` - support registry summary
- `skeptic_documentation/05_analysis.md` - analysis contract, deviation register, claim boundary as-narrowed
- `skeptic_documentation/06_evaluation.md` - claim survival registry, final claim boundary, per-dimension summaries (stability, predictability, validity), mandatory limitations, unresolved risks, communicate handoff, handoff discipline
- `skeptic_documentation/metrics.md` - formulation, protocol, cleaning, examination, analysis, and evaluation scorecards, claim boundary registry
- `notebooks/06_evaluation.ipynb` - evidence for claim survival verdicts
- `README.md` - confirms prior stage completion

The evaluate handoff is the primary input. All other upstream documents provide traceability and context. Keep the evaluate handoff -- claim survival registry, final claim boundary, mandatory limitations, unresolved risks, and handoff discipline -- in active context throughout the stage. These are the constraints the communication must satisfy.

No additional user input is required at stage start. The audience is identified during Cycle B. If upstream outputs are incomplete, contradictory, or missing required sections, stop and repair the upstream stage. Do not invent communication permissions around gaps.

## Precondition Gate

Run this gate before anything else.

Verify all of the following:

- `skeptic_documentation/01_formulation.md` exists
- `skeptic_documentation/02_protocol.md` exists
- `skeptic_documentation/03_cleaning.md` exists
- `skeptic_documentation/04_examination.md` exists
- `skeptic_documentation/05_analysis.md` exists
- `skeptic_documentation/06_evaluation.md` exists
- `skeptic_documentation/metrics.md` exists
- `notebooks/06_evaluation.ipynb` exists
- `README.md` exists

Verify `06_evaluation.md` contains:

- `## Summary`
- `## Claim Survival Registry`
- `## Communicate Handoff`
- `## PCS Assessment`
- at least one claim with a verdict (survived, survived with caveats, or did not survive)
- final claim boundary
- mandatory limitations section (even if the list is empty)
- unresolved risks section (even if the list is empty)
- handoff discipline statement

Verify `01_formulation.md` contains:

- `## Summary`
- an approved question
- a question type
- a target quantity or estimand
- a claim boundary

Verify `metrics.md` contains:

- `### Claim Boundary Registry`

If any required field, artifact, or restriction is missing or contradictory:

- stop
- tell the user exactly what is missing or inconsistent
- route back to `evaluate`, `analyze`, or the appropriate upstream stage

Do not proceed with partial context.

## Guiding Principle

The goal of `communicate` is to make truthful, PCS-validated results usable by their intended audience. The standard for "done" is: can the intended user apply the findings without the analyst's help?

Use `communicate` to:

- package only claims that survived evaluation for the identified audience
- translate claims into audience-appropriate language without changing their substance
- present uncertainty, stability evidence, and predictability results honestly
- disclose all mandatory limitations and caveats from the evaluate handoff
- frame claims that did not survive as explicit limitations showing what the analysis could NOT establish
- generate bounded recommendations that cite their parent claim and inherit its caveats
- design visualizations that fairly represent findings across reasonable display formats
- produce a deliverable the audience can act on independently
- narrow the claim boundary when the audience or deployment context demands it

Do not use `communicate` to:

- re-analyze data or run new queries on raw or cleaned data
- re-evaluate claims or reopen survival verdicts
- generate new claims beyond what the analysis contract was designed to support
- upgrade claims from "survived with caveats" to "survived" or rescue claims that did not survive
- widen the claim boundary
- drop mandatory limitations or caveats from the evaluate handoff
- compute new statistics, fit new models, or produce outputs that did not exist in the analyze/evaluate pipeline
- add post-hoc analyses after seeing results
- choose between methods or specifications
- use causal language when the route is not causal
- present exploratory findings as confirmed conclusions

## Computation Boundary Rule

`communicate` may compute only presentation-level transformations:

- formatting numbers (rounding, significant figures)
- converting units for human readability
- rendering existing data into charts and tables
- aggregating existing outputs into summary tables
- computing percentages from existing counts

`communicate` may NOT:

- compute new statistics not present in the analyze or evaluate pipeline
- run new queries on the raw or cleaned data
- fit new models or run new algorithms
- produce any output that changes the substance (not just the format) of a finding

Any new computation that changes substance is a scope violation. The evaluation subagent explicitly checks for this.

## Null-Result Handling

If `evaluate` produced zero surviving claims, `communicate` still runs but produces a null-result deliverable that documents:

- what question was asked
- what analysis was attempted
- why no claims survived (from the evaluate claim survival registry)
- what the mandatory limitations are
- what would need to change for claims to survive in a future attempt

The same cycle structure applies. Cycles C through E are proportionally lighter since there are no claims to translate, present, or visualize. The five mandatory deliverable sections still apply, but the Findings section states that no claims survived and the Confidence section states why.

## Setup

Before Cycle A, create:

1. `notebooks/07_communication.ipynb` with a header cell containing:
   - stage title
   - date
   - project name
   - approved question
   - question type
   - target quantity
   - final claim boundary (from evaluate)
   - claim survival summary (survived: n, survived with caveats: n, did not survive: n)
   - mandatory limitations count
   - upstream dependency note: `01_formulation.md`, `02_protocol.md`, `03_cleaning.md`, `04_examination.md`, `05_analysis.md`, `06_evaluation.md`
   - note: "This notebook is the working surface for communication. The deliverable is rendered from this notebook into the audience-appropriate format in deliverables/. This stage does not re-analyze data, re-evaluate claims, widen the claim boundary, or compute new statistics."

2. `skeptic_documentation/07_communication.md` with this initial structure:

```markdown
# Communicate: Communication of Evaluated Results

## Dataset
- Sources: {raw source names or manifest from formulate}
- Approved question: {from 01_formulation.md}
- Question type: {from 01_formulation.md}
- Target quantity: {from 01_formulation.md}
- Final claim boundary: {from 06_evaluation.md}
- Active route: {from 02_protocol.md}
- Claims survived: {n}
- Claims survived with caveats: {n}
- Claims did not survive: {n}
- Mandatory limitations: {n}
- Date started: {date}

## Upstream Contract
- Approved question: {from formulate}
- Question type: {from formulate}
- Target quantity: {from formulate}
- Final claim boundary: {from evaluate}
- Active route: {from protocol}
- Claim survival registry: {from evaluate}
- Mandatory limitations: {from evaluate}
- Handoff discipline: {from evaluate}

## Audience Profile

## Communication Plan

## Decision Log

## Deliverable Register

## PCS Assessment
```

3. Create `deliverables/` directory under the project root if it does not exist.

## Deliverable Composition Rules

Every `communicate` run produces exactly one primary deliverable.

- **Primary deliverable**: the audience-facing document containing all five mandatory sections (Question, Findings, Confidence, Limitations, Methods Summary). Must exist -- a run that produces only data files is incomplete.
- **Companion data files**: optional structured data files (CSV, JSON, Excel, etc.) that supplement the primary deliverable. The Deliverable Register in `07_communication.md` must list the primary deliverable and every companion file separately with their roles.

## Deliverable Naming Convention

The primary deliverable filename must follow this pattern:

`{project_name}_{audience_type}_{date}.{format_extension}`

Companion data files must use a descriptive name that indicates their content and relationship to the primary deliverable:

`{project_name}_{content_description}_{date}.{ext}`

The notebook header must state the approved question, question type, target quantity, final claim boundary, and claim survival summary explicitly. `communicate` starts only after those fields are written.

## Stage Map

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Intake audit and communication plan | Yes |
| B | Audience and delivery framing | Yes |
| C | Claim translation and caveat calibration | Yes |
| D | Uncertainty and evidence presentation | Yes |
| E | Visualization and representation integrity | Yes |
| F | Communication assembly and terminal fidelity audit | Yes |

All six cycles are mandatory. There is no follow-up window. If a cycle uncovers issues that require rework on an earlier cycle, the standard cycle protocol handles iteration through Step 4 decisions.

## Execution Gates

Before each cycle, verify the required outputs from prior work exist. If anything is missing, stop and tell the user exactly what is missing.

| Before | Required state |
|--------|----------------|
| Cycle A | Precondition gate passed. Setup files exist. `deliverables/` directory exists. |
| Cycle B | `07_communication.md` contains `### Cycle A` log entry with a communication plan. `07_communication.ipynb` has Cycle A outputs. |
| Cycle C | `07_communication.md` contains `### Cycle B` log entry with audience profile and delivery format. User approved the audience identification. |
| Cycle D | `07_communication.md` contains `### Cycle C` log entry with translated claims and calibrated language. |
| Cycle E | `07_communication.md` contains `### Cycle D` log entry with uncertainty and evidence presentation decisions. |
| Cycle F | `07_communication.md` contains `### Cycle A` through `### Cycle E` log entries. |
| Post-cycle Phase 1 | Mandatory cycle loop complete. User has indicated the stage is ready for post-cycle review. |

## Gate Condition Registry

Every evaluation gate has a stable ID used in cycle metrics. The evaluation subagent references these IDs in its structured output.

### Cycle A: Intake Audit and Communication Plan

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `A-handoff-complete` | A01, A02 | All required sections and fields from the evaluate communicate handoff are present |
| `A-claims-inventoried` | A03, A04 | Every claim from the evaluate claim survival registry is explicitly listed with its verdict |
| `A-limitations-inventoried` | A05 | Every mandatory limitation from the evaluate handoff is explicitly listed |
| `A-plan-derived` | A07, A08 | Communication plan is derived from upstream handoff, not invented ad hoc |
| `A-null-result-handled` | A06 | If zero claims survived, the null-result path is explicitly activated |

### Cycle B: Audience and Delivery Framing

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `B-audience-identified` | B01, B02 | Audience is explicitly identified with technical level, decision context, and action capacity |
| `B-format-chosen` | B03 | Delivery format and medium are chosen and justified |
| `B-layer-structure-decided` | B04 | Number and depth of output layers are determined by audience needs |
| `B-scaffolding-set` | B05 | Communication scaffolding (section structure, flow, depth calibration) is established |
| `B-user-approved` | B06 | User explicitly approved the audience identification and delivery format |

### Cycle C: Claim Translation and Caveat Calibration

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `C-claims-translated` | C01, C02 | Every surviving claim is translated into audience-appropriate language |
| `C-language-calibrated` | C01, C02 | Language strength reflects PCS verdicts: assertive for survived, conditional for survived-with-caveats |
| `C-caveats-integrated` | C02, C03 | Every mandatory caveat from survived-with-caveats claims is integrated visibly, not buried |
| `C-dead-claims-framed` | C04 | Claims that did not survive appear only as limitations stating what the analysis could NOT establish |
| `C-recommendations-bounded` | C05, C06 | Every recommendation cites its parent claim and stays within the claim boundary |
| `C-no-upgrades` | C01, C02, C05 | No claim was upgraded from its evaluate verdict |
| `C-boundary-verified` | C07 | Claim Boundary Registry confirms no communicated claim uses forbidden verbs, stays within scope, and respects generalization_limit |

### Cycle D: Uncertainty and Evidence Presentation

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `D-perturbation-presented` | D01, D02 | Perturbation landscape is presented at audience-appropriate depth |
| `D-stability-presented` | D02 | Stability evidence is presented for each surviving claim |
| `D-predictability-presented` | D03 | Reality check results are presented |
| `D-limitations-presented` | D04 | All mandatory limitations from evaluate are presented |
| `D-risks-presented` | D05 | Unresolved risks are presented |
| `D-uncertainty-calibrated` | D06, D07 | Uncertainty depth matches the audience tier without understating or overstating |

### Cycle E: Visualization and Representation Integrity

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `E-figures-designed` | E01 | All key findings have visual representations |
| `E-stability-tested` | E02 | Each key surviving claim with a visual representation has been tested in at least two reasonable display formats |
| `E-no-misleading` | E04 | No visualization uses truncated axes, misleading scales, suppressed baselines, or cherry-picked ranges |
| `E-uncertainty-visible` | E03 | Uncertainty is visually present for every quantitative claim |
| `E-format-honest` | E02, E05 | The chosen display format for each claim is the one that honestly represents the finding, not the one that makes it look strongest |
| `E-proportional` | E06 | Visualization effort is proportional to the project complexity |
| `E-data-uncertainty` | E07 | Companion data files with point estimates include at least one uncertainty measure per row |

### Cycle F: Communication Assembly and Terminal Fidelity Audit

| gate_id | depends_on | condition |
|---------|------------|-----------|
| `F-sections-complete` | F01 | All five mandatory deliverable sections are present: Question, Findings, Confidence, Limitations, Methods Summary |
| `F-deliverable-rendered` | F02 | Deliverable is rendered to `deliverables/` in the chosen format |
| `F-computation-boundary` | F03 | No new statistics, queries, or models were computed -- only presentation-level transformations |
| `F-fidelity-verified` | F03 | Every surviving claim from the evaluate handoff is present in the deliverable |
| `F-caveats-preserved` | F03 | Every mandatory caveat is present and visible in the deliverable |
| `F-boundary-respected` | F03 | No language in the deliverable exceeds the final claim boundary |
| `F-recommendations-scoped` | F03 | Every recommendation cites its parent claim and inherits its caveats |
| `F-self-sufficient` | F05 | The deliverable is interpretable by someone with no prior project context |
| `F-narrowing-logged` | F04 | If communicate narrowed any claims, Claim Boundary Registry in metrics.md is updated with narrowing reason and cycle |
| `F-question-led` | F06 | The deliverable opens with the audience-relevant question and context, not a method-first description |
| `F-methods-grounded` | F07 | The Methods Summary states provenance, processing, route, and what was actually done in plain language without assuming shared context; and states intended use and prohibited use |
| `F-problems-disclosed` | F08 | Material problems, caveats, and limitations are surfaced clearly rather than hidden or downplayed |
| `F-encoding-clean` | F10 | All files in `deliverables/` pass the ASCII encoding scan with zero non-ASCII typographic punctuation |
| `F-data-dictionary` | F11 | Every companion data file has a data dictionary defining all columns or fields. Any column name that uses a relative temporal reference (e.g., `last_year_presence`, `rolling3_years_positive`, `lag1_*`) must include the explicit year range or reference year in either (a) the column name itself (e.g., `presence_2024`) or (b) the data dictionary entry with exact year ranges. Ambiguous temporal column names without year disambiguation are a blocking defect. |
| `F-degeneracy-disclosed` | F12 | If companion data files show value degeneracy (>30% identical values in a key output column), it is disclosed as a limitation |

## Cycle Protocol

Apply this protocol to every cycle.

### Step 0: Progress Indicator

At the start of each cycle, print:

`"Communicate stage: Cycle {X} ({focus}) - mandatory - {ordinal} of 6 mandatory cycles"`

For post-cycle phases, print:

`"Communicate stage: Post-cycle Phase {N} ({name})"`

### Step 1: Setup and Execution

- Claude reads existing notebook outputs. Skip this only for Cycle A beyond the header.
- Claude reads `06_evaluation.md` before every cycle. Treat the claim survival registry, final claim boundary, mandatory limitations, unresolved risks, and handoff discipline as hard constraints.
- Claude reads `01_formulation.md` before every cycle. Treat the approved question, question type, and target quantity as the anchoring context.
- If the claim survival registry or mandatory limitations become unclear mid-stage, reread `06_evaluation.md` before proceeding.
- Claude identifies what communication work the current cycle must produce.
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
  description="Research for Communicate Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a communication conventions research assistant for a Skeptic communicate stage.

  Context:
  - Approved question: "{approved question}"
  - Question type: {question type}
  - Target quantity: {target quantity}
  - Final claim boundary: {claim boundary}
  - Active route: {route}
  - Audience: {audience description from Cycle B, or "not yet identified" if Cycle A}
  - Delivery format: {format from Cycle B, or "not yet chosen" if Cycle A}
  - Current notebook findings: {findings from this cycle}
  - User observations: {if any}

  Answer these research questions for Cycle {X} ({focus}):
  {insert cycle-specific research questions}

  Rules:
  - Focus on communication conventions, not domain discovery or method selection.
  - Research audience-appropriate presentation standards, visualization conventions,
    uncertainty communication formats, and reporting guidelines.
  - If a question does not apply, say "not applicable" with a one-line reason.
  - Cite sources for claims that would change a communication decision.

  Return concise findings organized by research question. Include the URL for every resource cited.
  """
)
```

**Evaluation subagent:**

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Communicate Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a Skeptic communicate-stage cycle.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/07_communication.md
  2. {projects_root}/{project-name}/{notebooks_dir_name}/07_communication.ipynb
  3. {projects_root}/{project-name}/{docs_dir_name}/06_evaluation.md
  4. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md

  Cycle focus: {focus description}
  User observations: {if any}

  Applicable gates for this cycle:
  {list gate IDs}

  Answer these evaluation questions for Cycle {X} ({focus}):
  {insert cycle-specific evaluation questions}

  Task:
  1. Evaluate each applicable gate using notebook evidence.
  2. Answer cycle-specific evaluation questions from notebook evidence.
  3. Check claim fidelity: does the communication faithfully represent
     evaluate's verdicts? Was any claim upgraded, any caveat dropped,
     any boundary widened?
  4. Check computation boundary: does the notebook contain any new
     statistics, queries, or models not present in the analyze/evaluate
     pipeline?
  5. Flag any move that widens the claim boundary, re-executes analysis,
     generates new claims, drops mandatory caveats, or computes new
     statistics.
  6. Read the Claim Boundary Registry from `metrics.md`. Verify that
     all communicated claims use only verbs from `verbs_allowed`,
     stay within `scope`, and respect `generalization_limit`. Any
     violation is a BLOCKING defect. If communicate narrows the claim,
     append to `narrowing_log`.
  7. Recommend: pass / iterate on {topic} / acknowledge gap / backtrack
     to {stage}.

  Before evaluating gates, verify that all checklist items for this cycle were answered with evidence in the notebook. If any checklist item was not answered, the gates that depend on it auto-fail.

  Output format (follow this exact structure in order):

  EVALUATION: Cycle {X} - {focus}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Your job is to actively falsify each gate
  and checklist answer rather than confirm them. For each gate you mark PASS,
  you must state the specific failure mode you tested and ruled out.
  Categories to scan: claim inflation, caveat suppression, boundary
  widening, computation boundary violations, recommendation overreach,
  selective reporting, visualization misleading, audience mismatch,
  narrative overreach.
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
  (list every applicable gate)

  Key findings:
  - [finding]
  - [finding]
  - [finding]

  Claim boundary: {unchanged / narrowed / WIDENED (flag)}
  Gaps remaining: [list, or "none"]
  Recommended next step: pass / iterate / acknowledge gap / backtrack to {stage}

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

When both subagents return, Claude synthesizes them into one cycle assessment. Do not present disconnected subagent reports as if they were the stage decision. Log the raw subagent outputs inside the stage's decision log (the main `0X_{stage}.md` document) under a `### Cycle {X} raw subagent outputs` subsection. The research subagent's output must include the URLs for every resource it cites.

Do not fabricate certainty. If the evidence shows the claims cannot be faithfully communicated:

- request clarification from the user on audience needs
- reopen `evaluate` if claims cannot be stated without exceeding the boundary
- reopen `formulate` if the surviving claims do not address the original question at a useful level
- produce the null-result deliverable if appropriate

Count the blocking failures from the evaluation subagent output: blocking defects plus gates with verdict FAIL. Then apply the decision matrix.

**Decision matrix:**

| blocking_failures | forward actions allowed | note |
|-------------------|------------------------|------|
| 0 | pass, iterate | cycle meets minimum bar |
| > 0 | iterate, acknowledge gap (with written justification) | pass is blocked until blocking failures are resolved or justified |

**Always-available actions (regardless of blocking_failures):**

- **Reopen evaluate** -> stop and reopen `evaluate` if claims cannot be faithfully communicated within their boundary
- **Reopen formulate + protocol** -> stop and reopen `formulate` plus `protocol` if surviving claims do not address the original question at a useful level
- **User override** -> user states the specific reason the FAIL is incorrect, logged as `override: {reason}`, forward actions unlock

Interactive mode: present the synthesized assessment to the user via the **AskUserQuestion** tool, offering these options:

- **Pass** -> log the cycle and move forward
- **Fail + iterate** -> log the cycle, write more cells targeting the gaps, and rerun from Step 2
- **Fail + acknowledge gap** -> log the gap and move forward with risk carried explicitly
- **Evaluate mismatch** -> stop and reopen `evaluate`
- **Formulation mismatch** -> stop and reopen `formulate` plus `protocol`

Do not invoke any other tool until the user answers. The answer is the only valid trigger for continuing.

Auto mode: apply the autonomous decision protocol from `references/auto-mode.md`, log the rationale, and continue without waiting unless an escalation trigger fires.

### Step 5: Log

Immediately after each cycle decision, append to `skeptic_documentation/07_communication.md`:

```markdown
### Cycle {X}: {Focus}
- **What we did:** {notebook cells run, outputs reviewed}
- **Research findings:** {key findings from research subagent}
- **Evaluation verdict:** PASS / FAIL
- **Gate assessments:** {gate_id}: PASS/FAIL for each applicable gate
- **Claim fidelity:** {all claims faithful / {n} issues found}
- **Computation boundary:** {respected / violation found}
- **Claim boundary:** {unchanged / narrowed to {new boundary} because {reason}}
- **Gaps:** {remaining gaps, if any}
- **Decision:** {pass / iterate / acknowledge gap / backtrack to {stage}}

#### Cycle {X} raw subagent outputs

##### Research subagent
{verbatim output, including every source URL}

##### Evaluation subagent
{verbatim output, including DEFECT SCAN, SEVERITY CLASSIFICATION, GATE ASSESSMENTS, Alternatives considered, Gaps, Protocol implications, Recommended follow-up, VERDICT}
```

Also append structured cycle metrics to `skeptic_documentation/metrics.md`. Create the section `## Communication` if it does not yet exist.

```markdown
**Cycle metrics:**
- iterations: {n}
- verdict: PASS/FAIL (on iteration {n})
- gates: [{gate_id}: PASS/FAIL, ...]
- research_sources_returned: {n}
- evaluation_verdict_aligned: yes/no/partial/indeterminate
- claims_communicated: {n}
- claims_with_caveats: {n}
- recommendations_generated: {n}
- computation_boundary_violations: {n}
```

**Raw-subagent-outputs rule.** The `#### Cycle {X} raw subagent outputs` subsection is mandatory. The evaluation subagent auto-fails the cycle if that subsection is missing, empty, or contains paraphrased rather than verbatim output. The research subagent's raw output must include every source URL it cites.

**Cycle-state invariant.** After Step 5, the notebook, the stage document (`0X_{stage}.md`), `metrics.md`, and the README must all agree on the same "active cycle" pointer. Each cycle begins by verifying this invariant and ends by restoring it: the log entry for Cycle {X} and its metrics row are appended, the README stage-status line is updated to reflect Cycle {X}'s outcome, and only then may Cycle {X+1} work begin in the notebook.

## Cycle A: Intake Audit and Communication Plan

**Focus:** Verify that `evaluate` produced a complete communication-ready package, inventory all claims and limitations, and derive the communication plan from upstream contracts.

This cycle does not make audience decisions or translate claims. It maps the territory before communication begins.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| A01 | What is the approved question, question type, target quantity, final claim boundary, and active route? | never |
| A02 | Is the communicate handoff from evaluate complete (claim survival registry, per-dimension summaries, mandatory limitations, unresolved risks, handoff discipline)? | never |
| A03 | What claims survived, survived with caveats, and did not survive? | never |
| A04 | For each claim, what is the verdict, caveats (if any), and one-line evidence summary? | never |
| A05 | What mandatory limitations exist, what is the source of each, and are all non-droppable? | never |
| A06 | Did zero claims survive, requiring activation of the null-result path? | never |
| A07 | What claims will be communicated, what limitations must be disclosed, and what mandatory sections must the deliverable contain? | never |
| A08 | What recommendations are possible within the claim boundary? | never |
| A09 | Does the communication plan confirm that surviving claims speak to the stakeholder decision and candidate actions named in 01_formulation.md `## Summary`? | never |

Claude writes notebook cells using this default sequence:

1. Restate the approved question, question type, target quantity, final claim boundary, and active route.
2. Load and display the full communicate handoff from `06_evaluation.md`: claim survival registry, final claim boundary, per-dimension summaries, mandatory limitations, unresolved risks, and handoff discipline.
3. Verify completeness: is the claim survival registry present? Are all mandatory limitations listed? Is the handoff discipline statement present? Is the final claim boundary explicitly stated?
4. Build a claim inventory table with one row per claim:
   - claim description
   - verdict (survived / survived with caveats / did not survive)
   - caveats (if survived with caveats)
   - evidence summary (one line)
5. Build a limitation inventory table with one row per mandatory limitation:
   - limitation description
   - source (which cycle or stage produced it)
   - droppable: no (all mandatory limitations are non-droppable)
6. Build an unresolved risk inventory.
7. If zero claims survived, explicitly activate the null-result path. State that the deliverable will document what was attempted and why nothing survived.
8. Derive the communication plan:
   - what claims will be communicated (only survived and survived-with-caveats)
   - what limitations must be disclosed (all mandatory limitations)
   - what the deliverable must contain (five mandatory sections)
   - what recommendations are possible within the claim boundary
9. Write the `## Communication Plan` section in `07_communication.md`.

**Research questions:**

- What communication standards are typical for this question type and domain?
- What reporting guidelines may apply (STROBE, TRIPOD, CONSORT, or domain-specific standards)?
- What are common terminal-stage fidelity failures for similar projects?

**Evaluation questions:**

- Is the evaluate handoff complete -- can communication proceed without re-running evaluation?
- Are all claims from the evaluate claim survival registry explicitly inventoried?
- Are all mandatory limitations explicitly inventoried?
- Is the communication plan derived from upstream contracts, not invented ad hoc?
- If zero claims survived, is the null-result path explicitly activated?

**Evaluation focus for Cycle A:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle B: Audience and Delivery Framing

**Focus:** Identify the audience, choose the delivery format and medium, determine the output layer structure, and set the communication scaffolding.

This cycle uses `AskUserQuestion` to collect audience information from the user in both modes. Do not guess the audience from the project context.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| B01 | Who is the intended audience (customers, internal team, technical reviewers, executives, regulators, other)? | never |
| B02 | What is the audience's technical level, decision context, and action capacity? | never |
| B03 | What delivery format and medium are appropriate for this audience, and what is the justification? | never |
| B04 | How many output layers are needed, and what depth does each require? | never |
| B05 | What is the communication scaffolding: section structure, depth calibration, tone, vocabulary register, and jargon translation needs? | never |
| B06 | Did the user explicitly approve the audience identification and delivery format? | never |

Claude writes notebook cells using this default sequence:

1. State that this cycle identifies the audience and delivery format.
2. Use `AskUserQuestion` to ask the user:
   - Who is the intended audience? (customers, internal team, technical reviewers, executives, regulators, or other)
   - What is their technical level? (non-technical, semi-technical, technical)
   - What decisions will they make with these results?
   - What format do they expect? (report, presentation, dashboard, memo, academic paper, or other)
3. Record the audience profile in the notebook:
   - audience type
   - technical level
   - decision context
   - action capacity
   - expected format
4. Choose the delivery format and medium based on the audience profile.
5. Determine the output layer structure: how many layers, what depth for each, what sections each layer contains. All layers share the same claims, boundary, and mandatory limitations. Depth varies, substance does not.
6. Set the communication scaffolding:
   - section structure following the five mandatory sections (Question, Findings, Confidence, Limitations, Methods Summary)
   - depth calibration per section for this audience
   - tone and vocabulary register
   - whether jargon requires translation and which terms
7. Write the `## Audience Profile` section in `07_communication.md`.

**Research questions:**

- What communication conventions are standard for this audience type and domain?
- What format and depth do similar deliverables use for this audience?
- What jargon translation is needed for the specific technical terms in this project?
- What visualization formats are standard for this audience's domain?

**Evaluation questions:**

- Was the audience identified explicitly with technical level, decision context, and action capacity?
- Was the delivery format chosen and justified?
- Is the layer structure determined by audience needs?
- Is the communication scaffolding established with the five mandatory sections?
- Did the user explicitly approve the audience identification and delivery format?

**Step 4 addition:** Audience identification is a required human-input checkpoint in both modes. Interactive mode requires explicit approval before Cycle C begins. Auto mode requires the audience prompt to be answered and logged before Cycle C begins.

**Evaluation focus for Cycle B:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle C: Claim Translation and Caveat Calibration

**Focus:** Translate each surviving claim into audience-appropriate language, calibrate language strength to PCS verdicts, integrate mandatory caveats, frame dead claims as limitations, and draft bounded recommendations.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| C01 | For each claim that survived (without caveats), what is the audience-appropriate translation using assertive language within the claim boundary? | zero survived claims |
| C02 | For each claim that survived with caveats, what is the audience-appropriate translation using conditional language that names each caveat explicitly? | zero survived-with-caveats claims |
| C03 | Are all mandatory caveats from survived-with-caveats claims integrated visibly and substantively, not buried in footnotes or appendices? | zero survived-with-caveats claims |
| C04 | For each claim that did not survive, how is it framed as an explicit limitation stating what the analysis could NOT establish? | zero did-not-survive claims |
| C05 | What bounded recommendations are derived, and does each cite its parent claim and stay within the claim boundary? | never |
| C06 | Does every recommendation inherit the caveats of its parent claim? | never |
| C07 | Does the Claim Boundary Registry confirm no communicated claim uses verbs from verbs_forbidden, stays within scope, and respects generalization_limit? | never |

Claude writes notebook cells using this default sequence:

1. For each claim that survived (without caveats):
   - translate the claim into audience-appropriate language
   - use assertive language consistent with the claim boundary
   - verify the translated claim uses only verbs from `verbs_allowed` in the Claim Boundary Registry
2. For each claim that survived with caveats:
   - translate the claim into audience-appropriate language
   - use conditional language that names each caveat explicitly (e.g., "under conditions X, the data show Y")
   - integrate each mandatory caveat so it is visible and substantive, not buried in a footnote or appendix
   - verify the translated claim does not read as if the caveats are optional
3. For each claim that did not survive:
   - frame it as an explicit limitation: "this analysis could NOT establish that..."
   - state the reason from the evaluate claim survival registry
   - do not imply the evidence was almost sufficient or that a minor change would produce survival
4. Draft bounded recommendations:
   - each recommendation must cite the specific surviving claim it derives from
   - each recommendation must stay within the claim boundary (descriptive claims recommend investigation, not intervention; predictive claims recommend deployment conditions, not causal mechanisms; causal claims recommend intervention within the identification boundary)
   - each recommendation inherits the caveats of its parent claim
   - if the parent claim survived with caveats, the recommendation must state those caveats
5. Verify the Claim Boundary Registry:
   - no communicated claim uses verbs from `verbs_forbidden`
   - all claims stay within `scope`
   - all claims respect `generalization_limit`
   - if communicate narrows the claim, append to `narrowing_log`

**Language calibration guidance:** PCS verdicts inform language strength but do not map to rigid verb templates. "Survived" claims support direct assertion. "Survived with caveats" claims require conditional framing that names the instability source, marginal predictability, or non-fatal validity threat. The evaluation subagent checks whether the language strength matches the verdict, but the mapping is judgment-based, not mechanical.

**Research questions:**

- What audience-appropriate language conventions exist for this domain and question type?
- What plain-language equivalents exist for the technical terms the Skeptic produces (perturbation axes, stability verdicts, predictability checks, claim boundaries)?
- What recommendation framing conventions exist for this claim type and audience?
- What are common claim-inflation patterns in similar reports?

**Evaluation questions:**

- Is every surviving claim translated into audience-appropriate language?
- Does language strength match PCS verdicts -- assertive for survived, conditional for survived-with-caveats?
- Is every mandatory caveat integrated visibly, not buried?
- Do claims that did not survive appear only as limitations?
- Does every recommendation cite its parent claim?
- Does every recommendation stay within the claim boundary?
- Was any claim upgraded from its evaluate verdict?

**Evaluation focus for Cycle C:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

**Cycle C PCS checkpoint.** Before Step 5, record one line each: (P) does translated language reflect the evaluate verdict strength exactly, or was assertive language applied to a survived-with-caveats claim? (C) would a second analyst translating the same claim reach the same language strength and caveat visibility? (S) can each translated claim be traced back to the specific evaluate registry row and verdict that authorizes it? Stability FAIL → downgrade the language or surface the caveat more prominently.

## Cycle D: Uncertainty and Evidence Presentation

**Focus:** Decide how to present the perturbation landscape, stability evidence, predictability results, mandatory limitations, and unresolved risks to the identified audience.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| D01 | What uncertainty presentation depth is appropriate for the audience tier identified in Cycle B? | never |
| D02 | For each surviving claim, what perturbation axes were tested, and did the claim hold (stable, conditionally stable)? | never |
| D03 | What reality check was applied, did it pass, and what does "passed" mean for this audience? | never |
| D04 | Are all mandatory limitations from the evaluate handoff stated clearly and not omitted or downplayed? | never |
| D05 | Are all unresolved risks from the evaluate handoff presented? | never |
| D06 | Is the scope of perturbation testing disclosed (what was tested AND what was not tested)? | never |
| D07 | Is uncertainty neither overstated (creating false alarm) nor understated (creating false confidence)? | never |

Claude writes notebook cells using this default sequence:

1. Determine uncertainty presentation depth based on the audience tier identified in Cycle B. The EFSA three-tier model provides useful guidance:
   - entry-level audiences: qualitative uncertainty statements, frequency framing (e.g., "3 out of 10"), plain-language summaries of what was tested and what held up
   - informed audiences: ranges with point estimates, summary stability tables, verbal descriptions of perturbation results
   - technical audiences: full perturbation distributions, specification curves, sensitivity tables, quantile dotplots or hypothetical outcome plots
2. Present stability evidence for each surviving claim:
   - what perturbation axes were tested
   - whether the claim held (stable, conditionally stable)
   - what was sensitive and what the sensitivity means in plain terms
3. Present predictability evidence:
   - what reality check was applied (held-out validation, resampling, replication, falsification, etc.)
   - whether it passed, and what "passed" means for this audience
4. Present mandatory limitations from the evaluate handoff:
   - each limitation must be stated clearly
   - no mandatory limitation may be omitted or downplayed
5. Present unresolved risks from the evaluate handoff.
6. Disclose the scope of perturbation testing: what was tested AND what was not tested. Do not imply that all possible perturbations were explored.
7. Verify that uncertainty is neither overstated (creating false alarm) nor understated (creating false confidence).

**Research questions:**

- What uncertainty communication formats are effective for this audience type?
- What formats are standard for perturbation and sensitivity results in this domain?
- How do similar reports present stability and predictability evidence to non-technical audiences?
- What known patterns of uncertainty misrepresentation exist for this type of analysis?

**Evaluation questions:**

- Is the perturbation landscape presented at audience-appropriate depth?
- Is stability evidence presented for each surviving claim?
- Are reality check results presented?
- Are all mandatory limitations from evaluate present and not downplayed?
- Are unresolved risks presented?
- Is the uncertainty depth calibrated to the audience without understating or overstating?
- Is the scope of perturbation testing (what was and was not tested) disclosed?

**Evaluation focus for Cycle D:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle E: Visualization and Representation Integrity

**Focus:** Design all figures and tables, test each key claim's visual representation across at least two reasonable display formats, and verify visualization integrity.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| E01 | For each key surviving claim with quantitative content, what primary and alternative display formats were designed? | zero surviving claims with quantitative content |
| E02 | For each claim with multiple display formats, does the qualitative takeaway remain stable across formats, and which format most honestly represents the finding? | zero surviving claims with quantitative content |
| E03 | Is uncertainty visually present for every quantitative claim (error bars, confidence bands, prediction intervals, perturbation ranges, or frequency framing)? | zero surviving claims with quantitative content |
| E04 | Do any visualizations use non-zero baselines, inconsistent scaling, cherry-picked ranges, misleading color scales, suppressed baselines, or obscured axis labels? | zero surviving claims with quantitative content |
| E05 | Are all figures self-contained with titles, axis labels, legends, and annotations readable without additional explanation? | zero surviving claims with quantitative content |
| E06 | Is the visualization effort proportional to the project complexity? | never |
| E07 | If the deliverable includes companion data files with point estimates (scores, probabilities, predictions), does each row include at least one uncertainty measure (confidence interval, prediction interval, stability flag, or perturbation range)? | no companion data files with point estimates |

Claude writes notebook cells using this default sequence:

1. Design visualizations for each key surviving claim that has quantitative content:
   - choose a primary display format (bar chart, line chart, table, dot plot, heatmap, etc.)
   - choose at least one alternative display format for the same data
   - render both formats in the notebook
2. Run the representation stability check:
   - compare the qualitative takeaway from each format
   - if the takeaway changes across reasonable formats, flag it
   - if the takeaway is stable, choose the format that most honestly represents the finding
   - do not choose the format that makes the finding look strongest
3. Design uncertainty visualizations:
   - error bars, confidence bands, prediction intervals, or perturbation ranges as appropriate
   - verify uncertainty is visually present for every quantitative claim
   - for audience tiers that cannot interpret standard uncertainty formats, use frequency framing or alternative visual encodings
4. Check for known visualization integrity violations:
   - non-zero baselines that exaggerate differences
   - inconsistent scaling that compresses or expands trends
   - cherry-picked data ranges
   - color scales that mislead
   - suppressed baselines or reference lines
   - axis labels that obscure units or transformations
   - dual axes or unlabeled transforms that hide the actual scale
5. Verify all figures are self-contained: titles, axis labels, legends, and annotations must be readable without additional explanation.
6. Proportionality: the visualization effort should match the project complexity. A simple descriptive report with two claims needs less visualization work than a complex predictive model output with twelve claims.
7. If companion data files will include point estimates, verify per-row uncertainty measures exist (checklist E07). If the upstream pipeline did not produce them, disclose the absence as a limitation and add a qualitative indicator derived from existing stability evidence.

**Research questions:**

- What visualization standards are conventional for this data type and audience?
- What display formats are standard for the specific chart types being used?
- What known misleading visualization patterns exist for this type of data?
- What uncertainty visualization methods are most effective for this audience tier?

**Evaluation questions:**

- Do all key findings have visual representations?
- Has each key surviving claim with a visual been tested in at least two reasonable display formats?
- Does any visualization use truncated axes, misleading scales, suppressed baselines, or cherry-picked ranges?
- Is uncertainty visually present for every quantitative claim?
- Is the chosen display format the one that honestly represents the finding?

**Evaluation focus for Cycle E:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle F: Communication Assembly and Terminal Fidelity Audit

**Focus:** Assemble the deliverable with all five mandatory sections, render it to `deliverables/`, verify fidelity against the evaluate handoff, and confirm the deliverable is self-sufficient.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| F01 | Are all five mandatory deliverable sections present (Question, Findings, Confidence, Limitations, Methods Summary)? | never |
| F02 | Is the deliverable rendered to `deliverables/` in the chosen format with a descriptive filename? | never |
| F03 | Does the terminal fidelity check confirm: every surviving claim present, every mandatory caveat present and visible, no claim upgraded, no language exceeding the claim boundary, every recommendation citing its parent claim, and no new statistics computed? | never |
| F04 | If communicate narrowed any claims, is the Claim Boundary Registry in `metrics.md` updated with the narrowing reason and cycle? | no narrowing occurred |
| F05 | Is the deliverable self-sufficient for someone with no prior project context? | never |
| F06 | Does the deliverable lead with the audience-relevant question and why it matters, rather than opening with method or workflow details? | never |
| F07 | Does the Methods Summary state data provenance, key processing steps, question type and route, and what was actually done in plain language; and include a one-paragraph intended-use statement and a prohibited-use statement inherited from 01_formulation.md `## Summary`? | never |
| F08 | Are material problems, caveats, and limitations surfaced clearly in the deliverable rather than buried, and are exploratory dead ends excluded unless needed to explain a limitation? | never |
| F10 | Do all files in `deliverables/` pass the ASCII encoding scan (no em dashes, curly quotes, en dashes, or other non-ASCII typographic punctuation)? | never |
| F11 | If companion data files exist, does each have a data dictionary (header comment, companion README, or dedicated column-definition section in the primary deliverable) defining every column or field? | no companion data files |
| F12 | If companion data files contain quantitative scores, does the value distribution show entity-level variation rather than extensive degeneracy (more than 30% of rows sharing an identical value for a key output column)? If degeneracy is present, is it disclosed as a limitation? | no companion data files with quantitative scores |

Claude writes notebook cells using this default sequence:

1. Assemble the deliverable content following the five mandatory sections:

   **Section 1: Question**
   - The approved question restated in audience-appropriate language
   - Brief context: why this question matters for the audience
   - What type of analysis was performed (question type in plain terms)
   - Open with the question and decision context, not with the method or notebook workflow

   **Section 2: Findings**
   - Each surviving claim, translated and calibrated per Cycle C
   - Evidence summaries for each claim
   - Bounded recommendations citing their parent claims
   - Claims that survived with caveats: findings and caveats presented together

   **Section 3: Confidence**
   - Uncertainty presentation calibrated per Cycle D
   - Stability evidence summary
   - Predictability evidence summary
   - Scope of perturbation testing disclosure

   **Section 4: Limitations**
   - All mandatory limitations from evaluate (non-droppable)
   - Caveats from survived-with-caveats claims
   - Claims that did not survive, stated as what the analysis could NOT establish
   - Unresolved risks
   - Data limitations surfaced across the pipeline
   - Scope restrictions from claim-boundary narrowing

   **Section 5: Methods Summary**
   - One paragraph on how the analysis was conducted
   - Use plain-language scientific-scale wording so a new reader can tell what the analysis did and what the result means
   - Question type and route
   - Data provenance and the key processing steps that produced the analyzed artifact
   - Data description (without disclosing sensitive details)
   - Link to the full Skeptic documentation for traceability
   - Statement of reproducibility: the analysis can be rerun from raw data plus protocol-defined artifacts

2. Verify writing discipline before render:
   - the opening leads with the question and why it matters
   - the Methods Summary states provenance, processing, route, and what was actually done in plain language
   - material problems and limitations are surfaced clearly rather than buried
   - exploratory dead ends are excluded unless needed to explain a limitation or caveat

3. Render the deliverable to `deliverables/` following the naming convention from the Deliverable Naming Convention section. The primary deliverable must follow the `{project_name}_{audience_type}_{date}.{format_extension}` pattern. Companion data files must follow `{project_name}_{content_description}_{date}.{ext}`.

4. **Machine-checkable validation (mandatory before step 5).** Run checklist items F01 and F10-F12 as a direct scan of the rendered files. Fix any blocking defects before proceeding.

5. Run the terminal fidelity check within this cycle:
   - verify every surviving claim from the evaluate handoff is present in the deliverable
   - verify every mandatory caveat is present and visible
   - verify no claim was upgraded from its evaluate verdict
   - verify no language exceeds the final claim boundary
   - verify every recommendation cites its parent claim and inherits its caveats
   - verify the computation boundary was respected (no new statistics, queries, or models)
   - verify the deliverable is self-sufficient: interpretable by someone with no prior project context
   - verify the opening is question-led rather than method-led
   - verify methods and provenance are described plainly enough for a new reader
   - verify material problems are disclosed rather than buried

5. Update the Claim Boundary Registry in `metrics.md` if communicate narrowed any claims. Append to `narrowing_log` with the reason and cycle.

6. Write the `## Deliverable Register` section in `07_communication.md`:

```markdown
## Deliverable Register
- Deliverable path: deliverables/{filename}
- Format: {format}
- Audience: {audience description}
- Claims communicated: {n} ({n} without caveats, {n} with caveats)
- Claims excluded (did not survive): {n}
- Mandatory limitations included: {n}
- Recommendations generated: {n}
- Claim boundary: {unchanged / narrowed from {original} to {final} because {reason}}
- Computation boundary: {respected / violations found and corrected}
```

**Research questions:**

- What deliverable structure conventions exist for this audience and format?
- What self-sufficiency standards apply (can someone use this without the analyst)?
- What reproducibility documentation should accompany the deliverable?

**Evaluation questions:**

- Are all five mandatory deliverable sections present?
- Is the deliverable rendered to `deliverables/`?
- Was the computation boundary respected?
- Is every surviving claim from the evaluate handoff present?
- Is every mandatory caveat present and visible?
- Does any language exceed the final claim boundary?
- Does every recommendation cite its parent claim and inherit its caveats?
- Is the deliverable self-sufficient for someone with no prior project context?
- Does the deliverable lead with the question rather than the method?
- Does the Methods Summary state provenance, processing, route, and what was actually done in plain language?
- Are material problems and limitations surfaced clearly instead of buried?

**Evaluation focus for Cycle F:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Backtracking Trigger Registry

These are conditions discovered during `communicate` that force a return upstream. Communicate has limited backtracking: only to `evaluate` or to `formulate` plus `protocol`.

| Trigger | Discovered during | Return to |
|---------|-------------------|-----------|
| A surviving claim cannot be stated in audience-appropriate language without exceeding the claim boundary | C | `evaluate` to reconsider whether the claim genuinely survived within its stated boundary |
| Mandatory caveats make a claim so hedged it communicates no useful information, yet removing the caveats would exceed the boundary | C | `evaluate` to reconsider the caveat structure or downgrade the claim |
| The surviving claims do not address the original question at a level useful to any reasonable audience | B or C | `formulate` plus `protocol` to reassess the question |
| The claim boundary must widen to produce any meaningful deliverable | C or F | `formulate` plus `protocol` -- widening is never allowed within `communicate` |

`communicate` cannot backtrack to `analyze`, `clean`, or `examine`. If the issue is analytical (wrong method, insufficient data, cleaning error), the project must route through `evaluate` first.

When backtracking occurs, preserve the earlier record and mark it as superseded. Do not pretend the earlier work never happened.

## Ending the Cycle Loop

The cycle loop ends when:

- all six mandatory cycles are complete
- the user has approved the audience identification (Cycle B)
- interactive mode: the user indicates the stage is ready for post-cycle review
- auto mode: the mandatory cycles are complete, so the stage advances to stage-close review under `references/auto-mode.md`

Do not finalize because the stage "seems good enough." Require an explicit decision.

## Post-cycle Evaluation

After the cycle loop, move through two phases. Interactive mode waits for user review between phases. Auto mode follows `references/auto-mode.md` and pauses only on escalation triggers or the final stage-boundary approval.

| Before | Required state |
|--------|----------------|
| Phase 1: Terminal Fidelity Check | Cycle loop complete. Deliverable rendered to `deliverables/`. |
| Phase 2: Finalization | Fidelity check passed. Results confirmed in `07_communication.md`. |

### Phase 1: Terminal Fidelity Check

**Goal:** Independently verify that the deliverable faithfully represents the evaluate handoff without claim inflation, caveat suppression, boundary widening, or selective reporting.

This is a dedicated subagent that reads the evaluate handoff AND the assembled deliverable and mechanically checks fidelity. It is distinct from the evaluation subagent inside Cycle F -- it provides an independent second check on the final artifact.

Dispatch the terminal fidelity subagent:

```text
Agent(
  model="{subagent_model}",
  description="Terminal fidelity check for communicate",
  prompt="""
  You are a terminal fidelity auditor for a Skeptic communicate stage.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/06_evaluation.md
  2. {projects_root}/{project-name}/{docs_dir_name}/07_communication.md
  3. {projects_root}/{project-name}/deliverables/{deliverable-filename}
  4. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  5. {projects_root}/{project-name}/{docs_dir_name}/metrics.md

  Perform these mechanical checks:

  1. CLAIM COMPLETENESS: Does every claim from the evaluate Claim
     Survival Registry appear in the deliverable? List any missing
     claims. Claims that survived and survived-with-caveats must
     appear in the Findings section. Claims that did not survive
     must appear in the Limitations section.

  2. CAVEAT PRESERVATION: Is every mandatory caveat from the evaluate
     handoff present in the deliverable? Is each caveat visible and
     substantive (not buried in a footnote or appendix)? List any
     missing or buried caveats.

  3. CLAIM FIDELITY: Was any claim upgraded from its evaluate verdict?
     Does any "survived with caveats" claim read as if it survived
     without caveats? Does any "did not survive" claim read as if
     the evidence was almost sufficient? List any upgrades.

  4. BOUNDARY INTEGRITY: Is the final claim boundary in the deliverable
     equal to or narrower than the final claim boundary from evaluate?
     Does any sentence in the deliverable exceed the claim boundary?
     Check against the Claim Boundary Registry in metrics.md: are
     all verbs from verbs_allowed? Is scope respected? Is
     generalization_limit respected? Flag any violations.

  5. LIMITATION COMPLETENESS: Are all mandatory limitations from the
     evaluate handoff present in the Limitations section? List any
     missing limitations.

  6. RECOMMENDATION SCOPE: Does every recommendation cite its parent
     claim? Does every recommendation stay within the claim boundary?
     Does every recommendation inherit the caveats of its parent
     claim? List any overreaching recommendations.

  7. COMPUTATION BOUNDARY: Does the deliverable or the notebook contain
     evidence of new statistics, new queries, new models, or any
     computation that changes the substance of a finding? List any
     violations.

  8. SELF-SUFFICIENCY: Could someone with no prior project context
     understand the deliverable? Are all technical terms explained?
     Does the deliverable assume shared context that the audience
     lacks?

  9. MANDATORY SECTIONS: Are all five mandatory sections present
     (Question, Findings, Confidence, Limitations, Methods Summary)?

  10. ENCODING INTEGRITY: Do all deliverable files use ASCII-only
      punctuation per core-principles.md? List violations.

  11. COMPANION DATA QUALITY: If companion data files exist, are
      they referenced, documented with a data dictionary, and
      free of undisclosed value degeneracy (>30% identical in a
      key output column)?

  Output format:

  CLAIM COMPLETENESS: PASS / FAIL
  - [missing claims, if any]

  CAVEAT PRESERVATION: PASS / FAIL
  - [missing or buried caveats, if any]

  CLAIM FIDELITY: PASS / FAIL
  - [upgrades found, if any]

  BOUNDARY INTEGRITY: PASS / FAIL
  - [violations found, if any]

  LIMITATION COMPLETENESS: PASS / FAIL
  - [missing limitations, if any]

  RECOMMENDATION SCOPE: PASS / FAIL
  - [overreaching recommendations, if any]

  COMPUTATION BOUNDARY: PASS / FAIL
  - [violations found, if any]

  SELF-SUFFICIENCY: PASS / FAIL
  - [gaps found, if any]

  MANDATORY SECTIONS: PASS / FAIL
  - [missing sections, if any]

  ENCODING INTEGRITY: PASS / FAIL
  - [violations found, if any]

  COMPANION DATA QUALITY: PASS / FAIL / N/A
  - [issues found, if any]

  OVERALL: PASS / FAIL
  - [summary]
  """
)
```

After the subagent returns:

1. Present the fidelity check results to the user.
2. If any check FAILS:
   - identify the specific cycle that introduced the problem
   - reopen that cycle to fix the issue
   - do not proceed to Phase 2
3. If all checks PASS: proceed to Phase 2.

### Phase 2: Finalization

After the terminal fidelity check passes:

1. **Communication Scorecard (mandatory first item).** Append to `skeptic_documentation/metrics.md` under `## Communication`.

```markdown
### Communication Scorecard
| metric | value | source |
|--------|-------|--------|
| Checklist items answered | {answered}/{total} | cycle logs |
| Mandatory cycles completed | {n}/6 | cycle logs |
| Total iterations (all cycles) | {n} ({cycle}: {n}, ...) | cycle logs |
| Blocking failures total | {n across all cycles} | gate registry |
| Blocking failures resolved by iteration | {n} | gate registry |
| Blocking failures resolved by override | {n} ({list override reasons}) | gate registry |
| Claims communicated | {n} | draft output |
| Survived claims included | {n}/{total survived} | evaluate handoff |
| Mandatory caveats included | {n}/{total mandatory} | evaluate handoff |
| Dropped caveats | {n} (must be 0) | draft review |
| Claim boundary violations | {n} (must be 0) | draft review |
| Claims excluded (did not survive) | {n} | evaluate handoff |
| Mandatory limitations disclosed | {n} | evaluate handoff |
| Recommendations generated | {n} | draft output |
| Claim boundary | {unchanged / narrowed} | metrics.md |
| Computation boundary violations | {n} | cycle logs |
| Terminal fidelity check | PASS / FAIL | Phase 1 |
| Audience | {audience type} | Cycle B |
| Delivery format | {format} | Cycle B |
| Deliverable path | deliverables/{filename} | Cycle F |
| Research sources per cycle | {avg sources returned across cycles} | cycle logs |
| Evaluation alignment | {aligned count}/{total cycles} (exclude indeterminate from denominator) | cycle logs |
```

2. **Update `07_communication.md`** with `## Summary` containing:
   - audience and delivery format
   - claims communicated (with and without caveats)
   - claims excluded
   - mandatory limitations disclosed
   - recommendations generated
   - claim boundary status
   - terminal fidelity check result
   - deliverable location

3. **Update `## PCS Assessment`** with: "This stage is the terminal communication of PCS-evaluated claims. The terminal fidelity check verified that the deliverable faithfully represents the evaluate handoff. See the Deliverable Register for the communication record."

4. **Update Claim Boundary Registry** in `metrics.md` if communicate narrowed any claims.

5. **Update `README.md`:**

```markdown
## Communicate [COMPLETE]
Type: {question type}
Active route: {route}
Audience: {audience type}
Format: {delivery format}
Claims communicated: {n} ({n} with caveats)
Claims excluded: {n}
Limitations disclosed: {n}
Deliverable: deliverables/{filename}
```

6. Read `README.md` and quote the `## Communicate [COMPLETE]` block verbatim in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete — return to the README-update step. Only then tell the user the Skeptic is complete and state the deliverable location.

## Dependency Notes

- `formulate`, `protocol`, `clean`, `examine`, `analyze`, and `evaluate` are mandatory dependencies for `communicate`.
- `evaluate` produces the structured handoff that `communicate` packages. `communicate` does not modify or re-evaluate it.
- `communicate` does not load route-specific overlay files. It is route-aware from the evaluate handoff content.
- `communicate` may narrow the Claim Boundary Registry. It may not widen it.
- `communicate` has limited backtracking: to `evaluate` (claim cannot be faithfully communicated within its boundary) or to `formulate` plus `protocol` (surviving claims do not address the question at a useful level). It cannot backtrack to `analyze`, `clean`, or `examine`.
- `communicate` is the terminal stage. There is no downstream stage.
- If question type, target quantity, or claim boundary needs changing, reopen `formulate` and `protocol`.
- `communicate` does not choose methods, generate claims, re-execute analysis, re-evaluate claims, or compute new statistics.
- One deliverable per `communicate` run. If multiple audiences are needed, rerun `communicate` with a different audience specification.
