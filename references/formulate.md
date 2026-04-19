---
name: formulate
description: Use when starting a new data analysis project - refine a vague domain question into a precise, data-answerable question through iterative question-first cycles with format-aware dataset inspection. First stage of the Skeptic.
---

# /skeptic:formulate - Problem Formulation and Data Context

**IMPORTANT:** Before executing, read `references/core-principles.md` from the parent `skeptic` skill for shared conventions.

`core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

A good analyst updates the question instead of forcing the original wording through unsuitable data. Expect the question to evolve as data constraints become clear. This is not failure—it is the formulation process working correctly.

## Required Inputs

| Input | Description |
|-------|-------------|
| Project name | Subfolder name under the configured `projects_root` |
| Data source(s) | Path, table, file list, or other portable locator for the raw data source |
| Rough domain question | What the user wants to answer with this data |

If any input is missing, use `AskUserQuestion` to collect it before proceeding.

After collecting the project name, resolve the full project path as `{projects_root}/{project-name}` and present it to the user for confirmation. The user may accept or provide an alternative path. If the user provides an alternative, use that path for this project without modifying `skeptic.yaml`. Data files will always be copied into the project's data directory, never moved from their original location.

Also ask: "Do you have any documentation for this data (codebook, README, data dictionary, collection notes)?" If yes, copy it into the configured data directory and read it before generating the initial notebook. This materially changes how variables, units, collection logic, and biases are interpreted.

## Cycle Structure

The formulate stage progresses through mandatory cycles. Each cycle uses the same human-in-the-loop Jupyter workflow and the same dual-subagent review pattern. After the mandatory cycles, Claude or the evaluation subagent may propose additional cycles.

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Setup + Data Overview | Yes |
| B | Data Understanding | Yes |
| C | Question Type Classification | Yes |
| D | Operationalization | Yes |
| E | Collection and Biases | Yes |
| F+ | Context-dependent follow-ups | No |

Do not skip A-E. Do not collapse them into one pass. Formulation quality depends on repeated inspection, critique, and revision.

## Gate Condition Registry

Every evaluation gate has a stable ID used in cycle metrics. The evaluation subagent references these IDs in its structured output.

| gate_id | cycle | depends_on | condition |
|---------|-------|------------|-----------|
| `A-loadable` | A | A01 | Data loadable and structurally sound |
| `A-relevant` | A | A01, A02, A03 | Data appears relevant to the stated question |
| `A-question-fit` | A | A01, A02, A03, A06 | The question is framed as a real stakeholder or scientific problem, not a method request; at least two plausible framings were considered; and the approved framing is useful, specific, not already sufficiently answered, and plausibly answerable with available evidence |
| `A-audience-defined` | A | A08 | The intended audience is identified and the question is framed to be relevant to them |
| `A-no-red-flags` | A | A03, A04, A05 | No immediate structural red flags likely to derail formulation |
| `B-variables-understood` | B | B01, B02 | Relevant variables are understood well enough to reason about the question |
| `B-units-clear` | B | B03 | Unit of analysis or observational unit is clear |
| `B-no-ambiguity` | B | B04 | Major ambiguities that would distort interpretation are surfaced |
| `B-gap-assessed` | B | B05 | Gap between available data and ideal data is explicitly assessed |
| `C-type-classified` | C | C01 | Question classified into one of the six types |
| `C-type-supported` | C | C02 | Data collection and design plausibly support the classified type |
| `C-downstream-constraints-stated` | C | C03 | Consequences for `protocol`, route overlays, and later `analyze` are stated |
| `D-terms-identified` | D | D01 | Abstract or ambiguous terms are identified |
| `D-terms-operationalized` | D | D02 | Each key term is mapped to a column, metric, or derived metric |
| `D-competing-defs` | D | D02 | Competing operationalizations are considered before choosing one |
| `D-availability-checked` | D | D03 | Practical availability is verified for chosen operationalizations |
| `D-target-quantity-stated` | D | D04 | Target quantity or estimand is named |
| `D-claim-boundary-stated` | D | D05 | Claim boundary is stated explicitly |
| `D-route-candidates-ranked` | D | D07 | Route candidates are ranked and justified |
| `D-unit-of-analysis-stated` | D | D06 | Unit of analysis is explicitly stated |
| `D-context-stated` | D | D06 | Target population or deployment context is stated if relevant |
| `D-assumptions-stated` | D | D09 | Key assumptions are stated explicitly |
| `D-related-concepts` | D | D08 | Related concepts, modifiers, or confounders are identified |
| `D-baseline-stated` | D | D10 | Baseline the project must beat is stated |
| `D-error-costs-stated` | D | D11 | Error types and their costs in the decision context are stated, including which errors are unacceptable |
| `D-uplift-stated` | D | D12 | Minimum useful uplift over baseline is stated |
| `D-prior-art-reviewed` | D | D13 | Prior art or analogous work is reviewed and its consequences for scope, assumptions, or project order are stated |
| `D-unfeasible-flagged` | D | D01, D02 | Un-operationalizable terms are flagged with a recommended action |
| `D-measurement-mismatch` | D | D03 | Direct measure vs. proxy risk is assessed for each chosen operationalization |
| `D-confounding` | D | D08 | Confounding or identification relevance is assessed at a high level |
| `E-collection-understood` | E | E01 | Data collection process is understood well enough to proceed |
| `E-biases-assessed` | E | E05, E06 | Collection, selection, recall, measurement, and other relevant biases are assessed |
| `E-generalizability` | E | E06 | Generalizability risks relative to target population or deployment context are assessed |
| `E-data-usage-facts` | E | E01, E02, E03, E04 | Facts needed by `protocol` to decide data usage mode are surfaced |
| `E-validation-needs-framed` | E | E07 | High-level future validation needs are framed without locking the protocol |
| `E-open-protocol-questions` | E | E08 | Unresolved questions for `protocol` are explicitly listed |

**Note on diagnostic gates:** `D-measurement-mismatch`, `D-confounding`, and `E-validation-needs-framed` are diagnostic. A FAIL on one of these gates signals a bounded risk or unresolved protocol question. It does not automatically fail the cycle if the issue is surfaced clearly and the user decides to proceed with the risk documented.

## Cycle Protocol

This protocol applies to every cycle.

### Step 1: Setup and Execution

- Claude reads existing notebook outputs. Skip this only for Cycle A.
- Claude identifies what analysis is needed for the current cycle.
- Claude writes new notebook cells with code plus markdown reasoning.
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
  description="Domain research for Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a domain research assistant for a data science project.

  Context: The project is about "{rough question}" using data with these characteristics:
  {summary of key notebook findings from this cycle}

  User observations: {user's questions or observations, if any}

  Answer these research questions for Cycle {X} ({cycle focus}):
  {insert the research questions from the current cycle's definition below}

  Return: concise findings with sources (include the URL for every citation), organized by question.
  Focus on facts that materially change formulation, protocol handoff, or claim boundaries.
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
  You are an objective evaluator for a data science formulation cycle.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  2. {projects_root}/{project-name}/{notebooks_dir_name}/01_formulation.ipynb

  Cycle focus: {cycle focus description}
  User observations: {user's questions or observations, if any}

  Before evaluating gates, verify that all checklist items for this cycle were answered with evidence in the notebook. If any checklist item was not answered, the gates that depend on it auto-fail.

  Produce this structured output (follow this exact structure in order):

  EVALUATION: Cycle {X} - {focus}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Your job is to actively falsify each gate
  and checklist answer rather than confirm them. For each gate you mark PASS,
  you must state the specific failure mode you tested and ruled out.
  Categories to scan: unstated assumptions, missing edge cases, unverifiable
  criteria, logical gaps between goal and method, vague or unoperationalized
  terms, protocol-relevant omissions.
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

  GATE ASSESSMENTS (use gate IDs from the Gate Condition Registry for this cycle):
  - {gate_id}: PASS / FAIL - [evidence from notebook outputs]
  - {gate_id}: PASS / FAIL - [evidence from notebook outputs]
  (list every gate for this cycle, not just failures)

  Alternatives considered:
  - Current approach: [description] -> Score: [1-10] - [one-line justification]
  - Alt 1: [different framing/approach] -> Score: [1-10] - [one-line justification]
  - Alt 2: [different framing/approach] -> Score: [1-10] - [one-line justification]

  Gaps remaining: [list, or "none"]
  Protocol implications: [facts this cycle surfaced that should constrain `protocol`, or "none"]
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

When both subagents return, Claude synthesizes them into one unified assessment. Log the raw subagent outputs inside the stage's decision log (the main `0X_{stage}.md` document) under a `### Cycle {X} raw subagent outputs` subsection. The research subagent's output must include the URLs for every resource it cites.

Count the blocking failures from the evaluation subagent output: blocking defects plus gates with verdict FAIL. Then apply the decision matrix.

**Decision matrix:**

| blocking_failures | forward actions allowed | note |
|-------------------|------------------------|------|
| 0 | pass, iterate | cycle meets minimum bar |
| > 0 | iterate, acknowledge gap (with written justification) | pass is blocked until blocking failures are resolved or justified |

**Always-available actions (regardless of blocking_failures):**

- **Reopen formulate** -> write more cells targeting the gaps, rerun from Step 2
- **Data insufficient** -> log why and present options (request additional data, reformulate, archive)
- **User override** -> user states the specific reason the FAIL is incorrect, logged as `override: {reason}`, forward actions unlock

Interactive mode: present the synthesized assessment to the user via the **AskUserQuestion** tool, offering the allowed actions from the matrix as selectable options. Do not invoke any other tool until the user answers. The answer is the only valid trigger for continuing.

Auto mode: apply the autonomous decision protocol from `references/auto-mode.md`, log the rationale, and continue without waiting unless an escalation trigger fires.

Do not fabricate findings. Do not force optimistic assessments to keep the process moving. If the data cannot answer the cycle's question, say so. At any cycle, if the evidence shows the data is insufficient:

- **Request additional data** - specify what is needed and why
- **Reformulate** - pivot to a question the data can support
- **Archive** - stop with documentation of why

### Step 5: Log

Immediately after each cycle decision, append to `skeptic_documentation/01_formulation.md`:

```markdown
### Cycle {X}: {Focus}
- **What we inspected:** [notebook cells run, data examined]
- **Research findings:** [key domain context from research subagent]
- **Evaluation verdict:** PASS / FAIL
- **Alternatives considered:** [from evaluation subagent, with scores]
- **Protocol implications:** [facts this cycle surfaced that should constrain `protocol`]
- **Gaps:** [remaining gaps, if any]
- **Decision:** [pass / iterate / acknowledge gap / data insufficient - with reasoning]
```

Also append structured cycle metrics to `skeptic_documentation/metrics.md`. Create the file if it does not exist, starting with `# Skeptic Metrics` and `## Formulation`.

Every cycle logs the same base fields.

```markdown
**Cycle metrics:**
- iterations: {n}
- verdict: PASS/FAIL (on iteration {n})
- gates: [{gate_id}: PASS/FAIL, ...]
- research_sources_returned: {n}
- evaluation_verdict_aligned: yes/no/partial/indeterminate
- protocol_questions_open: {n}
```

## Cycle A: Setup + Data Overview

**Focus:** Create project structure, load data, and establish first-pass relevance.

Before loading data, read `references/data-formats.md` and apply the format-specific ingest checklist for each source file's format. These checks supplement the Cycle A checklist below.

**Setup actions unique to Cycle A:**
1. Create the project folder structure:
   ```text
   {projects_root}/{project-name}/
   |- {data_dir_name}/
   |- {docs_dir_name}/
   |- {notebooks_dir_name}/
   `- {readme_name}
   ```
2. If the sources are local files, copy them into the configured data directory. If the sources are database-backed or remote, create a portable source note in the configured data directory that records source names, tables, file patterns, and any non-secret access instructions. Copy any documentation into the configured data directory.
3. Create the configured README file with project name, date, and data source names as the data source.
4. Create `01_formulation.md` in the configured documentation directory with this skeleton:
   ```markdown
   # Formulate: Problem Formulation

   ## Dataset
   - Sources: {data source names or manifest}
   - Rough question: {rough domain question}
   - Date started: {date}

   ## Decision Log

   ## Summary
   Placeholder only. Fill at finalization.

   ## Protocol Handoff
   Placeholder only. Fill at finalization.

   ## PCS Assessment
   Placeholder only. Fill after PCS review.
   ```
5. Create `01_formulation.ipynb` in the configured notebooks directory with initial cells.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| A00 | For each source data file, what is the detected character encoding? (Follow the Source Data Encoding rules in `core-principles.md`. Record detected encoding, verify loaded values display correctly, and ensure all downstream reads use the detected encoding explicitly.) | never |
| A01 | What is the shape, column list, and dtype of each loaded source? | never |
| A02 | What do sample rows look like? | never |
| A03 | What are the basic statistics and missing-value counts per column? | never |
| A04 | For low-cardinality categorical columns, what are the value distributions? | never |
| A05 | If the question involves time, what is the date coverage and time grain? If grouping matters, what are group counts? If multiple tables, what is join-key overlap? | never |
| A06 | Is the question framed as a real stakeholder or scientific problem, not a method request; have at least two plausible framings been considered; and is the approved framing useful, specific, not already sufficiently answered, and plausibly answerable with available evidence? | never |
| A07 | For each raw data file, what is its SHA-256 hash? (Compute and log in the notebook and in `01_formulation.md` under a `## Raw File Hashes` section. These hashes serve as the immutability baseline for all downstream stages.) | never |
| A08 | Who is the intended audience for this question, and is the question interesting or useful to them? | never |

**Research questions:**
- What domain context matters for understanding this dataset?
- Are there known data quality issues or collection artifacts typical of this source type?
- What codebooks, metadata standards, or public documentation usually exist for this kind of data?
- What business or scientific decision is this question meant to support?
- What prior art or similar analyses already answer part of this question, and would that change project order or scope?
- What are the main alternative framings of the same underlying problem, and how do they differ in audience, decision, or claim boundary?
- Is the question already answered well enough that this project should narrow, reorder, or stop?
- What makes this question concretely answerable with the data and resources that are actually available?

**Evaluation focus for Cycle A:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

Tell the user: "Notebook created at `{notebooks_dir_name}/01_formulation.ipynb`. Run all cells in Jupyter and come back when done."

## Cycle B: Data Understanding

**Focus:** Understand what the variables mean, what the rows represent, and how far the available data is from the ideal evidence for the question.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| B01 | What do the relevant variables mean in domain context, including units and expected ranges? | never |
| B02 | What relationships exist between columns, and do derived columns already exist? | never |
| B03 | What does each row represent (unit of analysis / observational unit)? | never |
| B04 | Where do materially different interpretations exist, and which interpretation does the user choose? | no ambiguity surfaced in Cycle A |
| B05 | What would the ideal dataset for this question contain, and what is present versus missing? | never |

Where relevant, make the user choose between materially different interpretations instead of letting ambiguity survive into later stages.

**Research questions:**
- What do the specific variables and measurements mean in domain context?
- What are standard units, scales, and expected ranges for these measurements?
- What variables would an ideal dataset include for answering this question, and which are present versus missing?
- What sampling or instrumentation details matter for interpreting these variables correctly?

**Evaluation focus for Cycle B:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle C: Question Type Classification

**Focus:** Classify the question into one of six types. Assess whether the data collection and design can support that type.

The six question types are:

| Type | What it asks | Data or design requirement |
|------|---------------|----------------------------|
| **Descriptive** | What is present in this dataset or monitoring frame? | A defined reporting frame and defensible denominators |
| **Exploratory** | What patterns, structures, or anomalies are worth following up? | Open search with explicit hypothesis-generating status |
| **Inferential** | What pattern or quantity in this sample generalizes to a target population? | A defensible sampling or modeling frame for that population |
| **Predictive** | How well can unseen outcomes, probabilities, rankings, or forecasts be predicted in a defined deployment setting? | Predeclared targets plus protocol-approved unseen-data validation logic |
| **Causal** | Does changing X change Y, on average? | A defensible identification strategy |
| **Mechanistic** | What process generates the observed behavior? | Structured domain knowledge and a defensible structural model |

This classification is not a model-selection shortcut. It constrains:

- `protocol` - data usage mode, leakage rules, validation logic, and claim boundary
- route overlays - which evidence patterns and prohibitions later apply
- `analyze` - what the later analysis contract may and may not contain

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| C01 | Based on the rough question and Cycle A-B findings, which of the six question types best fits? | never |
| C02 | Does the current data collection, design, and variable coverage support the proposed type? If not, what is the strongest defensible alternative? | never |
| C03 | What are the downstream consequences for `protocol`, route overlays, and later `analyze`? | never |
| C04 | If the data cannot support the preferred type, what would be required for the original? | data supports the preferred type |

**Research questions:**
- What question types and study designs have been used to answer similar questions?
- What methodological requirements typically apply to each plausible type in this domain?
- Are there published examples where similar data was sufficient or insufficient for this type of question?

Operational note:
- inferential questions estimate quantities in a population or sampling frame
- predictive questions target unseen outcomes in a deployment context
- classification or unsupervised methods do not become predictive by default just because they are machine-learning methods

**Evaluation focus for Cycle C:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Cycle D: Operationalization

**Focus:** Turn the approved question into a measurable, bounded, downstream-usable object.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| D01 | Which terms in the question are vague, contested, or not directly mapped to a column? | never |
| D02 | For each such term, what are the candidate columns or derived metrics, and what are the tradeoffs between them? | never |
| D03 | For each candidate operationalization, what is the practical availability (granularity, missingness, support, value distribution, direct measure vs. proxy)? | never |
| D04 | What is the target quantity or estimand the later analysis must estimate, summarize, predict, or explain? | never |
| D05 | What claim boundary is implied by the question type and data design? | never |
| D06 | What is the unit of analysis, and what is the target population or deployment context if it materially matters? | unit of analysis already fixed in Cycle B (for the unit portion only) |
| D07 | What are the ordered route candidates for later stages, and why is the top route best? | never |
| D08 | What related concepts, effect modifiers, confounders, or structural dependencies must later stages respect? | never |
| D09 | What key assumptions are required for the approved formulation to remain coherent? | never |
| D10 | What is the baseline the project must beat? | never |
| D11 | What does each error type (false positive, false negative, over/underestimation, etc.) cost in the decision context? Which errors are unacceptable regardless of overall accuracy? | never |
| D12 | What minimum uplift over baseline would make this project worthwhile? | never |
| D13 | What prior art or analogous work changes the question framing, scope, assumptions, or project order? | never |

If no viable operationalization exists for a key term, do not bury it. Flag it and force the user decision in Step 4.

**Research questions:**
- For each abstract term, what are the standard and competing operationalizations in credible literature or domain practice?
- What validated measures, indices, or proxies exist?
- What known confounders, effect modifiers, or structural dependencies matter for this kind of question?
- When direct measures are unavailable, which proxies are accepted and what do they fail to capture?
- What prior art or analogous analyses already constrain the interpretation of the question or its target quantity?
- What baseline or success criteria are used in similar work, and do they change the practical framing here?

**Step 4 addition:** After the standard decision, propose a refined question with operationalized definitions inline. Also state:

- approved question wording
- question type
- target quantity or estimand
- claim boundary
- ordered route candidates
- unit of analysis
- target population or deployment context, if relevant
- key assumptions
- baseline, error type costs (including which errors are unacceptable), and minimum useful uplift
- prior-art implications for scope or project order
- if inferential or causal: null hypothesis, alternative hypothesis, treatment or exposure, and outcome
- what business or scientific decision the question is meant to support
- what success looks like in substantive terms

User approves or rejects the wording and the boundary. Do not auto-finalize this cycle without that explicit approval.

**Evaluation focus for Cycle D:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

**Log extension:** Append after the standard log entry:

```markdown
- **Question type:** {type} - {one-line justification}
- **Approved question:** {final approved question with operationalized definitions inline}
- **Target quantity:** {what later work must estimate, summarize, predict, or explain}
- **Claim boundary:** {descriptive / exploratory / inferential / predictive / causal / mechanistic boundary}
- **Route candidates:** {ordered list, most appropriate first}
- **Unit of analysis:** {unit}
- **Target population / deployment context:** {context, or "not central"}
- **Key assumptions:**
  - {assumption}
  - {assumption}
- **Operationalization decisions:**
  - "{term}" -> {chosen metric or column} - {one-line rationale}
- **Alternatives ruled out:** {term}: {alternative} ({why rejected})
- **Derived metrics introduced:** {metric name} = {formula} (or "None")
```

## Cycle E: Collection and Biases

**Focus:** Surface the collection, bias, generalizability, and deployment-context facts that `protocol` needs before it can define the project rules of the game.

### Checklist

| id | question | skip_when |
|----|----------|-----------|
| E01 | How was the data collected, generated, sampled, or recorded? | never |
| E02 | What is the time coverage, refresh cadence, and are there temporal gaps? | never |
| E03 | Is there grouping, clustering, panel, hierarchy, or interference structure? | never |
| E04 | Is the data a one-off extract, a monitoring stream, or a partially refreshed process? Are leakage-relevant fields or structures present (future information, post-outcome fields, target proxies, delayed labels, timestamp lookahead)? | never |
| E05 | How representative is the data relative to the target population or deployment context? | never |
| E06 | What selection, recall, measurement, survivorship, missingness, and other relevant biases are present? | never |
| E07 | Is the question tied to a deployment context, a reporting frame, or a population-level claim, and what kinds of future validation may be needed at a high level? | never |
| E08 | What unresolved questions must be passed to `protocol`? | never |

Do not decide the final data usage mode here. Do not create splits, folds, frozen holdouts, or validation artifacts here. Surface the facts that `protocol` needs in order to decide those things.

**Research questions:**
- How is this type of data typically collected in practice, and what limitations usually follow?
- What selection, recall, measurement, or surveillance biases are documented for similar sources?
- How far do findings from this kind of data usually generalize?
- What validation patterns are commonly needed for similar questions: refreshed data, external corroboration, group-aware checks, rolling validation, resampling, or something else?

**Evaluation focus for Cycle E:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

**Step 4 addition:** After the standard decision, produce a draft `protocol` handoff note that states:

- recommended data-usage considerations
- leakage-relevant facts, candidate forbidden-variable classes, or unresolved leakage risks
- whether future unseen-data validation seems relevant
- whether confounding or identification is likely central
- whether time ordering, grouping structure, or monitoring or refresh context matters
- whether the route family seems stable or still uncertain
- data collection and generalizability risks
- unresolved protocol questions

This draft informs `protocol`. It does not replace `protocol`.

## Follow-up Cycles

After the mandatory cycles, additional cycles are triggered by:

1. Claude proposes one based on accumulated findings across A-E
2. The evaluation subagent recommends one

The user approves or skips each proposed follow-up cycle. Follow-up cycles follow the same protocol. Keep them narrow and purpose-built. Examples:

- deep dive into a disputed variable definition
- resolving a target population mismatch
- challenging whether two plausible question types remain live
- clarifying whether a route family is genuinely stable or still open

Each follow-up cycle must define its own checklist before execution:

### Checklist (template for follow-up cycles)

| id | question | skip_when |
|----|----------|-----------|
| F{n}01 | {question derived from the specific follow-up topic} | {condition or "never"} |

Follow-up cycle IDs use F1, F2, F3, etc. as the cycle letter prefix (F101, F102, F201, F202, ...).

**Evaluation focus for follow-up cycles:**
The evaluation subagent checks: 1. For each checklist item: was it answered with evidence in the notebook? If not, dependent gates auto-fail. 2. For each gate where depends_on includes items from this cycle: does the answer satisfy the condition?

## Ending the Cycle Loop

The loop ends when:

- all mandatory cycles are complete
- all approved follow-up cycles are resolved or skipped
- interactive mode: the user explicitly approves the final question and the protocol handoff material
- auto mode: the stage summary and approval gate defined in `references/auto-mode.md` are complete

Do not finalize because "it seems good enough." Finalization requires explicit stage-close discipline.

## PCS Subagent Review

After the stage is ready to close under the active execution mode, dispatch a PCS review subagent:

```text
Agent(
  model="{subagent_model}",
  description="PCS review of formulate stage",
  prompt="""
  You are a PCS reviewer for a data science project.

  Read these files:
  1. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.md
  2. {projects_root}/{project-name}/{notebooks_dir_name}/01_formulation.ipynb

  Evaluate whether formulation adequately supports the downstream `protocol`
  and `analyze` stages.

  PREDICTABILITY:
  - Does the approved question match the reality the project actually needs to address?
  - Are future validation needs framed at the right level without forcing one validation template?
  - Are target population or deployment-context mismatches surfaced?

  STABILITY:
  - Could a different but still reasonable question formulation materially change the allowed claim?
  - Could a different but still reasonable operationalization materially change the route candidates or target quantity?
  - Are key assumptions explicit, or is the formulation hiding them?

  COMPUTABILITY:
  - Are variables, units, target quantity, and claim boundary documented clearly enough for downstream execution?
  - Are unresolved protocol questions explicit rather than left implicit?
  - Is the audit trail strong enough that another analyst could understand why this formulation was approved?

  Produce an objective assessment. For each lens, state:
  - What holds up well
  - What is uncertain or risky
  - Specific recommendations, if any

  Keep it concise.
  """
)
```

After the subagent returns:
1. Append the PCS assessment to `01_formulation.md` under `## PCS Assessment`.
2. Interactive mode: present the assessment to the user via the **AskUserQuestion** tool, offering these options:
   - **Satisfied** -> proceed to finalization
   - **Valid concern** -> return to the cycle loop
   - **Disagree** -> log the override and proceed

   Do not invoke any other tool until the user answers.
3. Auto mode: record the PCS assessment in the stage summary, apply non-blocking fixes autonomously, and escalate only if the review exposes a blocking concern or the user rejects the stage at the stage boundary.

The subagent advises. It does not silently widen scope or bypass a blocking concern.

## Finalization

After the PCS review clears, or the user overrides it:

### Formulation Scorecard
| metric | value | source |
|--------|-------|--------|
| Checklist items answered | {answered}/{total} | cycle logs |
| Mandatory cycles completed | {n}/5 | cycle logs |
| Follow-up cycles | {n} ({list topics}) | cycle logs |
| Total iterations (all cycles) | {n} ({cycle}: {n}, ...) | cycle logs |
| Blocking failures total | {n across all cycles} | gate registry |
| Blocking failures resolved by iteration | {n} | gate registry |
| Blocking failures resolved by override | {n} ({list override reasons}) | gate registry |
| Question type classified | {type} | Cycle C output |
| Operationalization complete | {yes/no} | Cycle D output |
| Claim boundary stated | {yes/no} | Cycle D output |
| Protocol handoff drafted | {yes/no} | Cycle E output |

Append this scorecard to `skeptic_documentation/metrics.md` under `## Formulation`.

**Claim Boundary Registry (mandatory - second item in finalization).** Write the registry to two locations:

1. A standalone file at `skeptic_documentation/claim_boundary_registry.yaml`. This is the canonical, machine-parseable source. Parse it as YAML after writing to verify it is valid. If parsing fails, repair before proceeding.
2. Append the same content to `skeptic_documentation/metrics.md` under `## Claim Boundary Registry` as a YAML code block for human readability.

Both copies must be identical. The standalone YAML file is the canonical source. If the `metrics.md` copy becomes corrupted, regenerate it from the standalone file. All downstream evaluation subagents will use the registry to verify claim-boundary compliance.

Generate the registry from the approved question, question type, and the question type constraints in `core-principles.md`. The `verbs_allowed` and `verbs_forbidden` lists are derived from the question type's interpretation boundary and admissible evidence pattern. The `scope` and `generalization_limit` come from Cycle D and Cycle E outputs.

```markdown
### Claim Boundary Registry
```yaml
claim_type: {one of: descriptive, exploratory, inferential, predictive, causal, mechanistic}
scope: "{what the claim covers, from Cycle D operationalization}"
target_quantity: "{from Cycle D}"
verbs_allowed:
  - {verbs consistent with the question type's interpretation boundary}
verbs_forbidden:
  - {verbs that would exceed the question type's interpretation boundary}
evidence_ceiling: "{what kinds of evidence the claim may rest on, from core-principles.md question type constraints}"
generalization_limit: "{population, context, or deployment scope the claim may not exceed}"
narrowing_log: []
```
```

**Registry derivation rules by question type:**

| Question type | verbs_allowed (defaults) | verbs_forbidden (defaults) |
|---------------|------------------------|---------------------------|
| descriptive | describe, summarize, compare, report, characterize, count | predict, cause, explain, generalize, infer, recommend |
| exploratory | explore, surface, suggest, hypothesize, identify candidates | confirm, prove, establish, demonstrate, predict, cause |
| inferential | estimate, generalize, quantify, test, infer | cause, predict deployment, explain mechanism, recommend treatment |
| predictive | predict, forecast, classify, score, rank | cause, explain, attribute, identify mechanism |
| causal | estimate effect, attribute, compare counterfactual | predict deployment, generalize beyond identification, explain mechanism from fit alone |
| mechanistic | model process, simulate, calibrate, explain mechanism | predict deployment, generalize beyond structural assumptions, claim causation from fit alone |

Adapt these defaults to the specific project. Add project-specific forbidden verbs based on Cycle D operationalization and Cycle E bias findings. The user approves the registry as part of finalization.

**Narrowing rule:** Any downstream stage may add entries to `verbs_forbidden`, reduce `scope`, or tighten `generalization_limit` by appending to `narrowing_log`. No downstream stage may remove entries from `verbs_forbidden`, expand `scope`, or loosen `generalization_limit` without reopening `formulate` plus `protocol`.

1. Add `## Summary` to `01_formulation.md` with:
   - approved question
   - question type and justification
   - target quantity or estimand
   - claim boundary
   - route candidates
   - unit of analysis
   - target population or deployment context, if applicable
   - operationalization table (reference Cycle D, do not duplicate the full table if already present in the Decision Log)
   - key assumptions
   - assumptions still weakly supported or contested
   - baseline, error type costs (including which errors are unacceptable), and minimum useful uplift
   - prior-art implications for scope or project order
   - what business or scientific decision the question is meant to support
   - what success looks like in substantive terms
   - if inferential or causal: hypothesis structure, or an explicit note that it is not needed

   The Summary is a synthesis for quick reference, not a copy of the Decision Log. Do not repeat cycle content verbatim. Where a cycle already documents something in full detail (e.g., operationalization, research findings), the Summary should reference the cycle entry rather than duplicating it.

2. Add `## Protocol Handoff` to `01_formulation.md` with:
   - recommended data-usage considerations
   - leakage-relevant facts, candidate forbidden-variable classes, and unresolved leakage risks
   - whether future unseen-data validation seems relevant, and why
   - whether confounding or identification is likely central
   - whether time ordering matters
   - whether grouping or hierarchy matters
   - whether monitoring or refresh context matters
   - whether route family seems stable or still uncertain
   - data collection and generalizability risks
   - unresolved protocol questions
   - what future validation may be needed at a high level
   - whether the current framing is already useful or still needs revision
   - whether prior art changes scope, assumptions, or project order
   - whether any hypothesis structure should be carried forward for inferential or causal work

3. Update `README.md`:
   ```markdown
   ## Formulate [COMPLETE]
   Type: {question type}
   Question: {final approved question}
   Data: {source description}
   Protocol handoff: {one-line summary of the main data-usage or validation considerations}
   Next: Protocol - Project rules of the game
   ```

4. Read `README.md` and quote the `## Formulate [COMPLETE]` block verbatim in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete — return to the README-update step. Only then tell the user the formulate stage is complete.

## Dependency Notes

- `protocol` is the mandatory next stage.
- `formulate` defines the question. `protocol` defines how that question may be answered.
- Do not create `data/splits/`, `split_data.py`, or any other frozen partition artifacts here.
- Do not tell later stages to use only a training set by default. Data visibility rules are decided in `protocol`.
- `clean` and `examine` require both `formulate` and `protocol`.
- `analyze` depends on the approved outputs of `formulate`, `protocol`, `clean`, and `examine`.
- Route candidates belong here. Route approval, final contract lock, and route-specific execution are finalized later through `protocol` and `analyze`.
- If question type, target quantity, or claim boundary changes later, reopen both `formulate` and `protocol`.
