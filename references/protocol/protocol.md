---
name: protocol
description: Use after formulate to lock the project rules of the game before clean starts. Defines the data-usage mode, admissible evidence logic, validation requirements, stage prohibitions, and backtracking triggers through iterative question-first cycles. Second stage of Skeptic.
---

# /skeptic:protocol - Project Rules of the Game

IMPORTANT: Before executing, read `../core-principles.md`. `core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

Protocol defines how the approved question may be answered. It locks the data-usage mode, admissible evidence logic, validation requirements, stage prohibitions, and backtracking triggers. It does not choose the estimator, model family, or final analysis contract. That belongs to `analyze`.

Do not default to splits. Do not default to full-data analysis. Decide, justify, and record.

## Stage Outputs

`protocol` writes exactly three project-side artifacts plus a README block. No notebooks. No separate metrics file. No separate claim-boundary registry file.

| Path | Role |
|------|------|
| `{scripts_dir_name}/02_protocol.py` | Single Python file containing one function per cycle (`run_cycle_a`, `run_cycle_b`, `run_cycle_c`, `run_cycle_d`, ...). Invoked one cycle at a time. Returns a JSON evidence packet on stdout. Deterministically creates frozen artifacts in Cycle B when required. |
| `{docs_dir_name}/02_protocol.yaml` | Canonical stage memory. Holds the route, handoff audit, data-usage decisions, frozen-artifact manifests, evidence rules, prohibitions, backtracking triggers, cycle history, and PCS review. Created at stage start, updated at the end of every cycle. |
| `{docs_dir_name}/02_protocol.md` | Human-readable report. Rendered once at finalization from the canonical YAML. |
| `{readme_name}` | Short `## Protocol [COMPLETE]` block added at finalization. |

The canonical YAML is the single source of truth. If the rendered markdown disagrees with the YAML, the YAML wins.

Protocol may also create frozen artifacts under `{data_dir_name}/splits/` (or another path the approved mode requires) during Cycle B. These belong to `protocol`, not `clean`. Record each artifact path in `provenance.files` with its SHA-256.

## Required Inputs

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` whose `formulate` stage is complete |

No additional user input is required if `formulate` is complete. If the formulate handoff is incomplete or contradictory, stop and repair `formulate` first. `protocol` is not allowed to guess around a missing formulation.

The stage reads the following upstream artifacts (written by `formulate`):

- `{docs_dir_name}/01_formulation.yaml` -- approved question, question type, target quantity, claim boundary, route candidates, key assumptions, protocol handoff, provenance
- `{scripts_dir_name}/01_formulation.py` -- referenced as the source for formulate evidence when the evaluation subagent needs to trace a claim
- `{readme_name}` -- confirms formulate completion

## Canonical YAML Schema

`02_protocol.yaml` is the stage's memory. The model initializes it in Cycle A and extends it at the end of every cycle. The script never writes to this file.

Write only fields that apply to the project. Omit fields that would be null; readers treat a missing key as "not applicable." The schema below names every possible field; a concrete project will populate a subset.

```yaml
stage: protocol
schema_version: 3

project:
  name:
  started_at:                       # ISO date; set in Cycle A

status:
  current_cycle:                    # A|B|C|D|F1|F2|null
  completed_cycles: []
  locked_at: null                   # set at stage close; presence = locked

provenance:                         # immutable audit facts only
  files: {}                         # {filename: {sha256}} for frozen artifacts created in Cycle B

route:
  active:                           # descriptive|exploratory|inferential|predictive|causal|mechanistic
  resolution_evidence:              # short note on how the route was resolved from formulate

handoff_audit:                      # populated in Cycle A
  sections_present: {}              # {section_name: true|false} for required formulate YAML keys
  required_fields: {}               # {field_path: present|partial|missing}
  contradictions: []                # list of {issue, locations, severity}
  ambiguities: []                   # list of {issue, classification: protocol_safe|protocol_blocking|formulate_contradiction}
  minimum_decisions: []             # minimum set of decisions protocol must produce before clean can start
  confirmed:                        # snapshot extracted from formulate
    approved_question:
    question_type:
    target_quantity:
    claim_boundary_summary:
    route_candidates: []

data_usage:                         # populated in Cycle B
  mode:                             # full_data|frozen_holdout_split|temporal_split|group_split|rolling_validation|external_validation|resampling_only|cross_fitting_authorized|hybrid
  mode_comparison: []               # [{mode, fit_to_question_type, target_quantity_fit, claim_boundary_fit, time_structure_fit, grouping_fit, deployment_or_reporting_fit, main_risk}]
  full_data_assessment:             # rationale for whether full_data is a serious candidate
  rejected_alternatives: []         # [{mode, why_rejected, claim_type_unchanged: bool, top_route_unchanged: bool, narrowing_entry_if_any}]
  chosen_rationale:
  hybrid_components: []             # [{component_mode, rationale}] only when mode == hybrid
  cross_fitting_authorized:         # bool; only set when later methods may require cross-fit
  identifier_strategy:              # only when identifiers freeze visibility

frozen_artifacts:                   # populated in Cycle B
  required:                         # bool
  artifacts: []                     # [{path, deterministic_logic, seed, cutoffs, row_or_group_identifier_logic, restriction_rules, access_rules}]
  justification_if_none:

evidence_rules:                     # populated in Cycle C
  leakage:
    relevance:                      # central|possible_limited|irrelevant
    forbidden_variable_classes: []  # post_outcome, post_treatment, future_information, direct_target_proxies, label_echoes, denominator_defined_artifacts, deployment_unavailable
    project_specific_vectors: []
    rationale_if_irrelevant:        # required when relevance == irrelevant
  confounding_identification:
    centrality:                     # central|secondary|not_relevant
    rationale:
  structure:
    time_order_matters:             # bool
    grouping_hierarchy_matters:     # bool
    interference_matters:           # bool
    rationale:
  validation_logic:
    required_checks: []             # denominator_integrity, resampling_stability, holdout_scoring, temporal_backtesting, group_transfer_checks, external_corroboration, placebo_falsification, overlap_sensitivity, simulation_based_validation
    rationale:
  uncertainty:
    framing:                        # interval_estimates|calibration_uncertainty|sensitivity_bands|perturbation_ranges|simulation_envelopes|uncertainty_not_central
    rationale:

prohibitions:                       # populated in Cycle D
  downstream_major: []
  clean: []
  examine: []
  analyze_contract_lock: []
  analyze_claim_limits: []

backtracking_triggers: []           # populated in Cycle D; list of {trigger, return_path}

cycle_history: []                   # append-only list, one entry per iteration
pcs_review: null                    # set at stage close
```

Each `cycle_history` entry:

```yaml
- cycle:                            # A|B|C|D|F1|...
  iteration:                        # 1-based per cycle letter
  unanswered: []                    # checklist IDs not answered; empty = all answered
  script_evidence: {}               # compact summary only: 4-8 one-line bullets, or one-line value per evidence_key. No full JSON, no DataFrames, no arrays, no per-column schema.
  script_evidence_ref:              # relative path to {scripts_dir_name}/stdout/cycle_{cycle}_iter{iteration}.json holding the full stdout JSON
  subagents:
    research_sources: []            # [{url, claim}] -- only sources that materially shaped a decision this iteration
    decisions: []                   # [{what, why, pcs: P|C|S|null, source: int?}] -- operational choices where a reasonable alternative existed (distinct from the top-level `decision:` verdict below; `source` is an optional index into research_sources)
    rejected_alternatives: []       # [{option, reason, pcs: P|C|S|null}] -- paths considered and dropped (the PCS Stability counterfactual record)
    open_risks: []                  # [str] -- unresolved concerns downstream stages must carry forward
    blocking_failures:              # int (0 = PASS, >0 = FAIL)
  decision:                         # pass|iterate|acknowledge_gap|data_insufficient|reformulate|archive
  # Optional: user_observations (captured in Step 2 when ambiguities required user input); decision_reason (required when decision != pass); override: {reason, gate} when a FAIL was overridden.
```

Do not store subagent prose anywhere -- not in the YAML, not on disk. The main model digests both subagent replies into the `subagents` fields above; only entries that materially shaped this iteration belong there. `blocking_failures` (0 = PASS, >0 = FAIL) is the enforceable integer summary. Per-gate reasoning enters `cycle_history` only through a `decisions[*]` or `rejected_alternatives[*]` entry that a specific gate produced, never as a gate-by-gate restatement. Never add ad-hoc keys to the subagents block; if a finding has no schema home, fold it into `open_risks` or omit it.

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
- This stage may append entries to `01_formulation.yaml`'s `claim_boundary.narrowing_log` while `protocol` is still open (for example when a rejected data-usage alternative would change the claim type). Do not edit other formulate fields.
- Write only fields that apply.
- Use only ASCII characters in generated YAML content. Replace em dashes with `--`, curly quotes with straight quotes.

## Cycle Structure

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Handoff Audit from Formulate | Yes |
| B | Data-Usage Mode Decision | Yes |
| C | Evidence, Validation, and Risk Rules | Yes |
| D | Stage Prohibitions and Backtracking Triggers | Yes |
| F1, F2, ... | Follow-ups | Conditional |

## Per-cycle Reference Files

Before running cycle X, load only `cycles/{X}.yaml`. Each cycle YAML carries:

- `upstream`: canonical-YAML fields that must be set before the cycle starts
- `setup_side_effects`: one-time actions (typically Cycle A only, plus Cycle B when frozen artifacts are created)
- `checklist`: the items the cycle must answer. Each item has:
  - `id`: e.g. `A01`
  - `question`: the question text
  - `evidence_key`: the JSON key the script produces for this item (or `null` if judgment-driven)
  - `writes_to`: the canonical-YAML field (or list of fields) this item populates (or `null` if the item only feeds gates)
  - `skip_when`: only present when the item can be skipped under a specific condition; absent means "never skip"
- `gates`: verifiable conditions. Each gate has:
  - `id`: for a single-dep gate, the dep is encoded as a prefix (e.g. `B08-route-family-confirmed` depends on B08); for a multi-dep gate, use a short name (e.g. `B-modes-compared`) and list `depends_on`
  - `depends_on`: present only for multi-dep gates
  - `condition`: what it verifies
- `research_questions`: topics for the research subagent
- `mode_registry` (Cycle B only): reference list of data-usage modes with typical justifications and typical mistakes
- `route_pressure` (Cycle B and C): reference list mapping question types to protocol pressure, validation emphasis, and common non-default outcomes
- `guidance`: short, cycle-specific judgment rules
- `step4_additions`, `pcs_focus`, `log_extension`: present only when the cycle adds a specific discipline. `pcs_focus` holds cycle-specific PCS questions injected into the evaluation subagent prompt; it has no separate Step 5 application.

The stage entry (this file) is read once at stage start. Per-cycle files are loaded one at a time as each cycle runs.

Follow-up cycles use `cycles/F_template.yaml` as a starting shape. Materialize the concrete Fn spec inside the canonical YAML (not as a new file on disk) when a follow-up is opened.

## Cycle Protocol

This protocol applies to every cycle, mandatory or follow-up.

### Step 1: Setup and Execution

1. Read `cycles/{cycle}.yaml`.
2. Recover prior stage state:
   - Cycle A:
     - Read `{docs_dir_name}/01_formulation.yaml` to pull `contract`, `claim_boundary`, `protocol_handoff`, and `provenance`.
     - Resolve the active route from `contract.question_type`. Expected values: `descriptive`, `exploratory`, `inferential`, `predictive`, `causal`, `mechanistic`. If `question_type` is missing, ambiguous, or does not match one of the six values, stop and route back to `/skeptic:formulate`.
     - Load `../routes/{route}/protocol.md` once and keep it in memory for the rest of the stage. If the route file is missing, stop.
     - Initialize `{docs_dir_name}/02_protocol.yaml` with `stage`, `schema_version`, `project.name`, `project.started_at` (ISO timestamp), `status.current_cycle: A`, `route.active`, and `route.resolution_evidence`.
     - Create `{scripts_dir_name}/02_protocol.py` with the shape specified below.
   - First cycle entered in a fresh session (not Cycle A), or first cycle after a backtrack reopens the stage: read `02_protocol.yaml` and reload `../routes/{route}/protocol.md` once.
   - Every other case (continuing the same chat session): skip the re-read; the canonical YAML content and route file are already in context.
3. Every cycle: extend `02_protocol.py` by writing or updating the cycle's function (`run_cycle_a`, `run_cycle_b`, ...). The function must produce every non-null `evidence_key` named in the cycle's checklist.
4. Cycle B only, when the chosen data-usage mode requires frozen artifacts: the script deterministically creates the partition index and any other frozen files under `{data_dir_name}/splits/` (or another path the approved mode requires). The script emits each artifact path and SHA-256 in `frozen_artifact_manifest`. The model records them under `frozen_artifacts.artifacts` and `provenance.files`.
5. Run `python {scripts_dir_name}/02_protocol.py --cycle {cycle}`. Capture stdout.
6. Parse stdout as JSON. Write the stdout verbatim to `{scripts_dir_name}/stdout/cycle_{cycle}_iter{iteration}.json` (create `{scripts_dir_name}/stdout/` on first use; `{iteration}` is the 1-based iteration number that will be written to `cycle_history` in Step 5). The parsed dictionary is the in-session candidate evidence driving Step 2 and Step 3. Only the compact summary derived from it is written into `cycle_history.script_evidence` in Step 5; the on-disk file is the full-JSON audit artifact referenced by `script_evidence_ref`.
7. Scan stderr and stdout for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing. Functions that intentionally demonstrate failure must be explicitly flagged with a `# expected_failure` comment.

Script shape: one `run_cycle_*` function per cycle, a `load_state()` helper that reads `02_protocol.yaml`, a `load_formulate()` helper that reads `01_formulation.yaml`, an `argparse --cycle X` CLI, and a `main()` that prints exactly one JSON object to stdout. Claude writes the file from scratch in Cycle A and extends it with a new function at the start of every subsequent cycle.

Script rules:
- The script prints exactly one JSON object to stdout. Nothing else on stdout.
- The script does not write to `02_protocol.yaml`. Only the model writes the canonical YAML.
- The script may create frozen-artifact files on disk in Cycle B. Record paths and SHA-256 in the evidence packet so the model can update `frozen_artifacts.artifacts` and `provenance.files`.
- Heavy data (arrays, full DataFrames) is summarized, not dumped. Evidence packets stay compact.
- Each cycle's stdout is written verbatim to `{scripts_dir_name}/stdout/cycle_{cycle}_iter{iteration}.json`. `cycle_history[*].script_evidence` stores only a compact summary plus `script_evidence_ref` pointing at that file. Do not dump the full JSON into the canonical YAML.
- Per-file provenance (schema, encoding, sha256) is emitted only the first time a file is recorded -- typically Cycle A iter 1 (or Cycle B for frozen partition artifacts). After it lands in `provenance.files`, neither the stdout packet nor `cycle_history[*].script_evidence` re-emits those fields; downstream cycles reference those files by filename.
- Seeds are set inside the function whenever any stochastic step runs, and the seed value is echoed into the evidence packet.
- Partition logic must not use future information unless the approved mode requires future separation by construction.
- No generic helpers at module scope beyond those named in the Script shape above. Any helper introduced for a cycle lives inside that cycle's function and is removed once the cycle passes.

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
  description="Domain and methods research for Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a domain and methods research assistant for a Skeptic protocol stage.

  Context:
  - Approved question: "{approved_question from 01_formulation.yaml}"
  - Question type: {question_type}
  - Target quantity: {target_quantity}
  - Claim boundary: {claim_boundary from 01_formulation.yaml}
  - Active route: {route.active}
  - Formulate protocol handoff: {protocol_handoff from 01_formulation.yaml}
  - Current cycle script evidence: {compact summary of script_evidence for this cycle}

  User observations: {cycle_history entry's user_observations from Step 2, or "none"}

  Answer these research questions for Cycle {X} ({cycle focus}):
  {research_questions list from the cycle YAML}

  Return concise findings with sources. Every citation must include its URL inline
  after the claim it supports. Organize findings by question. Focus on facts that
  materially change:
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

Evaluation subagent:

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a Skeptic protocol cycle.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/02_protocol.py
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  4. ../routes/{route}/protocol.md

  Cycle focus: {cycle focus description}
  Cycle YAML for reference: {cycles/{X}.yaml full content}
  Script evidence produced this iteration: {the candidate script_evidence}
  User observations: {cycle_history entry's user_observations from Step 2, or "none"}

  Claim Boundary check: verify that protocol decisions do not widen
  `claim_boundary.scope`, loosen `claim_boundary.generalization_limit`, or remove
  entries from the effective verbs_forbidden set derived in formulate. A divergence
  forces a narrowing entry in `01_formulation.yaml:claim_boundary.narrowing_log`;
  silent widening is a blocking defect.

  Produce this structured output, in order, with these exact section headings:

  EVALUATION: Cycle {X} - {focus}

  UNANSWERED CHECKLIST ITEMS (list the IDs of any checklist item that was not answered -- absence of an item's evidence_key in the script output, or absence of the corresponding judgment, counts as unanswered):
  - Unanswered: [list of IDs, or "none"]

  CYCLE-SPECIFIC PCS QUESTIONS (from the cycle YAML `pcs_focus.items`; answer each one explicitly in the DEFECT SCAN below if any are defined, otherwise state "none defined"):
  {pcs_focus.items from the cycle YAML, one bullet per item, or "none defined"}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Actively falsify each gate and checklist
  answer rather than confirm them. For each gate marked PASS, state the
  specific failure mode you tested and ruled out. Categories: unstated
  assumptions, missing edge cases, unverifiable criteria, logical gaps between
  protocol rules and downstream needs, decisions deferred without justification,
  constraint gaps, rules too vague for a later stage to enforce, silent claim
  widening.
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
  - Alt 1: [different protocol choice] - Score: [1-10] - [justification]
  - Alt 2: [different protocol choice] - Score: [1-10] - [justification]

  GAPS REMAINING: [list, or "none"]
  DOWNSTREAM IMPLICATIONS: [what clean, examine, or analyze must now obey, or "none"]
  RECOMMENDED FOLLOW-UP CYCLE: [topic and why, or "none"]

  FINAL COUNTS:
  Unanswered items: [count]
  Blocking defects: [count]
  Failed gates: [count]

  Be objective. Not harsh, not lenient.
  """
)
```

When both subagents return, the model parses three counts from the evaluation output: `Unanswered items`, `Blocking defects`, `Failed gates`. `blocking_failures = unanswered + blocking_defects + failed_gates`; `blocking_failures == 0` means PASS. Every checklist item must be answered for the cycle to pass -- unanswered items feed the count directly so there is no need for a 1:1 gate per item.

Digest the subagent replies into `cycle_history[*].subagents`. Do not store the verbatim prose anywhere -- not in the YAML, not on disk. Admit something to `subagents` only if a future reader needs it to reconstruct why this path was chosen.

Include:
- `research_sources`: URLs that actually tipped a call, each paired with a one-line claim. Drop sources that merely confirmed obvious baseline facts or rephrased what was already known.
- `decisions`: operational choices where a reasonable alternative existed. Tag each with its PCS axis (`P`, `C`, `S`, or `null` when not PCS-relevant). Set `source` to the index into `research_sources` when a specific source drove the call. Default choices (reading a CSV with `read_csv`, computing sha256 with hashlib) are not decisions.
- `rejected_alternatives`: paths actively weighed and dropped, with the reason and PCS axis. This is the stability counterfactual record.
- `open_risks`: one line each. Unresolved concerns downstream stages must carry forward.

Exclude:
- Prose summaries, meta-commentary, or "the subagent reviewed and confirmed" filler.
- Restatements of checklist questions, gate definitions, `research_questions`, or `script_evidence` already on file.
- Per-gate PASS notes when nothing interesting happened. Only gates whose reasoning belongs in the audit record.
- Sources that confirmed baseline facts without changing behavior.

Do not invent fields outside the schema. If something the subagent surfaced has no schema home, either fit it into `open_risks` or omit it; never add ad-hoc keys.

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
- `data_insufficient` -> log why and present options (request more data, reformulate, archive)
- `reformulate` -> stop and reopen `formulate` plus `protocol`
- `archive` -> stop with documentation of why
- `override` -> user states the specific reason a FAIL is incorrect; logged as `override: {reason, gate}`; forward actions unlock

Interactive mode: present the synthesized assessment and the allowed actions via `AskUserQuestion`. Wait for the user's answer before invoking any other tool.

Auto mode: apply the autonomous decision protocol from `../auto-mode.md`.

If later work discovers the rules cannot be locked without better upstream evidence, choose `reformulate`, `data_insufficient`, or `archive`.

### Step 5: Log

Append one entry to `cycle_history`. Required fields:

- `cycle`, `iteration`
- `unanswered` (list of checklist IDs that could not be answered; empty list when all were answered)
- `script_evidence` (compact summary only: 4-8 one-line bullets, or one-line value per `evidence_key` from the cycle YAML). Do not re-emit the full JSON, full DataFrames, or full arrays; after Cycle A iter 1, do not re-emit file schema, encoding, or sha256 -- those are immutable and live in `provenance.files`.
- `script_evidence_ref` (relative path to the on-disk stdout file written in Step 1: `{scripts_dir_name}/stdout/cycle_{cycle}_iter{iteration}.json`)
- `subagents.research_sources`, `subagents.decisions`, `subagents.rejected_alternatives`, `subagents.open_risks`, `subagents.blocking_failures` (populate each only with entries that materially shaped this iteration; empty lists are valid)
- `decision`

Write conditional fields only when they apply:

- `user_observations`: captured in Step 2 when AskUserQuestion elicited user input.
- `decision_reason`: required when `decision != pass`.
- `override`: `{reason, gate}` only when a FAIL was overridden.

`blocking_failures` (0 = PASS, >0 = FAIL) is the enforceable integer summary. Per-gate reasoning enters `cycle_history` only through `subagents.decisions[*]` or `subagents.rejected_alternatives[*]` when a gate's reasoning materially changed the outcome; never as a full gate-by-gate restatement.

Update every canonical-YAML field named in a checklist item's `writes_to`, but only for fields this project actually populates. Leave non-applicable optional fields out entirely rather than setting them to null. Cycle-specific `step4_additions` are applied at this point if the cycle YAML defines them. `pcs_focus` is consumed by the Step 3 evaluation subagent prompt and produces no separate Step 5 entry.

Set `status.current_cycle` to the next cycle letter (or keep for another iteration). Append the closed cycle letter to `status.completed_cycles` only when the cycle passes or is closed by override.

Re-parse `02_protocol.yaml` to confirm validity.

## Ending the Cycle Loop

The loop ends when all of the following hold:

- every mandatory cycle (A through D) has a closing `decision` of `pass` or an `override`
- every approved follow-up cycle is resolved
- every frozen artifact that Cycle B said was required has been created and recorded in `frozen_artifacts.artifacts` and `provenance.files`
- interactive mode: the user explicitly approves the protocol contract (route, data-usage mode, frozen artifacts, evidence rules, prohibitions, backtracking triggers)
- auto mode: the stage approval gate in `../auto-mode.md` completes

Finalization requires explicit stage-close discipline. Do not finalize because the stage "seems clear enough."

## PCS Subagent Review

At stage close:

```text
Agent(
  model="{subagent_model}",
  description="PCS review of protocol stage",
  prompt="""
  You are a PCS reviewer for a Skeptic protocol stage.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  2. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.yaml
  3. {projects_root}/{project-name}/{scripts_dir_name}/02_protocol.py
  4. ../routes/{route}/protocol.md

  Evaluate whether protocol adequately defines how the approved question may
  be answered and adequately constrains the downstream stages.

  PREDICTABILITY:
  - Does the chosen data-usage mode match the allowed claim and the reality check the claim requires?
  - Are validation requirements strong enough for the allowed claim without forcing the wrong template?
  - Are external, temporal, deployment-context, or reporting-frame realities handled when they materially matter?

  STABILITY:
  - Could a different but still reasonable protocol choice materially change the allowed claim?
  - Are leakage, confounding, identification, time order, grouping, and interference handled explicitly enough to prevent hidden instability?
  - If full-data analysis was approved, is that choice defended rather than assumed?

  COMPUTABILITY:
  - Are frozen artifacts, if any, created and deterministically reproducible from documented seeds and rules?
  - Are prohibitions and backtracking triggers explicit enough for later stages to execute reproducibly?
  - Could another analyst tell exactly what data they may use and what they may not do?

  For each lens, state what holds up well, what is uncertain or risky, and any
  specific recommendations. Keep it concise.
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

0. If frozen artifacts were declared required in Cycle B but are missing from `frozen_artifacts.artifacts` or from disk, stop. The stage is incomplete.

1. Parse `02_protocol.yaml` with a standard YAML loader. Repair if parsing fails.

2. Render `02_protocol.md` from the canonical YAML. Keep the report compact: one `##` section per top-level YAML key that is populated (`Route`, `Handoff Audit`, `Data Usage`, `Frozen Artifacts`, `Evidence Rules`, `Prohibitions`, `Backtracking Triggers`, `Cycle Summary` with one line per cycle, `PCS Assessment`). Omit sections whose YAML keys are empty or absent. Reference the subagent verbatims through the YAML; the markdown is a rendered summary.

3. Update `README.md` with:

   ```markdown
   ## Protocol [COMPLETE]
   Type: {question_type}
   Active route: {route.active}
   Data usage mode: {data_usage.mode}
   Frozen artifacts: {comma-separated artifact paths, or "none required"}
   Validation logic: {one-line summary of evidence_rules.validation_logic.required_checks}
   Next: Clean - auditable data pipeline under protocol rules
   ```

4. Set `status.locked_at: {ISO timestamp}`. Re-parse the YAML to confirm validity.

5. Read `README.md` and quote the `## Protocol [COMPLETE]` block verbatim in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete; return to step 3. Only then tell the user the protocol stage is complete and the next stage is `clean`.

## Backtracking

If a downstream stage reopens `protocol`:

- Preserve every entry in `cycle_history`. Append new iterations.
- Unlock the stage: set `status.locked_at: null`.
- Re-run the affected cycles and re-render the markdown at the end.
- If the chosen data-usage mode changes, create or retire frozen artifacts as needed and update `provenance.files` to reflect the new disk state. Preserve the earlier artifact records under the superseding cycle_history iteration rather than editing past entries.
- Downstream narrowing entries already written to `01_formulation.yaml:claim_boundary.narrowing_log` remain in place.

If later work changes the question type, target quantity, or claim boundary, reopen both `formulate` and `protocol`.
