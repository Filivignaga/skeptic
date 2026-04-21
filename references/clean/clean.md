---
name: clean
description: Use after formulate and protocol to build an auditable cleaning pipeline under protocol-defined data visibility, without widening the claim boundary or assuming predictive workflow defaults. Third stage of Skeptic.
---

# /skeptic:clean - Data Cleaning and Preprocessing

IMPORTANT: Before executing, read `../core-principles.md`. `core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

Cleaning produces an auditable, reproducible data pipeline that preserves measurement meaning and supports the approved question inside the approved protocol. Fix structural and value problems, make semantic contracts explicit, document judgment calls, preserve or clarify the analyzable population, and prepare trustworthy inputs for later stages. When convenience conflicts with meaning, choose meaning.

Route files may narrow or prohibit cleaning, preprocessing, or derived-variable actions. They may not widen this stage-core, the approved formulation, or the protocol contract.

## Stage Outputs

`clean` writes exactly three project-side artifacts plus a README block. The stage script grows two reusable helpers (`clean_data` and `preprocess_data`) during Cycle R. Constraint specs and cleaned outputs are optional companions.

| Path | Role |
|------|------|
| `{scripts_dir_name}/03_cleaning.py` | Single Python file. One `run_cycle_*` function per cycle, plus `clean_data(...)` and `preprocess_data(...)` helpers added during Cycle R. Invoked one cycle at a time: `python 03_cleaning.py --cycle X`. Returns a JSON evidence packet on stdout. |
| `{docs_dir_name}/03_cleaning.yaml` | Canonical stage memory. Data contract, visibility set, cleaning and preprocessing decisions, row-count reconciliation, dataset fitness reviews, reproducibility and robustness outputs, cycle history, and PCS review. Created at stage start, updated at the end of every cycle. |
| `{docs_dir_name}/03_cleaning.md` | Human-readable report. Rendered once at finalization from the canonical YAML. |
| `{readme_name}` | Short `## Clean [COMPLETE]` block added at finalization. |

Optional companion artifacts (written during Cycle R or beyond):

| Path | Role |
|------|------|
| `{scripts_dir_name}/clean_constraints.json` | Declared and derived constraints produced by `clean_data`. See `../constraint-spec.md`. |
| `{scripts_dir_name}/preprocess_constraints.json` | Declared and derived constraints produced by `preprocess_data` when Cycle E or F ran. Otherwise an explicit no-additional-constraints file. |
| `{data_dir_name}/silver/` | Cleaned outputs when they differ from raw inputs. Each artifact has a documented schema and known limitations. |

The canonical YAML is the single source of truth. If the rendered markdown disagrees with the YAML, the YAML wins.

## Required Inputs

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` with completed `formulate` and `protocol` stages |

`clean` reads:

- `{docs_dir_name}/01_formulation.yaml` and `01_formulation.md` -- approved question, question type, target quantity, claim boundary, operationalization, unit of analysis, key assumptions, protocol handoff
- `{docs_dir_name}/02_protocol.yaml` and `02_protocol.md` -- active route, data usage mode, visibility rules, frozen artifacts, leakage rules, forbidden variable classes, clean prohibitions, validation logic, backtracking triggers
- Raw files under `{data_dir_name}/`
- Protocol-defined artifacts under `{data_dir_name}/` or a path named in `02_protocol.yaml`
- `{readme_name}` -- confirms prior stage completion

If upstream outputs are incomplete, contradictory, or missing required restrictions, stop and repair the upstream stage rather than inventing cleaning permissions around the gap.

## Canonical YAML Schema

`03_cleaning.yaml` is the stage's memory. The model initializes it in Cycle A and extends it at the end of every cycle. The script never writes to this file.

Write only fields that apply to the project. Omit fields that would be null; readers treat a missing key as "not applicable." The schema below names every possible field; a concrete project will populate a subset.

```yaml
stage: clean
schema_version: 3

project:
  name:
  started_at:                       # ISO timestamp

status:
  current_cycle:                    # A|B|C|D1|...|E|F|G1|...|R|S|null
  completed_cycles: []
  skipped_cycles: {}                # {cycle_letter: reason} for conditional cycles (e.g., F)
  locked_at: null                   # set at stage close; presence = locked

route:
  active:                           # descriptive|exploratory|inferential|predictive|causal|mechanistic
  route_file:                       # references/routes/{active}/clean.md

upstream_snapshot:                  # facts read from 01_formulation.yaml and 02_protocol.yaml
  approved_question:
  question_type:
  target_quantity:
  claim_boundary: {}                # compact copy: claim_type, scope, evidence_ceiling, generalization_limit
  operationalization: {}
  unit_of_analysis:
  key_assumptions: []
  data_usage_mode:
  leakage_rules: []
  forbidden_variable_classes: []
  clean_prohibitions: []
  validation_logic_reserved: []
  backtracking_triggers: []
  protocol_required_artifacts: []

precondition_check:
  formulation_sections_present: []
  protocol_sections_present: []
  readme_present:
  raw_hash_verification: {}         # {filename: {expected, observed, match}}
  required_artifacts_present: {}    # {artifact: true|false|missing_reason}

visibility:
  visible_raw_files: []
  visible_protocol_artifacts: []
  restricted_artifacts: []
  access_levels: {}                 # {artifact: allowed_operations}

data_contract:
  raw_artifacts: []
  cleaned_artifacts: []
  tidy_rules: []
  codebook_location:
  codebook_contents: []             # variable definitions, units, allowed values, missing/censored codes, observational-unit notes
  missing_vs_censored_rule:
  raw_to_clean_recipe:
  structural_conventions: []

question_critical_variables: []     # [{term, operationalization, columns_or_artifacts, rationale}]

cleaning_decisions: []              # [{cycle, issue, policy, rationale, rationale_source, alternatives, reversibility, population_shift, claim_consequence, code_reference}]
preprocessing_decisions: []         # same shape, plus fit_scope
derived_variables: []               # [{name, formula, stage_core_class, rationale, meaning, missingness, distribution, interpretation_risk}]

row_count_reconciliation:           # populated once Cycle C resolves material row actions
  raw_rows:
  exclusions: []                    # [{reason, rows_removed}]
  cleaned_rows:

dataset_fitness_reviews: []         # [{at_cycle, still_fit, new_data_required, question_still_appropriate, protocol_mismatch, formulation_mismatch, notes}]

reproducibility:                    # populated in Cycle R
  clean_data_signature:
  preprocess_data_signature:
  snapshot_match:                   # {clean_match: bool, preprocess_match: bool_or_null, mismatch_examples}
  constraint_files: []
  clean_constraints: {}             # {declared_error_passed, declared_error_total, declared_warn_passed, declared_warn_total, derived_info_count}
  preprocess_constraints: {}

robustness:                         # populated in Cycle S
  instability_thresholds: {}
  transfer_diagnostics_status:      # pass|flagged|skipped
  transfer_diagnostics_reason:
  layer1_perturbations: []
  layer2_performed:                 # bool
  unstable_variables: []
  risk_driving_judgment_calls: []
  summary:

claim_boundary_updates:
  narrowing_log: []                 # appended only while clean is still open

cycle_history: []                   # append-only list, one entry per iteration
pcs_review: null                    # set at stage close
```

Each `cycle_history` entry:

```yaml
- cycle:                            # A|B|C|D1|...|E|F|G1|...|R|S
  iteration:                        # 1-based per cycle letter
  unanswered: []                    # checklist IDs not answered; empty = all answered
  script_evidence: {}               # JSON captured from script stdout
  subagents:
    research_verbatim:              # preserved with inline source URLs
    evaluation_verbatim:            # preserved; contains per-gate reasoning
    blocking_failures:              # int (0 = PASS, >0 = FAIL)
  decision:                         # pass|iterate|acknowledge_gap|data_insufficient|reopen_protocol|reopen_formulate|archive
  # Optional: user_observations (captured in Step 2 when ambiguities required user input); decision_reason (required when decision != pass); override: {reason, gate} when a FAIL was overridden.
```

Gate-level detail lives inside `subagents.evaluation_verbatim`. Do not re-serialize gate verdicts in the cycle_history entry; `blocking_failures` (0 = PASS, >0 = FAIL) is the enforceable summary.

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
- `claim_boundary_updates.narrowing_log` is appended only while `clean` is still open.
- Write only fields that apply.
- Use only ASCII characters in generated YAML content. Replace em dashes with `--`, curly quotes with straight quotes. Source-data strings may keep non-ASCII when the encoding is declared.

## Cycle Structure

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Structural audit | Yes |
| B | Integrity diagnostics | Yes |
| C | Cleaning resolution | Yes |
| D1, D2, ... | Cleaning follow-ups | Conditional |
| E | Preprocessing | Yes |
| F | Derived variables and related downstream-safe transforms | Conditional |
| G1, G2, ... | Preprocessing and derived-variable follow-ups | Conditional |
| R | Reproducibility | Yes |
| S | Stability and transfer diagnostics | Yes |

Cycle F runs only when derived variables or similarly downstream-safe transformations are justified by the approved question and protocol. Skipping F must be recorded in `status.skipped_cycles`. Cycles E, F, and G+ may force a new D-series follow-up if a representation decision turns out to be an unresolved cleaning issue.

## Per-cycle Reference Files

Before running cycle X, load only `cycles/{X}.yaml`. Each cycle YAML carries:

- `upstream`: canonical-YAML fields that must be set before the cycle starts
- `setup_side_effects`: one-time actions the cycle performs in Step 1 (Cycle A initializes the stage; Cycle R and S extend the script with helpers)
- `checklist`: the items the cycle must answer. Each item has:
  - `id`: e.g. `A01`
  - `question`: the question text
  - `evidence_key`: the JSON key the script produces for this item (or `null` if judgment-driven)
  - `writes_to`: the canonical-YAML field (or list of fields) this item populates (or `null` if the item only feeds gates)
  - `skip_when`: only present when the item can be skipped under a specific condition; absent means "never skip"
- `gates`: verifiable conditions. Each gate has:
  - `id`: for a single-dep gate, the dep is encoded as a prefix (e.g. `A01-visibility` depends on A01); for a multi-dep gate, use a short name (e.g. `A-structure-audited`) and list `depends_on`
  - `depends_on`: present only for multi-dep gates
  - `condition`: what it verifies
- `research_questions`: topics for the research subagent
- `guidance`: short, cycle-specific judgment rules
- `step4_additions`, `pcs_checkpoint`, `log_extension`: present only when the cycle adds a specific discipline

The stage entry (this file) is read once at stage start. Per-cycle files are loaded one at a time as each cycle runs.

Follow-up cycles use `cycles/D_template.yaml` (cleaning follow-ups) or `cycles/G_template.yaml` (preprocessing and derived-variable follow-ups) as a starting shape. Materialize the concrete Dn or Gn spec inside the canonical YAML (not as a new file on disk) when a follow-up is opened. Every follow-up must define at least one checklist item and one gate with the enforceable exit condition.

## Cycle Protocol

This protocol applies to every cycle, mandatory or follow-up.

### Step 1: Setup and Execution

1. Read `cycles/{cycle}.yaml`.
2. Recover prior stage state:
   - Cycle A: no prior `03_cleaning.yaml` exists yet.
   - First cycle entered in a fresh session (not Cycle A), or first cycle after a backtrack reopens the stage: read `03_cleaning.yaml` once to load the data contract, visibility set, cleaning and preprocessing decisions, and prior `cycle_history`. Also reread `01_formulation.yaml` and `02_protocol.yaml` for upstream facts.
   - Every other case (continuing the same chat session): skip the re-read; the canonical YAML content is already in context.
3. Cycle A only:
   - Resolve the active route from `01_formulation.yaml` plus `02_protocol.yaml`. If they contradict, or do not collapse to one route for `clean`, stop and reopen `protocol`.
   - Load `references/routes/{route}/clean.md` once and keep it in memory for the rest of the stage. If the expected route file is missing, stop and reopen upstream.
   - Run the precondition gate: verify `01_formulation.yaml`, `02_protocol.yaml`, `{readme_name}`, at least one raw file, and every protocol-required artifact exist. Recompute SHA-256 for each raw file and compare to `provenance.files.{filename}.sha256` in `01_formulation.yaml`. Any mismatch is a blocking defect; stop until raw data is restored or formulate is reopened.
   - Verify `01_formulation.yaml` carries an approved question, question type, target quantity, claim boundary, unit of analysis, operationalization, and key assumptions. Verify `02_protocol.yaml` carries question type, active route, data usage mode, visibility rules, frozen-artifact status, leakage rules, forbidden variable classes, clean prohibitions, validation logic, and backtracking triggers. Missing or contradictory fields block the stage.
   - Derive the active visibility set and record it under `visibility`: visible raw files, visible protocol artifacts, restricted artifacts, access levels.
   - Initialize `03_cleaning.yaml` with `stage`, `schema_version`, `project` (including `project.started_at`), `status.current_cycle: A`, `route`, `upstream_snapshot`, `precondition_check`, and `visibility`. Seed `question_critical_variables` from `contract.operationalization` in `01_formulation.yaml`.
   - Create `03_cleaning.py` with the shape specified below.
4. Every cycle after A: confirm the route context still resolves to the same route. If the route context becomes ambiguous, reread `01_formulation.yaml`, `02_protocol.yaml`, and the same route file before proceeding. Identify which visible artifacts the current cycle is allowed to inspect; if unclear, stop and reopen `protocol`.
5. Every cycle: extend `03_cleaning.py` by writing or updating the cycle's function (`run_cycle_a`, `run_cycle_b`, ...). The function must produce every non-null `evidence_key` named in the cycle's checklist.
6. Run `python {scripts_dir_name}/03_cleaning.py --cycle {cycle}`. Capture stdout.
7. Parse stdout as JSON. That dictionary becomes the candidate `script_evidence` for this cycle iteration.
8. Scan stderr and stdout for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing. Functions that intentionally demonstrate failure must be explicitly flagged with a `# expected_failure` comment.

Script shape: one `run_cycle_*` function per cycle, a `load_state()` helper that reads `03_cleaning.yaml` (and `01_formulation.yaml`, `02_protocol.yaml` for upstream facts), an `argparse --cycle X` CLI, and a `main()` that prints exactly one JSON object to stdout. Claude writes the file from scratch in Cycle A and extends it with a new function at the start of every subsequent cycle. Cycle R adds the `clean_data(...)` and `preprocess_data(...)` helpers plus the reproducibility validator. Cycle S adds the stability perturbation runner and the optional transfer-diagnostics runner.

Script rules:
- The script prints exactly one JSON object to stdout. Nothing else on stdout.
- The script does not write to `03_cleaning.yaml`. Only the model writes the canonical YAML.
- The script respects protocol visibility and never loads restricted artifacts.
- Heavy data (arrays, full DataFrames) is summarized, not dumped. Evidence packets stay compact.
- Seeds are set inside the function whenever stochastic steps run, and the seed is echoed into the evidence packet.

### Step 2: Human Review

Interactive mode:
1. Present the script evidence inline, concisely.
2. Scan the evidence for ambiguities, decision points the model cannot resolve alone, and research topics worth seeding into Step 3 beyond the cycle's default `research_questions`. Cleaning decisions often turn on user judgment (missingness policy, duplicate classification, population scope), so expect ambiguities in Cycles B, C, and any D-series follow-ups.
3. If at least one such item exists, dispatch `AskUserQuestion` with 1-3 questions targeting them. Otherwise proceed directly to Step 3.
4. When AskUserQuestion was dispatched, record the user's answers as `user_observations` in the pending cycle_history entry. Pass them into Step 3 subagent prompts via the `User observations:` field.

Auto mode: apply the self-review loop from `../auto-mode.md`. Self-correct within the configured budget, then proceed unless an escalation trigger fires.

### Step 3: Subagent Review

Dispatch two subagents in parallel.

Research subagent:

```text
Agent(
  model="{subagent_model}",
  description="Domain research for Clean Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a domain research assistant for a Skeptic clean cycle.

  Context:
  - Approved question: "{approved_question}"
  - Question type: {question_type}
  - Target quantity: {target_quantity}
  - Claim boundary: {claim_boundary}
  - Protocol mode: {data_usage_mode}
  - Clean-stage visibility rules: {visibility_summary}
  - Visible artifacts used in this cycle: {artifact_list}
  - Question-critical variables: {question_critical_variables}
  - Current cycle findings: {compact summary of script_evidence for this cycle}

  User observations: {cycle_history entry's user_observations from Step 2, or "none"}

  Answer these research questions for Cycle {X} ({cycle focus}):
  {research_questions list from the cycle YAML}

  Rules:
  - Stay inside the approved question and protocol.
  - Reuse prior formulate and protocol findings before researching beyond them.
  - Stay specific to the variables, artifacts, values, slices, or transformations surfaced by the script.
  - If a question does not apply, say "not applicable" and give a one-line reason.
  - Cite sources for any claim that would change a cleaning or preprocessing decision.

  Return concise findings with sources. Every citation must include its URL
  inline after the claim it supports. Organize findings by question. Focus on
  facts that materially change cleaning judgments, semantic interpretation,
  or protocol compliance.
  """
)
```

Evaluation subagent:

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Clean Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a Skeptic clean cycle.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/03_cleaning.py
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  4. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.yaml

  Cycle focus: {cycle focus description}
  Cycle YAML for reference: {cycles/{X}.yaml full content}
  Script evidence produced this iteration: {the candidate script_evidence}
  User observations: {cycle_history entry's user_observations from Step 2, or "none"}

  Active route, visibility rules, clean prohibitions, forbidden variable
  classes, and leakage rules: {summary from 02_protocol.yaml and route file}

  Produce this structured output, in order, with these exact section headings:

  EVALUATION: Cycle {X} - {focus}

  UNANSWERED CHECKLIST ITEMS (list the IDs of any checklist item that was not answered -- absence of an item's evidence_key in the script output, or absence of the corresponding judgment, counts as unanswered):
  - Unanswered: [list of IDs, or "none"]

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Actively falsify each gate and checklist
  answer rather than confirm them. For each gate marked PASS, state the
  specific failure mode you tested and ruled out. Categories: unstated
  assumptions, outcome-dependent decisions, protocol violations, claim-
  widening moves, cleaning choices that change the analyzable population
  without documentation, leakage risks, restricted-artifact misuse, silent
  drift toward model-family-specific preparation, fit-scope leakage into
  reserved artifacts.
  If after genuinely adversarial scrutiny you find zero defects, state
  "No defects found" and name at least three specific failure modes you
  tested and ruled out. Do not fabricate defects.
  - Defect 1: [description with evidence]
  - Defect 2: [description with evidence]

  SEVERITY CLASSIFICATION:
  - Defect 1: BLOCKING | NON-BLOCKING - [one-line reason]
  - Defect 2: BLOCKING | NON-BLOCKING - [one-line reason]

  GATE ASSESSMENTS (use gate IDs from the cycle YAML; list every gate, not only failures. A gate whose `depends_on` includes any unanswered item fails automatically):
  - {gate_id}: PASS | FAIL - [evidence]

  ALTERNATIVES CONSIDERED:
  - Current approach: [description] - Score: [1-10] - [justification]
  - Alt 1: [different cleaning or preprocessing choice] - Score: [1-10] - [justification]
  - Alt 2: [different cleaning or preprocessing choice] - Score: [1-10] - [justification]

  CLAIM-BOUNDARY CHECK: Verify that no cleaning or preprocessing decision
  this cycle widens `claim_boundary.scope` or loosens `generalization_limit`
  relative to the values frozen in `01_formulation.yaml`. If the cycle
  narrows the claim, state the narrowing entry that should be appended to
  `claim_boundary_updates.narrowing_log`.

  GAPS REMAINING: [list, or "none"]
  PROTOCOL IMPLICATIONS: [facts this cycle surfaced that affect downstream stages, or "none"]
  RECOMMENDED FOLLOW-UP CYCLE: [topic and whether it belongs in D-series or G-series, or "none"]

  FINAL COUNTS:
  Unanswered items: [count]
  Blocking defects: [count]
  Failed gates: [count]

  Be objective. Not harsh, not lenient.
  """
)
```

Both outputs are preserved verbatim. The model parses three counts from the evaluation output: `Unanswered items`, `Blocking defects`, `Failed gates`. `blocking_failures = unanswered + blocking_defects + failed_gates`; `blocking_failures == 0` means PASS. Every checklist item must be answered for the cycle to pass -- unanswered items feed the count directly so there is no need for a 1:1 gate per item.

### Step 4: Decision

When both subagents return:

1. Verify each result is non-empty and contains its required sections. If malformed, escalate to the user (interactive) or follow `../auto-mode.md` (auto).
2. Parse `Unanswered items`, `Blocking defects`, `Failed gates` from the evaluation output.
3. Compute `blocking_failures = unanswered + blocking_defects + failed_gates`.
4. Apply the decision matrix.

Decision matrix:

| blocking_failures | forward actions allowed |
|-------------------|------------------------|
| 0 | pass, iterate |
| > 0 | iterate, acknowledge_gap (with written justification) |

Always available regardless of `blocking_failures`:
- `iterate` -> extend the cycle's function with new checks, rerun Step 1
- `reopen_protocol` -> stop and reopen `protocol` with a written reason
- `reopen_formulate` -> stop and reopen `formulate` (then `protocol`, then return) with a written reason
- `data_insufficient` -> log why and present options (request more data, reformulate, archive)
- `archive` -> stop with documentation of why
- `override` -> user states the specific reason a FAIL is incorrect; logged as `override: {reason, gate}`; forward actions unlock

Dataset fitness checkpoint (mandatory at Cycle C close, and after any later cycle that materially changes coverage, population, question-critical variables, or visibility): answer each of these and append a record to `dataset_fitness_reviews`:
- Is the cleaned dataset still fit for the approved question?
- Is additional data now required?
- Is the approved question still appropriate for this dataset?
- Did cleaning reveal a protocol mismatch?
- Did cleaning reveal a formulation mismatch?

Any `no` or `unclear` answer must be surfaced to the user as a decision point rather than buried in gaps.

Interactive mode: present the synthesized assessment and the allowed actions via `AskUserQuestion`. Wait for the user's answer before invoking any other tool.

Auto mode: apply the autonomous decision protocol from `../auto-mode.md`.

### Step 5: Log

Append one entry to `cycle_history`. Required fields:

- `cycle`, `iteration`
- `unanswered` (list of checklist IDs that could not be answered; empty list when all were answered)
- `script_evidence` (the full JSON captured in Step 1)
- `subagents.research_verbatim`, `subagents.evaluation_verbatim`, `subagents.blocking_failures`
- `decision`

Write conditional fields only when they apply:

- `user_observations`: captured in Step 2 when AskUserQuestion elicited user input.
- `decision_reason`: required when `decision != pass`.
- `override`: `{reason, gate}` only when a FAIL was overridden.

Gate-level detail lives in `evaluation_verbatim`; `blocking_failures` (0 = PASS, >0 = FAIL) is the enforceable summary.

Update every canonical-YAML field named in a checklist item's `writes_to`, but only for fields this project actually populates. Append to list-valued fields (`cleaning_decisions`, `preprocessing_decisions`, `derived_variables`, `dataset_fitness_reviews`, `claim_boundary_updates.narrowing_log`) rather than overwriting. Leave non-applicable optional fields out entirely rather than setting them to null. Cycle-specific additions (`step4_additions`, `pcs_checkpoint`) are applied at this point if the cycle YAML defines them.

Set `status.current_cycle` to the next cycle letter (or keep for another iteration). Append the closed cycle letter to `status.completed_cycles` only when the cycle passes or is closed by override. When a conditional cycle is skipped with a logged reason, record it under `status.skipped_cycles`.

Re-parse `03_cleaning.yaml` to confirm validity.

## Ending the Cycle Loop

The loop ends when all of the following hold:

- every mandatory cycle (A, B, C, E, R, S) has a closing `decision` of `pass` or an `override`
- Cycle F is completed with `pass` or `override`, or recorded in `status.skipped_cycles` with a specific reason (e.g., "no derived variables justified by the approved question and protocol")
- every approved D-series or G-series follow-up is resolved
- the latest dataset fitness review returns no unresolved `no` or `unclear` answers
- interactive mode: the user explicitly approves the stage state before finalization
- auto mode: the stage approval gate in `../auto-mode.md` completes

Finalization requires explicit stage-close discipline. Do not finalize because the stage "seems good enough."

## PCS Subagent Review

At stage close, after Cycle R and Cycle S have produced reproducibility and robustness outputs:

```text
Agent(
  model="{subagent_model}",
  description="PCS review of clean stage",
  prompt="""
  You are a PCS reviewer for a Skeptic clean stage.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  2. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.yaml
  3. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.yaml
  4. {projects_root}/{project-name}/{scripts_dir_name}/03_cleaning.py

  Evaluate the incremental risk introduced by cleaning and preprocessing. Do
  not restate the full formulation or protocol reviews. Use the approved
  instability thresholds from `robustness.instability_thresholds`. Use
  protocol-conditioned transfer diagnostics only when
  `robustness.transfer_diagnostics_status` is `pass` or `flagged`. Treat
  failed declared-error constraints as a hard defect.

  PREDICTABILITY:
  - Does the cleaned dataset still match the reality the approved question needs?
  - Are dataset fitness reviews consistent with the approved claim boundary?
  - Did any cleaning decision quietly change the target population or deployment context?

  STABILITY:
  - Do cleaning policies match the data-generating process rather than convenience?
  - Would any single judgment call, reversed, change the analyzable population enough to alter the claim boundary?
  - Which judgment call is the main risk driver, if any?
  - Should clean reopen a D-series or G-series follow-up cycle?

  COMPUTABILITY:
  - Is every material transformation expressed in reproducible code another analyst could rerun?
  - Are the `clean_data` and `preprocess_data` signatures clear enough for downstream stages?
  - Do declared-error constraints pass on the cleaned outputs?
  - Is the audit trail strong enough that another analyst could reconstruct why each cleaning choice was made?

  For each lens, state what holds up well, what is uncertain or risky, and
  any specific recommendations. Keep it concise.
  """
)
```

Store the full output in `pcs_review.verbatim`.

- Interactive mode: present via `AskUserQuestion` with options `satisfied`, `valid_concern`, `disagree_override`. Wait for the user's answer before invoking any other tool.
- Auto mode: apply `../auto-mode.md` stage-close rules.

Record the chosen disposition and reason in `pcs_review.disposition` and `pcs_review.disposition_reason`.

The subagent advises. It does not silently widen scope or bypass a blocking concern.

## Finalization

After the PCS review clears or the user overrides it:

1. Parse `03_cleaning.yaml` with a standard YAML loader. Repair if parsing fails.

2. Render `03_cleaning.md` from the canonical YAML. Keep the report compact: one `##` section per populated top-level YAML key (`Data Contract`, `Question-Critical Variables`, `Visibility`, `Cleaning Decisions`, `Preprocessing Decisions`, `Derived Variables`, `Row Count Reconciliation`, `Dataset Fitness Reviews`, `Reproducibility`, `Robustness`, `Claim Boundary Updates`, `Cycle Summary` with one line per cycle, `PCS Assessment`). Omit sections whose YAML keys are empty or absent. Reference the subagent verbatims through the YAML; the markdown is a rendered summary.

3. Append a Cleaning Scorecard block to `03_cleaning.md`:

   ```markdown
   ### Cleaning Scorecard
   | metric | value | source |
   |--------|-------|--------|
   | Checklist items answered | {answered}/{total} | cycle_history |
   | Mandatory cycles completed | {n}/6 | status.completed_cycles |
   | Conditional Cycle F | {completed / skipped: {reason}} | status.completed_cycles or status.skipped_cycles |
   | Cleaning follow-ups (D-series) | {n} ({list topics}) | cycle_history |
   | Preprocessing follow-ups (G-series) | {n} ({list topics}) | cycle_history |
   | Total iterations (all cycles) | {n} ({cycle}: {n}, ...) | cycle_history |
   | Blocking failures total | {n across all iterations} | cycle_history.subagents.blocking_failures |
   | Blocking failures resolved by iteration | {n} | cycle_history |
   | Blocking failures resolved by override | {n} ({list reasons}) | cycle_history |
   | Snapshot match | {yes / no} | reproducibility.snapshot_match |
   | Declared-error constraints passed | {n}/{total} | reproducibility.*.constraints |
   | Declared-warn constraints passed | {n}/{total} | reproducibility.*.constraints |
   | Judgment calls total | {n} | cleaning_decisions + preprocessing_decisions |
   | Judgment calls stable under perturbation | {n}/{tested} | robustness.layer1_perturbations |
   | Transfer diagnostics | {pass / flagged / skipped: {reason}} | robustness.transfer_diagnostics_status |
   | PCS verdict | {verbatim summary} | pcs_review.verbatim |
   | PCS user decision | {satisfied / valid_concern / disagree_override: {reason}} | pcs_review.disposition |
   ```

4. Update `README.md` with:

   ```markdown
   ## Clean [COMPLETE]
   Type: {question_type}
   Protocol mode: {data_usage_mode}
   Visibility: {one-line summary of clean-stage visibility rules}
   Cleaning: {one-line summary of key cleaning decisions}
   Preprocessing: {one-line summary of applied low-regret transformations, or "none"}
   Derived variables: {one-line summary, or "none"}
   Population shift: {one-line summary, or "none"}
   Constraints: {constraint files created}
   Functions: {scripts_dir_name}/03_cleaning.py (clean_data, preprocess_data)
   Next: Examine - inspect cleaned data under protocol rules
   ```

5. Set `status.locked_at: {ISO timestamp}`. Re-parse the YAML to confirm validity.

6. Read `README.md` and quote the `## Clean [COMPLETE]` block verbatim in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete; return to step 4. Only then tell the user the clean stage is complete.

## Backtracking

If a downstream stage reopens `clean`:

- Preserve every entry in `cycle_history`. Append new iterations.
- Unlock the stage: set `status.locked_at: null`.
- Re-run the affected cycles and re-render the markdown at the end.
- If reopen is driven by a protocol mismatch, reopen `protocol` first and let its changes flow back into this stage's visibility set and prohibitions before resuming here.
- If reopen is driven by a formulation mismatch, reopen `formulate` first, then `protocol`, then return here.
- Entries already written to `claim_boundary_updates.narrowing_log` remain in place.
