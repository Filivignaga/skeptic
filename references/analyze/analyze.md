---
name: analyze
description: Use after formulate, protocol, clean, and examine to lock one executable analysis contract within upstream constraints and execute it, producing auditable outputs for route-appropriate PCS evaluation without widening the claim boundary or self-revising based on result quality.
---

# /skeptic:analyze - Analysis Contract Lock and Execution

IMPORTANT: Before executing, read `../core-principles.md`. `core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

`analyze` translates the approved question, protocol contract, cleaned data, and examination handoff into one executable analysis specification, executes only that specification, and packages the outputs for `evaluate`. It does not self-revise based on result quality. Sensitivity divergence, challenger disagreement, and result magnitude are findings for `evaluate` to adjudicate. `analyze` handles execution-viability failures only: convergence failure, degenerate output, computational infeasibility.

## Stage Outputs

`analyze` writes exactly three project-side artifacts plus a README block.

| Path | Role |
|------|------|
| `{scripts_dir_name}/05_analysis.py` | Single Python file containing one function per cycle (`run_cycle_a`, `run_cycle_b`, `run_cycle_c`, `run_cycle_d`, `run_cycle_f`, plus any `run_cycle_eN` follow-ups). Invoked one cycle at a time. Returns a JSON evidence packet on stdout. |
| `{docs_dir_name}/05_analysis.yaml` | Canonical stage memory. Holds the locked contract, assumption results, primary/sensitivity/challenger outputs, deviations, amendments, claim boundary state, evaluation handoff, reproducibility result, cycle history, and PCS review. Created at stage start, updated at the end of every cycle. |
| `{docs_dir_name}/05_analysis.md` | Human-readable report. Rendered once at finalization from the canonical YAML. |
| `{readme_name}` | Short `## Analyze [COMPLETE]` block added at finalization. |

The canonical YAML is the single source of truth. If the rendered markdown disagrees with the YAML, the YAML wins.

## Required Inputs

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` with completed `formulate`, `protocol`, `clean`, and `examine` stages |

`analyze` does not collect domain inputs directly. It reads them from upstream canonical YAMLs:

- `01_formulation.yaml`: approved question, question type, target quantity, claim boundary, route candidates, unit of analysis, decision context, key assumptions
- `02_protocol.yaml`: active route, data-usage mode, visibility rules, frozen artifacts, leakage rules, forbidden variable classes, validation logic, analyze contract-lock obligations, analyze claim limits, backtracking triggers, protocol-committed analyses
- `03_cleaning.yaml`: final visible artifact list, final variable list, population-shift summary, open questions
- `04_examination.yaml`: support registry (supported / weakly supported / unsupported), analysis handoff, analysis constraints, fragility verdicts, active-route pressure

Cycle A verifies each upstream artifact parses and contains the fields `analyze` depends on. If anything is missing, contradictory, or forces widening of the claim boundary, stop and reopen the affected upstream stage. Do not invent analysis permissions around gaps.

Cross-stage metric consistency rule: when recomputing a metric also computed in `examine` (baseline performance, prevalence rate, fold statistic), record the exact data subset and fold range used. If the recomputed value differs from `examine`'s value, record the reason explicitly. Unexplained discrepancies are a blocking defect.

## Canonical YAML Schema

`05_analysis.yaml` is the stage's memory. The model initializes it in Cycle A and extends it at the end of every cycle. The script never writes to this file.

Write only fields that apply to the project. Omit fields that would be null; readers treat a missing key as "not applicable." The schema below names every possible field; a concrete project will populate a subset.

```yaml
stage: analyze
schema_version: 1

project:
  name:
  started_at:                       # ISO date

status:
  current_cycle:                    # A|B|C|D|F|E1|E2|null
  completed_cycles: []
  locked_at: null                   # set at stage close; presence = locked
  active_route:                     # resolved at stage entry; immutable within the stage

provenance:                         # immutable audit facts only
  upstream_artifacts: {}            # {path: sha256} for 01-04 yaml and cleaned artifacts read
  visibility_set: {}                # {visible_cleaned: [], visible_protocol_created: [], restricted: [], access_level_per_artifact: {}}

contract:                           # locked in Cycle A; may be amended only under A07 policy
  estimand:
  decision_anchor:                  # {decision, candidate_actions, action_change_logic} inherited from formulate A06
  method_family:
  primary_specification: {}         # variables, functional_form, parameters, configuration
  accuracy_metric:                  # when route overlay requires
  perturbation_plan: {}             # {axes: [], types: [], scope}
  challenger_alternatives: []       # [{name, structural_difference, rationale}]
  assumption_failure_policy: {}     # {mode: backtrack_only|amendment_allowed, named_fallbacks: []}
  missing_data_rule:
  subgroup_rule:                    # when route overlay requires
  claim_boundary_as_locked: {}      # snapshot at contract lock; same or narrower than upstream
  backtracking_triggers: []
  visibility_confirmation: {}       # {used: [], restricted: []}
  examination_support_alignment: {} # {contract_field: {support_registry_entry, classification, how_addressed}}
  route_overlay_requirements: {}    # {contract_field: {requirement_or_prohibition, how_satisfied}}
  user_approval:                    # {at: ISO date, via: AskUserQuestion|auto-mode-gate}

assumptions:
  required_checks: []               # [{id, assumption, source: route_overlay|contract, check_description}]
  results: []                       # [{id, verdict: pass|marginal|fail, evidence}]
  policy_applied:                   # backtrack_only|amendment_allowed|not_triggered
  amendment: null                   # {named_fallback_invoked, what_changed, narrowing_confirmation} when amendment_allowed

primary_execution:
  contract_executed: {}             # snapshot of method/spec/visible_artifacts at execution
  outputs: {}                       # point_estimates, intervals, predictions, diagnostics, model_parameters
  computational_diagnostics: {}     # convergence_status, runtime, numerical_warnings, memory
  random_seeds: {}
  status:                           # completed|failed
  failure_details: null

sensitivity_execution:
  per_axis: []                      # [{axis, outputs, random_seeds, runtime, status, failure_details}]

challenger_execution:
  per_challenger: []                # [{name, outputs, random_seeds, runtime, status, failure_details}]

comparison_table: []                # [{quantity, primary, per_axis: {}, per_challenger: {}, material_difference: bool}]

deviations: []                      # [{what_changed, forced|chosen, cause, potential_impact, pre_registration_delta}]
contract_amendments: []             # [{trigger, what_changed, narrowing_confirmation}]

claim_boundary:                     # inherited from formulate; only narrowed here, never widened
  claim_type:                       # snapshot for clarity
  scope:
  evidence_ceiling:
  generalization_limit:
  verbs_forbidden_added: []
  verbs_allowed_added: []
  narrowing_log_additions: []       # appended by A/B/D/F when this stage narrows further

evaluation_handoff:                 # assembled in Cycle F; rendered into the markdown at finalization
  contract_summary: {}
  execution_summary: {}
  deviation_register: []
  contract_amendments: []
  flags_for_evaluate: []
  handoff_discipline: []            # ["Next stage: evaluate", "Do not treat analysis outputs as confirmed claims", ...]

reproducibility:                    # produced in Cycle F; re-executes the full pipeline from cleaned plus frozen artifacts
  status:                           # pass|fail
  match_kind:                       # exact|numerical_tolerance|mismatch
  runtime:
  tolerance_notes:
  mismatch_details:

cycle_history: []                   # append-only list, one entry per iteration
pcs_review: null                    # set at stage close
```

Each `cycle_history` entry:

```yaml
- cycle:                            # A|B|C|D|F|E1|...
  iteration:                        # 1-based per cycle letter
  unanswered: []                    # checklist IDs not answered; empty = all answered
  script_evidence: {}               # JSON captured from script stdout
  subagents:
    research_verbatim:              # preserved with inline source URLs
    evaluation_verbatim:            # preserved; contains per-gate reasoning
    blocking_failures:              # int (0 = PASS, >0 = FAIL)
  decision:                         # pass|iterate|acknowledge_gap|reopen_examine|reopen_protocol|reopen_formulate|data_insufficient|archive
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
- `claim_boundary.narrowing_log_additions` is append-only within `analyze` and is merged into formulate's `claim_boundary.narrowing_log` at finalization.
- `contract` is set in Cycle A and may be amended only under the locked `contract.assumption_failure_policy`. Every amendment appends to `contract_amendments` and narrows the claim boundary if the fallback requires it.
- Write only fields that apply.
- Use only ASCII characters in generated YAML content. Replace em dashes with `--`, curly quotes with straight quotes. Source-data strings may keep non-ASCII when the encoding is declared.

## Cycle Structure

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Contract Lock | Yes |
| B | Assumption Verification | Yes |
| C | Primary Execution | Yes |
| D | Sensitivity and Challenger Execution | Yes |
| F | Results Assembly, Reproducibility, Handoff | Yes |
| E1, E2, ... | Execution-issue Follow-ups | Conditional |

`E`-prefixed follow-ups are narrow execution-issue cycles opened only when Cycle C or Cycle D surfaces a material execution-viability problem (convergence failure, degenerate output, computational infeasibility, missing-data cascade). They are not a license for re-exploration or result-quality judgment.

## Per-cycle Reference Files

Before running cycle X, load only `cycles/{X}.yaml`. Each cycle YAML carries:

- `upstream`: canonical-YAML fields (including upstream-stage fields) that must be set before the cycle starts
- `setup_side_effects`: one-time actions (typically Cycle A only)
- `checklist`: the items the cycle must answer. Each item has:
  - `id`: e.g. `A01`
  - `question`: the question text
  - `evidence_key`: the JSON key the script produces for this item (or `null` if judgment-driven)
  - `writes_to`: the canonical-YAML field (or list of fields) this item populates (or `null` if the item only feeds gates)
  - `skip_when`: only present when the item can be skipped under a specific condition; absent means "never skip"
- `gates`: verifiable conditions. Each gate has:
  - `id`: for a single-dep gate, the dep is encoded as a prefix (e.g. `A05-axes-types-scope` depends on A05); for a multi-dep gate, use a short name (e.g. `A-method-executable`) and list `depends_on`
  - `depends_on`: present only for multi-dep gates
  - `condition`: what it verifies
- `research_questions`: topics for the research subagent
- `guidance`: short, cycle-specific judgment rules
- `step4_additions`, `pcs_checkpoint`, `log_extension`: present only when the cycle adds a specific discipline

The stage entry (this file) is read once at stage start. Per-cycle files are loaded one at a time as each cycle runs.

Follow-up cycles use `cycles/E_template.yaml` as a starting shape. Materialize the concrete En spec inside the canonical YAML (not as a new file on disk) when a follow-up is opened.

## Cycle Protocol

This protocol applies to every cycle, mandatory or follow-up.

### Step 1: Setup and Execution

1. Read `cycles/{cycle}.yaml`.
2. Recover prior stage state:
   - Cycle A: read `01_formulation.yaml`, `02_protocol.yaml`, `03_cleaning.yaml`, `04_examination.yaml` once. Confirm each parses and contains the fields `analyze` depends on. Resolve exactly one `active_route` from `01_formulation.yaml` plus `02_protocol.yaml`; if they contradict or do not collapse to one route, stop and reopen `protocol`. Load `references/routes/{active_route}/analyze.md` once and keep it in memory for the rest of the stage.
   - First cycle entered in a fresh session (not Cycle A), or first cycle after a backtrack reopens the stage: read `05_analysis.yaml` once to recover the locked contract, assumption results, execution outputs, prior `cycle_history`, and `status.active_route`; reload the same route file.
   - Every other case (continuing the same chat session): skip the re-read; the canonical YAML content is already in context from the cycle that just wrote it.
3. If the active route becomes ambiguous mid-stage, reread the four upstream canonical YAMLs and the same route file before proceeding. Do not guess.
4. Cycle A only: verify all upstream artifacts, hash each source file read into `provenance.upstream_artifacts`, derive and record `provenance.visibility_set`, initialize `05_analysis.yaml` with `stage`, `schema_version`, `project`, `status.current_cycle: A`, `status.active_route`, and create `05_analysis.py` with the shape specified below.
5. Every cycle: extend `05_analysis.py` by writing or updating the cycle's function (`run_cycle_a`, `run_cycle_b`, ...). The function must produce every non-null `evidence_key` named in the cycle's checklist.
6. Run `python {scripts_dir_name}/05_analysis.py --cycle {cycle}`. Capture stdout.
7. Parse stdout as JSON. That dictionary becomes the candidate `script_evidence` for this cycle iteration.
8. Scan stderr and stdout for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing. Functions that intentionally demonstrate failure must be explicitly flagged with a `# expected_failure` comment.

Script shape: one `run_cycle_*` function per cycle, a `load_state()` helper that reads `05_analysis.yaml`, an `argparse --cycle X` CLI, and a `main()` that prints exactly one JSON object to stdout. Claude writes the file from scratch in Cycle A and extends it with a new function at the start of every subsequent cycle. The Cycle F function contains the reproducibility re-run logic that re-executes primary, sensitivity, and challenger pipelines from cleaned artifacts plus protocol-defined frozen artifacts.

Script rules:
- The script prints exactly one JSON object to stdout. Nothing else on stdout.
- The script does not write to `05_analysis.yaml`. Only the model writes the canonical YAML.
- The script reads only artifacts inside the visibility set recorded in `provenance.visibility_set`. Touching a restricted artifact is a blocking defect.
- Heavy data (arrays, full DataFrames) is summarized, not dumped. Evidence packets stay compact.
- Seeds are set inside the function whenever stochastic steps run, and echoed into the evidence packet.

### Step 2: Human Review

Interactive mode:
1. Present the script evidence inline, concisely.
2. Scan the evidence for ambiguities, decision points the model cannot resolve alone, and research topics worth seeding into Step 3 beyond the cycle's default research_questions.
3. If at least one such item exists, dispatch `AskUserQuestion` with 1-3 questions targeting them. Otherwise proceed directly to Step 3.
4. When AskUserQuestion was dispatched, record the user's answers as `user_observations` in the pending cycle_history entry. Pass them into Step 3 subagent prompts via the `User observations:` field.

Auto mode: apply the self-review loop from `../auto-mode.md`. Self-correct within the configured budget, then proceed unless an escalation trigger fires.

### Step 3: Subagent Review

Dispatch two subagents in parallel.

Research subagent:

```text
Agent(
  model="{subagent_model}",
  description="Methodological research for Analyze Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a methodological research assistant for a Skeptic analyze stage.

  Context:
  - Approved question: "{approved question}"
  - Question type: {question type}
  - Target quantity: {target quantity}
  - Claim boundary: {claim boundary}
  - Active route: {route}
  - Protocol mode: {data_usage_mode}
  - Visibility rules: {visibility summary}
  - Examination support summary: {supported/weakly/unsupported}
  - Analysis constraints: {from examine}
  - Current cycle script evidence: {compact summary of script_evidence}
  - User observations: {cycle_history entry's user_observations from Step 2, or "none"}

  Answer these research questions for Cycle {X} ({focus}):
  {research_questions list from the cycle YAML}

  Rules:
  - Stay inside the approved question, protocol contract, and active route.
  - Focus on methodological guidance. Do not re-do domain discovery.
  - If a question does not apply, say "not applicable" with a one-line reason.
  - Every citation must include its URL inline after the claim it supports.

  Return concise findings organized by research question.
  """
)
```

Evaluation subagent:

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Analyze Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a Skeptic analyze-stage cycle.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/05_analysis.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/05_analysis.py
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  4. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.yaml
  5. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.yaml
  6. {projects_root}/{project-name}/{docs_dir_name}/04_examination.yaml

  Cycle focus: {cycle focus description}
  Cycle YAML for reference: {cycles/{X}.yaml full content}
  Script evidence produced this iteration: {the candidate script_evidence}
  User observations: {cycle_history entry's user_observations from Step 2, or "none"}

  Produce this structured output, in order, with these exact section headings:

  EVALUATION: Cycle {X} - {focus}

  UNANSWERED CHECKLIST ITEMS (list the IDs of any checklist item that was not answered -- absence of an item's evidence_key in the script output, or absence of the corresponding judgment, counts as unanswered):
  - Unanswered: [list of IDs, or "none"]

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Actively falsify each gate and checklist
  answer rather than confirm them. For each gate you mark PASS, state the
  specific failure mode you tested and ruled out. Categories to scan:
  contract drift, post-hoc analysis additions, claim-boundary widening,
  protocol violations, forbidden variable usage, unauthorized data access,
  unregistered specification changes, result-quality-driven self-revision,
  perturbation or challenger added after seeing primary results, visibility
  violations, examination-support misalignment.
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

  CLAIM BOUNDARY CHECK:
  - Locked verbs_allowed and verbs_forbidden (from claim_boundary plus any narrowing_log_additions): [summary]
  - Any language or action in this cycle that violates them: [list, or "none"]
  - Any narrowing this cycle introduced: [list, or "none"]

  ALTERNATIVES CONSIDERED:
  - Current approach: [description] - Score: [1-10] - [justification]
  - Alt 1: [different specification or challenger] - Score: [1-10] - [justification]
  - Alt 2: [different specification or challenger] - Score: [1-10] - [justification]

  CONTRACT FIDELITY (Cycles B/C/D/F only): {contract followed | drift detected | amendment needed per locked A07 policy}
  GAPS REMAINING: [list, or "none"]
  RECOMMENDED FOLLOW-UP CYCLE: [topic and why, or "none"]

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
- `reopen_examine` -> stop and reopen `examine` (support overestimated, fragility understated)
- `reopen_protocol` -> stop and reopen `protocol` (admissible method set or visibility rules too tight or too loose)
- `reopen_formulate` -> stop and reopen `formulate` plus `protocol` (question type or claim boundary needs widening)
- `reopen_clean` -> stop and reopen `clean` (structural data problem not caught earlier)
- `data_insufficient` -> log why and present options (request more data, reformulate, archive)
- `archive` -> stop with documentation of why
- `override` -> user states the specific reason a FAIL is incorrect; logged as `override: {reason, gate}`; forward actions unlock

Cycle A special rule: passing Cycle A additionally requires explicit user approval of the full locked contract. The decision matrix applies, but the model does not set `status.current_cycle: B` until that approval is recorded in `contract.user_approval`.

Interactive mode: present the synthesized assessment and the allowed actions via `AskUserQuestion`. Wait for the user's answer before invoking any other tool.

Auto mode: apply the autonomous decision protocol from `../auto-mode.md`.

All challengers producing materially different results from the primary is not a backtracking trigger. It is a finding documented in Cycle D for `evaluate` to adjudicate. `analyze` does not self-revise based on result quality.

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

Gate-level detail lives in `evaluation_verbatim`; `blocking_failures` (0 = PASS, >0 = FAIL) is the enforceable summary. The cycle_history entry stores only those two.

Update every canonical-YAML field named in a checklist item's `writes_to`, but only for fields this project actually populates. Leave non-applicable optional fields out entirely rather than setting them to null. Cycle-specific additions (`step4_additions`, `pcs_checkpoint`) are applied at this point if the cycle YAML defines them.

Set `status.current_cycle` to the next cycle letter (or keep for another iteration). Append the closed cycle letter to `status.completed_cycles` only when the cycle passes or is closed by override. The planned order is A -> B -> C -> D -> F, with any approved En follow-ups slotted before F.

Re-parse `05_analysis.yaml` to confirm validity.

## Ending the Cycle Loop

The loop ends when all of the following hold:

- every mandatory cycle (A, B, C, D, F) has a closing `decision` of `pass` or an `override`
- every approved En follow-up is resolved
- `reproducibility.status` is `pass` (produced by Cycle F)
- interactive mode: the user explicitly approves the contract (Cycle A), the deviation register, evaluation handoff, and claim boundary as-narrowed
- auto mode: the stage approval gate in `../auto-mode.md` completes

Finalization requires explicit stage-close discipline.

## PCS Subagent Review

At stage close:

```text
Agent(
  model="{subagent_model}",
  description="PCS review of analyze stage",
  prompt="""
  You are a PCS reviewer for a Skeptic analyze stage.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/05_analysis.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/05_analysis.py
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  4. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.yaml
  5. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.yaml
  6. {projects_root}/{project-name}/{docs_dir_name}/04_examination.yaml

  Evaluate only the incremental risk introduced by analysis contract lock
  and execution. Do not restate the full formulation, protocol, cleaning,
  or examination reviews.

  PREDICTABILITY:
  - Did execution produce outputs that the protocol-specified reality check
    in `evaluate` can run against?
  - Are primary and sensitivity outputs structured for comparison?
  - Are target population or deployment-context mismatches surfaced as flags?

  STABILITY:
  - Are perturbation and challenger outputs present and separated so
    `evaluate` can assess whether results survive reasonable alternatives?
  - Were perturbation axes adequate for the route?
  - Could a different but still reasonable locked contract materially change
    the allowed claim?

  COMPUTABILITY:
  - Can another analyst reproduce the full analysis from the locked contract,
    cleaned artifacts, frozen artifacts, and the analyze script?
  - Did the reproducibility re-run pass?
  - Are random seeds, parameters, and diagnostics recorded?

  CONTRACT FIDELITY:
  - Did execution follow the locked contract?
  - Are deviations and amendments documented with cause, impact, and
    narrowing confirmation?

  MAIN RISK DRIVER:
  - What single contract choice or execution choice introduced the most risk,
    if any?

  REOPEN CYCLE OR ROUTE UPSTREAM:
  - Should `analyze` reopen a cycle or route upstream? Yes or no, and why.

  For each lens, state what holds up well, what is uncertain or risky, and
  any specific recommendations. Keep it concise.
  """
)
```

Store the full output in `pcs_review.verbatim`.

- Interactive mode: present via `AskUserQuestion` with options `satisfied`, `valid_concern`, `disagree_override`. Wait for the user's answer before invoking any other tool.
- Auto mode: apply `../auto-mode.md` stage-close rules.

Record the chosen disposition and reason in `pcs_review.disposition` and `pcs_review.disposition_reason`.

The subagent advises. It does not silently widen scope, bypass a blocking concern, or revise analysis outputs based on result quality.

## Finalization

After the PCS review clears or the user overrides it:

1. Finalize `claim_boundary`: ensure the analyze-stage `narrowing_log_additions` are ordered by the cycle that introduced them (A, B, D, or F), that no entry widens `scope`, `evidence_ceiling`, `generalization_limit`, or the effective verb set, and that any added `verbs_forbidden_added` or `verbs_allowed_added` are explicit.

2. Finalize `evaluation_handoff`: confirm `contract_summary`, `execution_summary`, `deviation_register`, `contract_amendments`, `flags_for_evaluate`, and `handoff_discipline` are populated and that every protocol-committed analysis from `02_protocol.yaml` is either completed in `primary_execution` / `sensitivity_execution` / `challenger_execution` or logged under `deviations` with justification.

3. Parse `05_analysis.yaml` with a standard YAML loader. Repair if parsing fails.

4. Render `05_analysis.md` from the canonical YAML. Keep the report compact: one `##` section per top-level YAML key that is populated (`Upstream Contract`, `Locked Analysis Contract`, `Assumption Verification`, `Primary Execution`, `Sensitivity Execution`, `Challenger Execution`, `Comparison Table`, `Deviation Register`, `Contract Amendments`, `Claim Boundary As-Narrowed`, `Reproducibility`, `Evaluation Handoff`, `Cycle Summary` with one line per cycle, `PCS Assessment`). Omit sections whose YAML keys are empty or absent. Reference subagent verbatims through the YAML; the markdown is a rendered summary.

5. Update `README.md` with:

   ```markdown
   ## Analyze [COMPLETE]
   Type: {question_type}
   Active route: {route}
   Method: {method_family} -- {primary_specification one-line}
   Contract amendments: {n, or "none"}
   Deviations: {n, or "none"}
   Claim boundary: {unchanged from examine | narrowed to {one-line}}
   Perturbation axes: {n} executed
   Challengers: {n} executed
   Reproducibility: pass -- {runtime}
   Next: Evaluate - route-appropriate PCS review of outputs and claims
   ```

6. Set `status.locked_at: {ISO timestamp}`. Re-parse the YAML to confirm validity.

7. Read `README.md` and quote the `## Analyze [COMPLETE]` block verbatim in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete; return to step 5. Only then tell the user the analyze stage is complete.

## Backtracking

If a downstream stage reopens `analyze`, or an in-stage decision triggers a reopen of an upstream stage:

- Preserve every entry in `cycle_history`. Append new iterations.
- Unlock the stage: set `status.locked_at: null`.
- When reopening upstream (`reopen_examine`, `reopen_protocol`, `reopen_formulate`, `reopen_clean`): record the reason in the current cycle's `decision_reason`, write the target stage and rationale, and stop. Do not silently rewind. The upstream stage reopens under its own backtracking discipline.
- Re-run the affected cycles and re-render the markdown at the end.
- `claim_boundary.narrowing_log_additions` already written remain in place; only widening is prohibited.
- Contract amendments under the locked `contract.assumption_failure_policy` remain permitted only inside Cycle B. Post-result amendments require an explicit reopen of Cycle A with user approval.
