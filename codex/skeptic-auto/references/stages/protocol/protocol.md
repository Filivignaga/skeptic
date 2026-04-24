
# /skeptic:protocol - Project Rules of the Game

IMPORTANT: Before executing, read `references/core-principles.md`. `core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

Protocol defines how the approved question may be answered. It locks the data-usage mode, admissible evidence logic, validation requirements, stage prohibitions, and backtracking triggers. It does not choose the estimator, model family, or final analysis contract. That belongs to `analyze`.

Do not default to splits. Do not default to full-data analysis. Decide, justify, and record.

## Stage Outputs

`protocol` writes exactly three project-side artifacts plus a README block. Compact state lives in the canonical YAML.

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
  files: {}                         # {filename: {sha256}} for source files first registered by formulate and frozen artifacts created in Cycle B

upstream_refs:
  - file: skeptic_documentation/01_formulation.yaml
    sections: [approved_question, question_type, target_quantity, claim_boundary, route_candidates, key_assumptions, protocol_handoff, provenance]
    sha256:

route:
  active:                           # descriptive|exploratory|inferential|predictive|causal|mechanistic
  resolution_evidence:              # short note on how the route was resolved from formulate

handoff_audit:                      # populated in Cycle A
  sections_present: {}              # {section_name: true|false} for required formulate YAML keys
  required_fields: {}               # {field_path: present|partial|missing}
  contradictions: []                # list of {issue, locations, severity}
  ambiguities: []                   # list of {issue, classification: protocol_safe|protocol_blocking|formulate_contradiction}
  minimum_decisions: []             # minimum set of decisions protocol must produce before clean can start
  confirmed:                        # compact refs or summaries extracted from formulate; do not copy full upstream fields
    approved_question_ref:
    question_type_ref:
    target_quantity_ref:
    claim_boundary_ref:
    route_candidates_ref:

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

decision_ledger: []                   # append-only list, one entry per iteration
pcs_review: null                    # set at stage close
```

Each `decision_ledger` entry:

```yaml
- cycle:                            # cycle letter or follow-up id
  iteration:                        # 1-based per cycle id
  decision:                         # pass|iterate|acknowledge_gap|reopen_*|data_insufficient|archive|override
  blocking_failures:                # int (0 = PASS, >0 = FAIL)
  blocking_reason:                  # one-line reason when blocking_failures > 0, else null
  evidence_summary: {}              # compact material evidence only; no full JSON, DataFrames, arrays, or per-column schema dumps
  changed_fields: []                # canonical-YAML fields written or materially changed this iteration
  next_action:                      # next cycle, follow-up, finalization, or backtrack target
  # Optional: user_observations, decision_reason, override: {reason, criterion}, material_sources: [{url, claim}], rejected_alternatives: [{option, reason}]
```

Analytical findings belong in their destination fields. The decision ledger records only what changed, why the cycle did or did not close, and what happens next. Do not store full subagent replies, criterion-by-criterion PASS notes, or repeated script output in canonical YAML.
`pcs_review` when set:

```yaml
pcs_review:
  overall:                          # PASS|FAIL, satisfied|valid_concern|disagree_override, or route-specific terminal verdict
  blocking_findings: []             # compact list of failed checks or blocking concerns
  material_risks: []                # compact list of non-blocking risks worth carrying forward
  material_findings: []             # compact list of review findings that changed a decision or disposition
  full_review_pointer:              # optional; use only when a FAIL or override requires retaining full text outside the canonical YAML
  disposition:                      # satisfied|valid_concern|disagree_override
  disposition_reason:
```

Rules:
- The YAML must parse with a standard YAML loader after every write.
- `decision_ledger` is append-only. Superseded iterations stay in the list; new iterations append.
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
- `setup_side_effects`: one-time actions (typically Cycle A only, plus Cycle B when frozen artifacts are created); omit when empty
- `required_evidence`: evidence keys or judgment outputs the cycle must produce
- `acceptance_criteria`: 3-5 verifiable conditions for cycle closure
- `writes`: mapping from evidence or judgment outputs to canonical-YAML fields
- `research_questions`: topics for the research subagent
- `mode_registry` (Cycle B only): reference list of data-usage modes with typical justifications and typical mistakes
- `route_pressure` (Cycle B and C): reference list mapping question types to protocol pressure, validation emphasis, and common non-default outcomes
- `guidance`: short, cycle-specific judgment rules
- decision-relevance check: for material judgments, name the plausible alternative most likely to change a downstream decision and store it in the relevant analytical field, not a new log
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
     - Load `references/routes/{route}/protocol.md` once and keep it in memory for the rest of the stage. If the route file is missing, stop.
     - Initialize `{docs_dir_name}/02_protocol.yaml` with `stage`, `schema_version`, `project.name`, `project.started_at` (ISO timestamp), `status.current_cycle: A`, `route.active`, and `route.resolution_evidence`.
     - Create `{scripts_dir_name}/02_protocol.py` with the shape specified below.
   - First cycle entered in a fresh session (not Cycle A), or first cycle after a backtrack reopens the stage: read `02_protocol.yaml` and reload `references/routes/{route}/protocol.md` once.
   - Every other case (continuing the same chat session): skip the re-read; the canonical YAML content and route file are already in context.
3. Every cycle: extend `02_protocol.py` by writing or updating the cycle's function (`run_cycle_a`, `run_cycle_b`, ...). The function must produce every required evidence key named by the cycle spec.
4. Cycle B only, when the chosen data-usage mode requires frozen artifacts: the script deterministically creates the partition index and any other frozen files under `{data_dir_name}/splits/` (or another path the approved mode requires). The script emits each artifact path and SHA-256 in `frozen_artifact_manifest`. The model records them under `frozen_artifacts.artifacts` and `provenance.files`.
5. Run `python {scripts_dir_name}/02_protocol.py --cycle {cycle}`. Capture stdout.
6. Parse stdout as JSON. Use the parsed dict as this cycle's candidate evidence for Step 2 and Step 3; Step 5 records a compact summary in `decision_ledger[*].script_evidence`. Do not retain raw stdout by default. Write a debug sidecar only when the cycle fails, is rerun for diagnosis, or the user asks for retained raw evidence.
7. Scan stderr and stdout for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing. Functions that intentionally demonstrate failure must be explicitly flagged with a `# expected_failure` comment.

Script contract: generate `02_protocol.py` for the current project and follow `references/script-contract.md`. Include only the helpers needed to read `02_protocol.yaml`, read `01_formulation.yaml`, and produce the active cycle evidence. Cycle B may create frozen artifacts only when the chosen data-usage mode requires them.

Script rules:
- The script prints exactly one JSON object to stdout. Nothing else on stdout.
- The script does not write to `02_protocol.yaml`. Only the model writes the canonical YAML.
- The script may create frozen-artifact files on disk in Cycle B. Record paths and SHA-256 in the evidence packet so the model can update `frozen_artifacts.artifacts` and `provenance.files`.
- Heavy data (arrays, full DataFrames) is summarized, not dumped. Evidence packets stay compact.
- Per-file provenance (schema, encoding, sha256) is emitted only the first time a file is recorded -- typically Cycle A iter 1 (or Cycle B for frozen partition artifacts). After it lands in `provenance.files`, neither the stdout packet nor `decision_ledger[*].script_evidence` re-emits those fields; downstream cycles reference those files by filename.
- Seeds are set inside the function whenever any stochastic step runs, and the seed value is echoed into the evidence packet.
- Partition logic must not use future information unless the approved mode requires future separation by construction.
- Stable helper functions or sibling helper modules are allowed when they reduce duplication and improve reproducibility. Helpers must be deterministic, documented briefly, and must not write canonical YAML or access restricted artifacts.

### Step 2: Human Review

Interactive mode:
1. Present the script evidence inline, concisely.
2. Scan the evidence for ambiguities, decision points the model cannot resolve alone, and research topics worth seeding into Step 3 beyond the cycle's default research_questions.
3. If at least one such item exists, dispatch `AskUserQuestion` with 1-3 questions targeting them. Otherwise proceed directly to Step 3.
4. When AskUserQuestion was dispatched, record the user's answers as `user_observations` in the pending decision_ledger entry. Pass them into Step 3 subagent prompts via the `User observations:` field.

Auto mode: apply the self-review loop from `references/auto-mode.md`. Self-correct within the configured budget, then proceed unless an escalation trigger fires.

### Step 3: Subagent Review

Run subagents only when the cycle risk warrants it. Use the research subagent only when outside domain or methodological information can materially change a decision. Use the evaluation subagent on high-risk cycles, unresolved blocking issues, or stage close; otherwise perform the acceptance-criteria check inline.

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

  User observations: {decision_ledger entry's user_observations from Step 2, or "none"}

  Answer these research questions for Cycle {X} ({cycle focus}):
  {research_questions list from the cycle YAML}

  Return concise findings. Create or reference a `research_log.jsonl` row only for sources that materially change a decision or will be cited in a deliverable; canonical YAML keeps only `research_log#n` pointers. Organize findings by question. Focus on facts that
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
  4. references/routes/{route}/protocol.md

  Cycle focus: {cycle focus description}
  Cycle YAML for reference: {cycles/{X}.yaml full content}
  Script evidence produced this iteration: {the candidate script_evidence}
  User observations: {decision_ledger entry's user_observations from Step 2, or "none"}

  Claim Boundary check: verify that protocol decisions do not widen
  `claim_boundary.scope`, loosen `claim_boundary.generalization_limit`, or remove
  entries from the effective verbs_forbidden set derived in formulate. A divergence
  forces a narrowing entry in `01_formulation.yaml:claim_boundary.narrowing_log`;
  silent widening is a blocking defect.

  Produce this structured output, in order, with these exact section headings:

  EVALUATION: Cycle {X} - {focus}

  MISSING REQUIRED EVIDENCE (list required evidence keys or judgment outputs that are absent; evidence with a satisfied skip rule is not missing):
  - Unanswered: [list of IDs, or "none"]

  CYCLE-SPECIFIC PCS QUESTIONS (from `pcs_focus.items`, if any):
  {pcs_focus.items from the cycle YAML, one bullet per item, or "none defined"}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Actively falsify the acceptance criteria and material evidence rather than confirm them. Record only failures or non-obvious risks; do not write PASS notes for every criterion. Categories: unstated
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

  ACCEPTANCE CRITERIA ASSESSMENT (list only failed criteria or non-obvious criteria that materially affected the decision; missing required evidence fails dependent criteria):
  - {criterion_id}: PASS | FAIL - [evidence]

  DECISION-RELEVANT COUNTERFACTUAL:
  - Strongest plausible alternative that would change a downstream decision: [alternative, affected decision, why accepted/rejected]

  GAPS REMAINING: [list, or "none"]
  DOWNSTREAM IMPLICATIONS: [what clean, examine, or analyze must now obey, or "none"]
  RECOMMENDED FOLLOW-UP CYCLE: [topic and why, or "none"]

  FINAL COUNTS:
  Unanswered items: [count]
  Blocking defects: [count]
  Failed criteria: [count]

  Be objective. Not harsh, not lenient.
  """
)
```

When both subagents return, the model parses three counts from the evaluation output: `Unanswered items`, `Blocking defects`, `Failed criteria`. `blocking_failures = unanswered + blocking_defects + failed_criteria`; `blocking_failures == 0` means PASS. Every required evidence key must be produced or formally skipped, and every acceptance criterion must pass or be explicitly overridden.

Digest subagent replies only when they change the cycle outcome or leave a risk that downstream stages must carry. Store those items in `decision_ledger[*].review_findings`.

Include only:
- blocking findings or failed criteria that drove the decision
- decision-changing external sources, referenced by `research_log#n` when a research log exists
- the strongest rejected alternative when it would change a downstream decision
- unresolved risks that downstream stages must carry

Exclude PASS notes, subagent summaries, restatements of required evidence, sources that did not change behavior, and default implementation choices.

### Step 4: Decision

When both subagents return:

1. Verify each result is non-empty and contains its required sections. If malformed, escalate to the user (interactive) or follow `references/auto-mode.md` (auto).
2. Parse `Unanswered items`, `Blocking defects`, `Failed criteria` from the evaluation output.
3. Compute `blocking_failures = unanswered + blocking_defects + failed_criteria`.
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
- `override` -> user states the specific reason a FAIL is incorrect; logged as `override: {reason, criterion}`; forward actions unlock

Interactive mode: present the synthesized assessment and the allowed actions via `AskUserQuestion`. Wait for the user's answer before invoking any other tool.

Auto mode: apply the autonomous decision protocol from `references/auto-mode.md`.

If later work discovers the rules cannot be locked without better upstream evidence, choose `reformulate`, `data_insufficient`, or `archive`.

### Step 5: Log

Append one entry to `decision_ledger`. Required fields:

- `cycle`, `iteration`
- `decision`, `blocking_failures`, `blocking_reason`, `evidence_summary`, `changed_fields`, and `next_action`

Write conditional fields only when they apply:

- `user_observations`: captured in Step 2 when AskUserQuestion elicited user input.
- `decision_reason`: required when `decision != pass`.
- `override`: `{reason, criterion}` only when a FAIL was overridden.

`blocking_failures` (0 = PASS, >0 = FAIL) is the enforceable integer summary. Record only material failed criteria, rejected alternatives, or source-backed decisions; do not store Per-criterion PASS notes or full subagent output.

Update every canonical-YAML field named by the cycle spec `writes`, but only for fields this project actually populates. Leave non-applicable optional fields out entirely rather than setting them to null. Cycle-specific `step4_additions` are applied at this point if the cycle YAML defines them. `pcs_focus` is consumed by the Step 3 evaluation subagent prompt and produces no separate Step 5 entry.

Set `status.current_cycle` to the next cycle letter (or keep for another iteration). Append the closed cycle letter to `status.completed_cycles` only when the cycle passes or is closed by override.

Re-parse `02_protocol.yaml` to confirm validity.

## Ending the Cycle Loop

The loop ends when all of the following hold:

- every mandatory cycle (A through D) has a closing `decision` of `pass` or an `override`
- every approved follow-up cycle is resolved
- every frozen artifact that Cycle B said was required has been created and recorded in `frozen_artifacts.artifacts` and `provenance.files`
- interactive mode: the user explicitly approves the protocol contract (route, data-usage mode, frozen artifacts, evidence rules, prohibitions, backtracking triggers)
- auto mode: the stage approval checkpoint in `references/auto-mode.md` completes

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
  4. references/routes/{route}/protocol.md

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

Digest the review into `pcs_review`: record `overall`, `blocking_findings`, `material_risks`, `material_findings`, `disposition`, and `disposition_reason`. Do not store the full review text unless a FAIL or override makes literal audit text necessary; if retained, store only a pointer in `full_review_pointer`.

- Interactive mode: present via `AskUserQuestion` with options `satisfied`, `valid_concern`, `disagree_override`. Wait for the user's answer before invoking any other tool.
- Auto mode: apply `references/auto-mode.md` stage-close rules.

Record the chosen disposition and reason in `pcs_review.disposition` and `pcs_review.disposition_reason`.

The subagent advises. It does not silently widen scope or bypass a blocking concern.

## Finalization

After the PCS review clears or the user overrides it:

0. If frozen artifacts were declared required in Cycle B but are missing from `frozen_artifacts.artifacts` or from disk, stop. The stage is incomplete.

1. Parse `02_protocol.yaml` with a standard YAML loader. Repair if parsing fails.

2. Render `02_protocol.md` from the canonical YAML. Keep the report compact: one `##` section per top-level YAML key that is populated (`Route`, `Handoff Audit`, `Data Usage`, `Frozen Artifacts`, `Evidence Rules`, `Prohibitions`, `Backtracking Triggers`, `PCS Assessment`). Omit sections whose YAML keys are empty or absent. Reference the compact `pcs_review` fields through the YAML; the markdown is a rendered summary.

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

5. Read `README.md` and include the `## Protocol [COMPLETE]` block exactly in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete; return to step 3. Only then tell the user the protocol stage is complete and the next stage is `clean`.

## Backtracking

If a downstream stage reopens `protocol`:

- Preserve every entry in `decision_ledger`. Append new iterations.
- Unlock the stage: set `status.locked_at: null`.
- Re-run the affected cycles and re-render the markdown at the end.
- If the chosen data-usage mode changes, create or retire frozen artifacts as needed and update `provenance.files` to reflect the new disk state. Preserve the earlier artifact records under the superseding decision_ledger iteration rather than editing past entries.
- Downstream narrowing entries already written to `01_formulation.yaml:claim_boundary.narrowing_log` remain in place.

If later work changes the question type, target quantity, or claim boundary, reopen both `formulate` and `protocol`.
