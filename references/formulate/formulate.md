---
name: formulate
description: Use when starting a new data analysis project. Refine a vague domain question into a precise, data-answerable question through iterative question-first cycles with format-aware dataset inspection. First stage of Skeptic.
---

# /skeptic:formulate - Problem Formulation and Data Context

IMPORTANT: Before executing, read `../core-principles.md`. `core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

A good analyst updates the question instead of forcing the original wording through unsuitable data. Expect the question to evolve as data constraints become clear. That is the formulation process working correctly.

## Stage Outputs

`formulate` writes exactly three project-side artifacts plus a README block. No notebooks. No separate metrics file. No separate claim-boundary registry file.

| Path | Role |
|------|------|
| `{scripts_dir_name}/01_formulation.py` | Single Python file containing one function per cycle (`run_cycle_a`, `run_cycle_b`, `run_cycle_c`, ...). Invoked one cycle at a time. Returns a JSON evidence packet on stdout. |
| `{docs_dir_name}/01_formulation.yaml` | Canonical stage memory. Holds the full contract, state, claim boundary, protocol handoff, cycle history, and PCS review. Created at stage start, updated at the end of every cycle. |
| `{docs_dir_name}/01_formulation.md` | Human-readable report. Rendered once at finalization from the canonical YAML. |
| `{readme_name}` | Short `## Formulate [COMPLETE]` block added at finalization. |

The canonical YAML is the single source of truth. If the rendered markdown disagrees with the YAML, the YAML wins.

## Required Inputs

| Input | Description |
|-------|-------------|
| Project name | Subfolder name under the configured `projects_root` |
| Data source(s) | Path, table, file list, or portable locator for the raw data |
| Rough domain question | What the user wants to answer with this data |

If any input is missing, use `AskUserQuestion` to collect it before proceeding.

After collecting the project name, resolve the full project path as `{projects_root}/{project-name}` and present it to the user for confirmation. The user may accept or provide an alternative path. If the user provides an alternative, use that path for this project without modifying `skeptic.yaml`. Raw data files are copied into the configured data directory, never moved from the original location.

Also ask: "Do you have any documentation for this data (codebook, README, data dictionary, collection notes)?" If yes, copy it into the configured data directory and read it before Cycle A. Documentation materially changes how variables, units, collection logic, and biases are interpreted.

## Canonical YAML Schema

`01_formulation.yaml` is the stage's memory. The model initializes it in Cycle A and extends it at the end of every cycle. The script never writes to this file.

Write only fields that apply to the project. Omit fields that would be null; readers treat a missing key as "not applicable." The schema below names every possible field; a concrete project will populate a subset.

```yaml
stage: formulate
schema_version: 3

project:
  name:
  data_sources: []
  rough_question:
  started_at:                       # ISO date

status:
  current_cycle:                    # A|B|C|D|E|F1|F2|null
  completed_cycles: []
  stage_locked: false
  locked_at: null                   # set at stage close

provenance:                         # immutable audit facts only
  file_hashes: {}                   # {filename: sha256}
  encoding: {}                      # {filename: detected_encoding}

contract:
  approved_question:
  question_type:                    # descriptive|exploratory|inferential|predictive|causal|mechanistic
  target_quantity:
  unit_of_analysis:
  audience:
  decision_context:
    mode:                           # stakeholder | academic
    # when mode == stakeholder:
    stakeholder:
    actions: []
    how_answer_changes_action:
    # when mode == academic:
    prior:
    evidence_threshold:
  route_candidates: []              # ordered, best first
  baseline:
  minimum_uplift:
  error_costs: {}                   # {error_type: {cost, unacceptable: bool}}
  key_assumptions: []
  operationalization: {}            # {term: {chosen, rationale, rejected_alternatives: []}}
  derived_metrics: {}               # {name: formula}
  intended_uses: []
  prohibited_uses: []
  # Optional (include only when populated):
  # target_population:              # include when target population is central to the question
  # hypothesis:                     # required for inferential and causal: {null, alt, treatment, outcome}

claim_boundary:
  claim_type:
  scope:
  evidence_ceiling:
  generalization_limit:
  narrowing_log: []                 # appended by downstream stages only
  # Optional (include only when the project diverges from the question-type defaults):
  # verbs_forbidden_added: []       # project-specific verbs to add on top of the default-forbidden list
  # verbs_allowed_added: []         # rare; project-specific verbs to re-allow
  # Default verbs_allowed / verbs_forbidden are implied by claim_type. See the claim-boundary
  # defaults table in the Finalization section. Do NOT serialize the defaults into this file.

protocol_handoff:
  data_usage_considerations: []     # include collection purpose, sampling frame, upstream exclusions,
                                    # and structural notes (confounding / time-ordering / grouping /
                                    # monitoring) as separate bullets when relevant
  leakage_risks: []
  forbidden_variable_candidates: []
  validation_needs: []
  route_family_stability:
  generalizability_risks: []
  open_questions: []

cycle_history: []                   # append-only list, one entry per iteration
pcs_review: null                    # set at stage close
```

Each `cycle_history` entry:

```yaml
- cycle:                            # A|B|C|D|E|F1|...
  iteration:                        # 1-based per cycle letter
  checklist_complete: true          # false when any checklist item could not be answered
  script_evidence: {}               # the JSON object captured from the script's stdout
  subagents:
    research_verbatim:              # preserved with inline source URLs
    evaluation_verbatim:            # preserved; contains per-gate reasoning
    evaluation_verdict:             # PASS|FAIL
    blocking_failures:              # int (blocking defects + non-diagnostic gate failures)
  decision:                         # pass|iterate|acknowledge_gap|data_insufficient|reformulate|archive
  # Optional (include only when applicable):
  # unanswered: [A03, A05]          # required when checklist_complete is false
  # decision_reason:                # required when decision != pass
  # override:                       # {reason, gate} when a FAIL was overridden; omit otherwise
```

Gate-level detail lives inside `subagents.evaluation_verbatim`. Do not re-serialize gate verdicts in the cycle_history entry; `evaluation_verdict` plus `blocking_failures` carry the enforceable summary.

`pcs_review` when set:

```yaml
pcs_review:
  verbatim:
  disposition:                      # satisfied|valid_concern|disagree_override
  disposition_reason:
```

Rules:
- The YAML must parse with a standard YAML loader after every write.
- `cycle_history` is append-only. Superseded iterations stay in the list; new iterations append.
- Only downstream stages append to `claim_boundary.narrowing_log`. `formulate` must not write to it after stage close.
- Write only fields that apply. Do not pre-fill optional fields with `null` or empty containers just because the schema shows them.
- Use only ASCII characters in generated YAML content. Replace em dashes with `--`, curly quotes with straight quotes. Source-data strings may keep non-ASCII when the encoding is declared.

## Cycle Structure

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Setup + Data Overview | Yes |
| B | Data Understanding | Yes |
| C | Question Type Classification | Yes |
| D | Operationalization | Yes |
| E | Collection and Biases | Yes |
| F1, F2, ... | Follow-ups | Conditional |

Do not skip A through E. Do not collapse them into one pass.

## Per-cycle Reference Files

Before running cycle X, load only `cycles/{X}.yaml`. Each cycle YAML carries:

- `upstream`: which canonical-YAML fields must be set before the cycle starts
- `setup_side_effects`: one-time actions for Cycle A only
- `checklist`: question IDs that the script evidence must answer
- `gates`: verifiable conditions with `depends_on` checklist IDs
- `research_questions`: topics for the research subagent
- `script_contract`: keys the script's JSON evidence must contain
- `contract_writes`: which canonical-YAML fields this cycle populates
- `guidance`: short, cycle-specific judgment rules
- `step4_additions`, `pcs_checkpoint`, `log_extension`: present only when the cycle adds a specific discipline

The stage entry (this file) is read once at stage start. Per-cycle files are loaded one at a time as each cycle runs. Do not re-read the full stage entry between cycles.

Follow-up cycles use `cycles/F_template.yaml` as a starting shape. Materialize the concrete Fn spec inside the canonical YAML (not as a new file on disk) when a follow-up is opened.

## Cycle Protocol

This protocol applies to every cycle, mandatory or follow-up.

### Step 1: Setup and Execution

1. Read `cycles/{cycle}.yaml`.
2. Recover prior stage state:
   - Cycle A: no prior state to recover.
   - First cycle entered in a fresh session (not Cycle A), or first cycle after a backtrack reopens the stage: read `01_formulation.yaml` once to load the contract, claim boundary, protocol handoff, and prior `cycle_history`.
   - Every other case (continuing the same chat session): do not re-read `01_formulation.yaml`. The model just wrote it; its content is already in context.
3. Cycle A only: create the project folder structure, copy raw data and documentation into the data directory, initialize `01_formulation.yaml` with `stage`, `schema_version`, `project`, and `status.current_cycle: A`, and create `01_formulation.py` with the shape specified below.
4. Every cycle: extend `01_formulation.py` by writing or updating the cycle's function (`run_cycle_a`, `run_cycle_b`, ...). The function must produce the `script_contract.evidence_keys` listed in the cycle YAML.
5. Run `python {scripts_dir_name}/01_formulation.py --cycle {cycle}`. Capture stdout.
6. Parse stdout as JSON. That dictionary becomes the candidate `script_evidence` for this cycle iteration.
7. Scan stderr and stdout for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing. Functions that intentionally demonstrate failure must be explicitly flagged with a `# expected_failure` comment.

Script shape: one `run_cycle_*` function per cycle, a `load_state()` helper that reads `01_formulation.yaml`, an `argparse --cycle X` CLI, and a `main()` that prints exactly one JSON object to stdout. Claude writes the file from scratch in Cycle A and extends it with a new function at the start of every subsequent cycle.

Script rules:
- The script prints exactly one JSON object to stdout. Nothing else on stdout.
- The script does not write to `01_formulation.yaml`. Only the model writes the canonical YAML.
- Heavy data (arrays, full DataFrames) is summarized, not dumped. Evidence packets stay compact.
- Seeds are set inside the function if any stochastic step runs.

### Step 2: Human Review

- Interactive mode: present the script evidence inline, concisely. The user asks questions or raises concerns. Respond before proceeding.
- Auto mode: apply the self-review loop from `../auto-mode.md`. Self-correct within the configured budget, then proceed unless an escalation trigger fires.

### Step 3: Subagent Review

Dispatch two subagents in parallel.

Research subagent:

```text
Agent(
  model="{subagent_model}",
  description="Domain research for Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a domain research assistant for a data science project.

  Context: the project is about "{rough question}" using data with these characteristics:
  {compact summary of script_evidence for this cycle}

  User observations: {user's questions or observations, if any}

  Answer these research questions for Cycle {X} ({cycle focus}):
  {research_questions list from the cycle YAML}

  Return concise findings with sources. Every citation must include its URL inline
  after the claim it supports. Organize findings by question. Focus on facts that
  materially change formulation, protocol handoff, or claim boundaries.
  """
)
```

Evaluation subagent:

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a data science formulation cycle.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/01_formulation.py

  Cycle focus: {cycle focus description}
  Cycle YAML for reference: {cycles/{X}.yaml full content}
  Script evidence produced this iteration: {the candidate script_evidence}
  User observations: {user's questions or observations, if any}

  Before evaluating gates, verify that every checklist item for this cycle was
  answered with evidence in the script output. If any item was not answered,
  the gates that depend on it auto-fail.

  Produce this structured output, in order, with these exact section headings:

  EVALUATION: Cycle {X} - {focus}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Actively falsify each gate and checklist
  answer rather than confirm them. For each gate marked PASS, state the
  specific failure mode you tested and ruled out. Categories: unstated
  assumptions, missing edge cases, unverifiable criteria, logical gaps between
  goal and method, vague or unoperationalized terms, protocol-relevant omissions.
  If after genuinely adversarial scrutiny you find zero defects, state
  "No defects found" and name at least three specific failure modes you
  tested and ruled out. Do not fabricate defects.
  - Defect 1: [description with evidence]
  - Defect 2: [description with evidence]

  SEVERITY CLASSIFICATION:
  - Defect 1: BLOCKING | NON-BLOCKING - [one-line reason]
  - Defect 2: BLOCKING | NON-BLOCKING - [one-line reason]

  GATE ASSESSMENTS (use gate IDs from the cycle YAML; list every gate, not only failures):
  - {gate_id}: PASS | FAIL - [evidence]

  ALTERNATIVES CONSIDERED:
  - Current approach: [description] - Score: [1-10] - [justification]
  - Alt 1: [different framing] - Score: [1-10] - [justification]
  - Alt 2: [different framing] - Score: [1-10] - [justification]

  GAPS REMAINING: [list, or "none"]
  PROTOCOL IMPLICATIONS: [facts this cycle surfaced for `protocol`, or "none"]
  RECOMMENDED FOLLOW-UP CYCLE: [topic and why, or "none"]

  VERDICT:
  PASS = zero BLOCKING defects and zero FAIL gates.
  FAIL = one or more BLOCKING defects or FAIL gates.
  Verdict: [PASS | FAIL]
  Blocking defects: [count]
  Failed gates: [count]

  Be objective. Not harsh, not lenient.
  """
)
```

Both outputs are preserved verbatim. The model parses exactly three values from the evaluation output: the `Verdict` line, the `Blocking defects` count, and the `Failed gates` count. `blocking_failures = blocking_defects + failed_gates`.

### Step 4: Decision

When both subagents return:

1. Verify each result is non-empty and contains its required sections. If malformed, escalate to the user (interactive) or follow `../auto-mode.md` (auto).
2. Parse `Verdict`, `Blocking defects`, `Failed gates`.
3. Compute `blocking_failures`.
4. Apply the decision matrix.

Decision matrix:

| blocking_failures | forward actions allowed |
|-------------------|------------------------|
| 0 | pass, iterate |
| > 0 | iterate, acknowledge_gap (with written justification) |

Always available regardless of `blocking_failures`:
- `iterate` -> extend the cycle's function with new checks, rerun Step 1
- `data_insufficient` -> log why and present options (request more data, reformulate, archive)
- `reformulate` -> pivot to a question the data can support
- `archive` -> stop with documentation of why
- `override` -> user states the specific reason a FAIL is incorrect; logged as `override: {reason, gate}`; forward actions unlock

Interactive mode: present the synthesized assessment and the allowed actions via `AskUserQuestion`. Do not invoke any other tool until the user answers.

Auto mode: apply the autonomous decision protocol from `../auto-mode.md`.

Do not fabricate findings or force optimistic assessments to keep the process moving. If the data cannot answer the cycle's question, choose `data_insufficient`, `reformulate`, or `archive`.

### Step 5: Log

Append one entry to `cycle_history`. Required fields:

- `cycle`, `iteration`
- `checklist_complete` (bool)
- `script_evidence` (the full JSON captured in Step 1)
- `subagents.research_verbatim`, `subagents.evaluation_verbatim`, `subagents.evaluation_verdict`, `subagents.blocking_failures`
- `decision`

Write conditional fields only when they apply:

- `unanswered`: list of checklist IDs that could not be answered. Required when `checklist_complete: false`.
- `decision_reason`: required when `decision != pass`.
- `override`: `{reason, gate}` only when a FAIL was overridden.

Do not re-serialize gate verdicts. Gate-level detail lives in `evaluation_verbatim`; `evaluation_verdict` plus `blocking_failures` are the enforceable summary.

Update every canonical-YAML field listed in the cycle YAML's `contract_writes`, but only for fields this project actually populates. Leave non-applicable optional fields out entirely rather than setting them to null. Cycle-specific additions (`step4_additions`, `pcs_checkpoint`) are applied at this point if the cycle YAML defines them.

Set `status.current_cycle` to the next cycle letter (or keep for another iteration). Append the closed cycle letter to `status.completed_cycles` only when the cycle passes or is closed by override.

Re-parse `01_formulation.yaml` to confirm validity.

## Ending the Cycle Loop

The loop ends when all of the following hold:

- every mandatory cycle (A through E) has a closing `decision` of `pass` or an `override`
- every approved follow-up cycle is resolved
- interactive mode: the user explicitly approves the final contract, claim boundary, and protocol handoff
- auto mode: the stage approval gate in `../auto-mode.md` completes

Do not close the loop because it "seems good enough." Finalization requires explicit stage-close discipline.

## PCS Subagent Review

At stage close:

```text
Agent(
  model="{subagent_model}",
  description="PCS review of formulate stage",
  prompt="""
  You are a PCS reviewer for a data science project.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/01_formulation.py

  Evaluate whether this formulation adequately supports the downstream `protocol`
  and `analyze` stages.

  PREDICTABILITY:
  - Does the approved question match the reality the project needs to address?
  - Are future validation needs framed at the right level without forcing one template?
  - Are target population or deployment-context mismatches surfaced?

  STABILITY:
  - Could a different but still reasonable question formulation materially change the allowed claim?
  - Could a different but still reasonable operationalization materially change the route candidates or target quantity?
  - Are key assumptions explicit, or is the formulation hiding them?

  COMPUTABILITY:
  - Are variables, units, target quantity, and claim boundary documented clearly enough for downstream execution?
  - Are unresolved protocol questions explicit?
  - Is the audit trail strong enough that another analyst could understand why this formulation was approved?

  For each lens, state what holds up well, what is uncertain or risky, and any
  specific recommendations. Keep it concise.
  """
)
```

Store the full output in `pcs_review.verbatim`.

- Interactive mode: present via `AskUserQuestion` with options `satisfied`, `valid_concern`, `disagree_override`. Do not invoke any other tool until the user answers.
- Auto mode: apply `../auto-mode.md` stage-close rules.

Record the chosen disposition and reason in `pcs_review.disposition` and `pcs_review.disposition_reason`.

The subagent advises. It does not silently widen scope or bypass a blocking concern.

## Finalization

After the PCS review clears or the user overrides it:

1. Finalize `claim_boundary`: set `scope`, `evidence_ceiling`, and `generalization_limit` from Cycle D and Cycle E evidence. Add project-specific verb overrides under `verbs_forbidden_added` (and, rarely, `verbs_allowed_added`) when Cycle D operationalization tradeoffs or Cycle E bias findings demand narrowing beyond the defaults. The default verb lists implied by `claim_type` are the table below; downstream stages derive the effective verb set from `claim_type` + the `*_added` overrides. Do not serialize the defaults into the canonical YAML.

   | question_type | verbs_allowed (defaults) | verbs_forbidden (defaults) |
   |---------------|--------------------------|----------------------------|
   | descriptive   | describe, summarize, compare, report, characterize, count | predict, cause, explain, generalize, infer, recommend |
   | exploratory   | explore, surface, suggest, hypothesize, identify candidates | confirm, prove, establish, demonstrate, predict, cause |
   | inferential   | estimate, generalize, quantify, test, infer | cause, predict deployment, explain mechanism, recommend treatment |
   | predictive    | predict, forecast, classify, score, rank | cause, explain, attribute, identify mechanism |
   | causal        | estimate effect, attribute, compare counterfactual | predict deployment, generalize beyond identification, explain mechanism from fit alone |
   | mechanistic   | model process, simulate, calibrate, explain mechanism | predict deployment, generalize beyond structural assumptions, claim causation from fit alone |

2. Parse `01_formulation.yaml` with a standard YAML loader. Repair if parsing fails.

3. Render `01_formulation.md` from the canonical YAML. Keep the report compact: one `##` section per top-level YAML key that is populated (`Approved Question`, `Decision Context`, `Operationalization`, `Route Candidates`, `Baseline / Uplift / Error Costs`, `Key Assumptions`, `Claim Boundary` with effective verbs derived from `claim_type` + overrides, `Intended and Prohibited Uses`, `Provenance`, `Protocol Handoff`, `Cycle Summary` with one line per cycle, `PCS Assessment`). Omit sections whose YAML keys are empty or absent. Do not re-embed subagent verbatims; they already live in the YAML.

4. Update `README.md` with:

   ```markdown
   ## Formulate [COMPLETE]
   Type: {question_type}
   Question: {approved_question}
   Data: {data source description}
   Protocol handoff: {one-line summary of the main data-usage or validation considerations}
   Next: Protocol - Project rules of the game
   ```

5. Set `status.stage_locked: true` and `status.locked_at: {ISO timestamp}`. Re-parse the YAML to confirm validity.

6. Read `README.md` and quote the `## Formulate [COMPLETE]` block verbatim in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete; return to step 4. Only then tell the user the formulate stage is complete.

## Backtracking

If a downstream stage reopens `formulate`:

- Preserve every entry in `cycle_history`. Append new iterations; do not edit old ones.
- Unlock the stage: `status.stage_locked: false`, `status.locked_at: null`.
- Re-run the affected cycles and re-render the markdown at the end.
- Downstream narrowing entries already written to `claim_boundary.narrowing_log` remain in place.
