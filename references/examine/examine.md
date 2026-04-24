---
name: examine
description: Use after formulate, protocol, and clean. Characterize what the cleaned, protocol-visible data can actually support through iterative cycles that stay inside the approved question and the protocol contract. Fourth stage of Skeptic.
---

# /skeptic:examine - Data Examination and Support Characterization

IMPORTANT: Before executing, read `../core-principles.md`. `core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

A good analyst characterizes what the cleaned, protocol-visible data can actually support, then hands `analyze` a concrete list of supported aspects, fragile patterns, and constraints. Examination maps distributions, relationships, anomalies, and fragility; exploratory patterns remain observations that inform later contract lock, not confirmed claims. Contract selection, claim-boundary widening, and final-estimator decisions belong to `analyze`.

The active route is whatever `02_protocol` confirmed. Route candidates in `01_formulation` are upstream history, not live permissions.

## Stage Outputs

`examine` writes exactly three project-side artifacts plus a README block. Compact state lives in the canonical YAML.

| Path | Role |
|------|------|
| `{scripts_dir_name}/04_examination.py` | Single Python file containing one function per cycle (`run_cycle_a`, `run_cycle_b`, `run_cycle_c`, `run_cycle_e`, and any opened follow-up `run_cycle_d1`, `run_cycle_d2`, ...). Invoked one cycle at a time. Returns a JSON evidence packet on stdout. |
| `{docs_dir_name}/04_examination.yaml` | Canonical stage memory. Holds the upstream snapshot, visibility set, support registry, structure and relationship findings, anomaly and bias inventory, fragility review, analysis handoff, cycle history, and PCS review. Created at stage start, updated at the end of every cycle. |
| `{docs_dir_name}/04_examination.md` | Human-readable report. Rendered once at finalization from the canonical YAML. |
| `{readme_name}` | Short `## Examine [COMPLETE]` block added at finalization. |

The canonical YAML is the single source of truth. If the rendered markdown disagrees with the YAML, the YAML wins.

## Required Inputs

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` with `formulate`, `protocol`, and `clean` complete |

No new user input is required. If upstream outputs are incomplete, contradictory, or missing, stop and reopen the upstream stage. Examination permissions come from upstream outputs only.

The stage reads these upstream artifacts:

- `{docs_dir_name}/01_formulation.yaml`: approved question, question type, target quantity, claim boundary, key assumptions, route candidates
- `{docs_dir_name}/02_protocol.yaml`: active route, data usage mode, visibility rules for `examine`, frozen artifacts, leakage and forbidden-variable rules, validation logic, stage prohibitions, backtracking triggers
- `{docs_dir_name}/03_cleaning.yaml`: final visible artifact list, final variable list, population-shift summary, dataset fitness review, carried assumptions and open questions
- cleaned artifacts named in `03_cleaning.yaml` under the configured data directory (and protocol-created artifacts such as split manifests under `{data_dir_name}/splits/` when `02_protocol.yaml` names them)
- `{readme_name}`: confirms prior stage completion

If `02_protocol.yaml` does not collapse to exactly one route for `examine`, or contradicts `01_formulation.yaml`, stop and reopen `protocol`.

## Canonical YAML Schema

`04_examination.yaml` is the stage's memory. The model initializes it in Cycle A and extends it at the end of every cycle. The script never writes to this file.

Write only fields that apply to the project. Omit fields that would be null; readers treat a missing key as "not applicable." The schema below names every possible field; a concrete project will populate a subset.

```yaml
stage: examine
schema_version: 1

project:
  name:
  path:

status:
  current_cycle:                    # A|B|C|E|D1|D2|...|null
  completed_cycles: []
  locked_at: null                   # set at stage close; presence = locked

upstream:                           # snapshot copied once at Cycle A setup
  formulation_yaml:                 # relative path
  protocol_yaml:
  cleaning_yaml:
  approved_question:
  question_type:
  target_quantity:
  claim_boundary:                   # {claim_type, scope, evidence_ceiling, generalization_limit, verbs_allowed_effective, verbs_forbidden_effective}
  active_route:                     # descriptive|exploratory|inferential|predictive|causal|mechanistic
  route_file:                       # references/routes/{route}/examine.md
  protocol_mode:
  visibility_rules_summary:
  cleaned_artifact_list: []
  protocol_created_artifact_list: []
  leakage_rules_summary:
  examine_prohibitions: []
  backtracking_triggers: []
  carried_assumptions: []
  carried_open_questions: []

visibility:                         # derived once at Cycle A setup; reused across cycles
  visible_cleaned_artifacts: []     # [{name, access_level, notes}]
  visible_protocol_artifacts: []    # [{name, access_level, notes}]
  restricted_artifacts: []          # named artifacts that are out of bounds for examine
  access_notes:                     # free-text clarifications when protocol visibility needs interpretation

support_registry:                   # built across A, B, C; finalized in E
  well_supported: []                # [{item, evidence_ref}]
  weakly_supported: []              # [{item, why_weak, evidence_ref}]
  unsupported: []                   # [{item, why_unsupported, evidence_ref}]

structure_profile:                  # Cycle A
  artifact_dimensions: {}           # {artifact: {n_rows, n_cols}}
  distributions_and_coverage: {}    # {artifact: {column: compact_summary}}
  schema_and_reconciliation: {}     # {artifact: {schema_sanity, count_reconciliation}}
  subgroup_presence: {}             # {dimension: {levels, balance, thin_or_missing_levels}} when relevant
  startup_checks: {}                # {artifact: {top_rows_seen, bottom_rows_seen, missing_codes_seen, sentinels_seen, join_structure_notes}}
  subsample_use: {}                 # {artifact: {used: bool, method, size, reconciled_against_full: bool}} when relevant

relationships:                      # Cycle B
  meaningful_views: []              # [{view, why_meaningful, variables_involved}]
  scope_excluded_views: []          # [{view, why_out_of_scope}]
  dependence_findings: []           # [{finding, artifact, evidence}]
  heterogeneity_findings: []        # [{dimension, finding, evidence}] when relevant
  route_pressures: []               # [{pressure, explanation, implication_for_analyze}]
  display_justifications: []        # [{plot_family_or_statistic, variable_type, alternative_view_tested, outcome}]
  subsample_justification:          # free-text when a subsample was used for visual reasoning

anomalies_and_contradictions:       # Cycle C
  inventory: []                     # [{type: anomaly|contradiction|sparse_region|extreme|inconsistency|measurement_artifact, description, artifact, evidence}]
  bias_taxonomy: []                 # [{domain: confounding|participant_selection|exposure_classification|protocol_departure|missing_data|outcome_measurement|reporting_selection|immortal_time|berkson|positivity_violation, presence, direction, severity, threatens_claim_boundary, mitigation_or_deferral}]
  perturbation_checks: []           # [{pattern, alternatives_tested, outcome}]
  stability_classification: []      # [{pattern, verdict: stable|conditional|fragile, reasoning}]
  support_gaps_against_claim_boundary: []  # [{gap, why_material, affected_route_or_claim}]
  backtracking_decision:            # {required: bool, target: none|clean|protocol|formulate_plus_protocol, reason}
  stop_rule_decision:               # {decision: stop|continue|open_follow_up, reason}

fragility_review:                   # set at stage close; each item also feeds Cycle E
  patterns: []                      # [{pattern, alternatives_tested, verdict: stable|conditional|fragile, downstream_consequence}]
  framing_incremental_risk:         # free-text; one-line if no risk introduced

claim_boundary_narrowing: []        # [{entry, reason, source_cycle}] -- this stage's recommended narrowing; flows to formulate only via backtracking

analysis_handoff:                   # Cycle E; finalized at stage close
  supported_aspects: []
  weakly_supported_aspects: []
  unsupported_aspects: []
  route_strength_update:            # {stronger: [...], weaker: [...], unchanged: [...], no_longer_defensible: [...]}
  analysis_constraints: []          # [{constraint, evidence, why_it_matters}]
  unresolved_risks: []
  open_issues_for_analyze: []
  tensions: []                      # [{description, sources, implication}]
  next_stage: analyze
  contract_selection_disclaimer:    # one-line: examine does not select the analysis contract

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
- `claim_boundary_narrowing` holds examine-stage recommendations. Entries become canonical only when `formulate` is reopened and adopts them.
- Write only fields that apply.
- Use only ASCII characters in generated YAML content. Replace em dashes with `--`, curly quotes with straight quotes. Source-data strings may keep non-ASCII when the encoding is declared.

## Cycle Structure

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Support and distribution audit | Yes |
| B | Structural relationships and heterogeneity | Yes |
| C | Anomalies, contradictions, and support gaps | Yes |
| D1, D2, ... | Follow-up examinations | Conditional |
| E | Analysis handoff synthesis | Yes |

Cycles A, B, C, and E are mandatory. Follow-ups (`D1`, `D2`, ...) are narrow, issue-specific cycles opened only when a material examination question remains after A-C. Mandatory cycles run in order A -> B -> C -> (any approved follow-ups) -> E.

## Per-cycle Reference Files

Before running cycle X, load only `cycles/{X}.yaml`. Each cycle YAML carries:

- `upstream`: canonical-YAML fields that must be set before the cycle starts
- `setup_side_effects`: one-time actions (Cycle A only); omit when empty
- `required_evidence`: evidence keys or judgment outputs the cycle must produce
- `acceptance_criteria`: 3-5 verifiable conditions for cycle closure
- `writes`: mapping from evidence or judgment outputs to canonical-YAML fields
- `research_questions`: topics for the research subagent
- `guidance`: short, cycle-specific judgment rules
- decision-relevance check: for material judgments, name the plausible alternative most likely to change a downstream decision and store it in the relevant analytical field, not a new log
- `step4_additions`, `pcs_focus`, `log_extension`: present only when the cycle adds a specific discipline. `pcs_focus` holds cycle-specific PCS questions injected into the evaluation subagent prompt; it has no separate Step 5 application.

The stage entry (this file) is read once at stage start. Per-cycle files are loaded one at a time as each cycle runs.

Follow-up cycles use `cycles/D_template.yaml` as a starting shape. Materialize the concrete `Dn` spec inside the canonical YAML (not as a new file on disk) when a follow-up is opened.

## Cycle Protocol

This protocol applies to every cycle, mandatory or follow-up.

### Step 1: Setup and Execution

1. Read `cycles/{cycle}.yaml`.
2. Resolve the route and upstream snapshot:
   - Cycle A: read `01_formulation.yaml`, `02_protocol.yaml`, `03_cleaning.yaml`, and `README.md`. Resolve exactly one active route from `02_protocol.yaml` (must match the confirmed question type in `01_formulation.yaml`). Load `references/routes/{route}/examine.md` once and keep it in context for the rest of the stage. If the route cannot be resolved or the expected route file is missing, stop and reopen `protocol`.
   - First cycle entered in a fresh session (not Cycle A), or first cycle after a backtrack reopens the stage: read `04_examination.yaml` once to load the upstream snapshot, visibility, prior findings, and prior `decision_ledger`; reload the route file named in `upstream.route_file`.
   - Every other case (continuing the same chat session): skip the re-reads; the canonical YAML and route context are already in context from the cycle that just wrote it. If route context becomes ambiguous mid-stage, reread `01_formulation.yaml`, `02_protocol.yaml`, `03_cleaning.yaml`, and the route file before proceeding.
3. Cycle A only: create `04_examination.yaml` with `stage`, `schema_version`, `project`, the full `upstream` snapshot copied from the three upstream YAMLs, the derived `visibility` set (which cleaned artifacts and protocol-created artifacts `examine` may inspect, which are restricted, and what access level applies to each), and `status.current_cycle: A`. Create `04_examination.py` with the shape specified below.
4. Every cycle: extend `04_examination.py` by writing or updating the cycle's function (`run_cycle_a`, `run_cycle_b`, ...). The function must produce every required evidence key named by the cycle spec. Operate only on artifacts in `visibility.visible_cleaned_artifacts` and `visibility.visible_protocol_artifacts`.
5. Run `python {scripts_dir_name}/04_examination.py --cycle {cycle}`. Capture stdout.
6. Parse stdout as JSON. Use the parsed dict as this cycle's candidate evidence for Step 2 and Step 3; Step 5 records a compact summary in `decision_ledger[*].script_evidence`. The script has already mirrored the same JSON to `{scripts_dir_name}/stdout/cycle_{cycle}.json` for external inspection; do not copy it into the canonical YAML.
7. Scan stderr and stdout for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing. Functions that intentionally demonstrate failure must be explicitly flagged with a `# expected_failure` comment.

Script contract: generate `04_examination.py` for the current project and follow `../script-contract.md`. Include only the helpers needed for protocol-visible cleaned artifacts and the active cycle evidence.

Script rules:
- The script prints exactly one JSON object to stdout. Nothing else on stdout.
- The script does not write to `04_examination.yaml`. Only the model writes the canonical YAML.
- The script reads only artifacts named in `visibility.visible_cleaned_artifacts` and `visibility.visible_protocol_artifacts`. Touching a restricted artifact is a blocking defect.
- Heavy data (arrays, full DataFrames) is summarized, not dumped. Evidence packets stay compact.
- Per-file provenance (schema, encoding, sha256) is emitted only the first time a file is recorded -- typically Cycle A iter 1. After it lands in `provenance.files`, neither the stdout packet nor `decision_ledger[*].script_evidence` re-emits those fields; downstream cycles reference those files by filename.
- Seeds are set inside the function if any stochastic step runs (representative subsampling, resampled perturbations).
- Stable helper functions or sibling helper modules are allowed when they reduce duplication and improve reproducibility. Helpers must be deterministic, documented briefly, and must not write canonical YAML or access restricted artifacts.

### Step 2: Human Review

Interactive mode:
1. Present the script evidence inline, concisely.
2. Scan the evidence for ambiguities, decision points the model cannot resolve alone (ambiguous subgroup definitions, disputed anomaly interpretation, contested route-pressure reading), and research topics worth seeding into Step 3 beyond the cycle's default research_questions.
3. If at least one such item exists, dispatch `AskUserQuestion` with 1-3 questions targeting them. Otherwise proceed directly to Step 3.
4. When AskUserQuestion was dispatched, record the user's answers as `user_observations` in the pending decision_ledger entry. Pass them into Step 3 subagent prompts via the `User observations:` field.

Auto mode: apply the self-review loop from `../auto-mode.md`. Self-correct within the configured budget, then proceed unless an escalation trigger fires.

### Step 3: Subagent Review

Run subagents only when the cycle risk warrants it. Use the research subagent only when outside domain or methodological information can materially change a decision. Use the evaluation subagent on high-risk cycles, unresolved blocking issues, or stage close; otherwise perform the acceptance-criteria check inline.

Research subagent:

```text
Agent(
  model="{subagent_model}",
  description="Domain research for Examine Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a domain research assistant for a data science examine stage.

  Context:
  - Approved question: "{approved question}"
  - Question type: {question type}
  - Target quantity: {target quantity}
  - Claim boundary: {claim boundary}
  - Active route: {active route}
  - Protocol mode: {protocol mode}
  - Examine-stage visibility rules: {visibility rules summary}
  - Visible artifacts used in this cycle: {artifact list}
  - Compact summary of script_evidence for this cycle: {summary}
  - User observations: {decision_ledger entry's user_observations from Step 2, or "none"}

  Answer these research questions for Cycle {X} ({cycle focus}):
  {research_questions list from the cycle YAML}

  Rules:
  - Stay inside the approved question, active route, protocol rules, and visible data.
  - Ask only domain questions that clarify observed structure, anomalies, subgroup patterns, dependencies, measurement artifacts, or support limitations.
  - Cite sources only for claims that would change how the examination is interpreted or how later analysis should respond.
  - Every citation must include its URL inline after the claim it supports.

  Return concise findings with sources, organized by research question. Focus on
  information that changes support characterization, fragility assessment, or
  analysis constraints.
  """
)
```

Evaluation subagent:

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Examine Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a Skeptic examine-stage cycle.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/04_examination.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/04_examination.py
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  4. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.yaml
  5. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.yaml

  Cycle focus: {cycle focus description}
  Cycle YAML for reference: {cycles/{X}.yaml full content}
  Script evidence produced this iteration: {the candidate script_evidence}
  User observations: {decision_ledger entry's user_observations from Step 2, or "none"}

  Produce this structured output, in order, with these exact section headings:

  EVALUATION: Cycle {X} - {focus}

  MISSING REQUIRED EVIDENCE (list required evidence keys or judgment outputs that are absent; evidence with a satisfied skip rule is not missing):
  - Unanswered: [list of IDs, or "none"]

  CYCLE-SPECIFIC PCS QUESTIONS (from `pcs_focus.items`, if any):
  {pcs_focus.items from the cycle YAML, one bullet per item, or "none defined"}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Actively falsify the acceptance criteria and material evidence rather than confirm them. Record only failures or non-obvious risks; do not write PASS notes for every criterion. Categories: unstated
  assumptions, overread exploratory patterns, claim-boundary violations,
  protocol-visibility violations, touches of restricted artifacts, support
  claims not backed by evidence, drift into final analysis, widened scope
  against the active route file.
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

  ROUTE AND CLAIM BOUNDARY CHECK:
  Read upstream.claim_boundary and the route file (active_route) from the
  canonical YAML. Verify that no finding, support characterization, or
  handoff statement in this cycle uses verbs from verbs_forbidden_effective
  or asserts scope beyond the approved claim_boundary. If examination weakens
  support, the narrowing belongs in claim_boundary_narrowing.

  ALTERNATIVES CONSIDERED:
  - Current approach: [description] - Score: [1-10] - [justification]
  - Alt 1: [different framing] - Score: [1-10] - [justification]
  - Alt 2: [different framing] - Score: [1-10] - [justification]

  DESIGN IMPLICATIONS: [constraints or pressures this cycle surfaced for `analyze`, or "none"]
  GAPS REMAINING: [list, or "none"]
  RECOMMENDED FOLLOW-UP CYCLE: [Dn topic and why, or "none"]
  RECOMMENDED BACKTRACK: [none | reopen clean | reopen protocol | reopen formulate_plus_protocol] - [reason]

  FINAL COUNTS:
  Unanswered items: [count]
  Blocking defects: [count]
  Failed criteria: [count]

  Be objective. Not harsh, not lenient.
  """
)
```

When both subagents return, the model parses three counts from the evaluation output: `Unanswered items`, `Blocking defects`, `Failed criteria`. `blocking_failures = unanswered + blocking_defects + failed_criteria`; `blocking_failures == 0` means PASS. Every required evidence key must be produced or formally skipped, and every acceptance criterion must pass or be explicitly overridden.

Digest the subagent replies into `decision_ledger[*].subagents`; the replies themselves stay in memory. Admit something to `subagents` when a future reader needs it to reconstruct why this path was chosen.

Include:
- `research_sources`: URLs that actually tipped a call, each paired with a one-line claim. Drop sources that merely confirmed obvious baseline facts or rephrased what was already known.
- `decisions`: operational choices where a reasonable alternative existed. Tag each with its PCS axis (`P`, `C`, `S`, or `null` when not PCS-relevant). Set `source` to the index into `research_sources` when a specific source drove the call. Default implementation choices that do not affect evidence or interpretation are not decisions.
- `rejected_alternatives`: paths actively weighed and dropped, with the reason and PCS axis. This is the stability counterfactual record.
- `open_risks`: one line each. Unresolved concerns downstream stages must carry forward.

Exclude:
- Prose summaries, meta-commentary, or "the subagent reviewed and confirmed" filler.
- Restatements of required-evidence questions, acceptance-criteria definitions, `research_questions`, or `script_evidence` already on file.
- Per-criterion PASS notes when nothing interesting happened. Only failed or non-obvious criteria whose reasoning belongs in the audit record.
- Sources that confirmed baseline facts without changing behavior.

Keep the schema as the authoritative field list. If something the subagent surfaced has no schema home, fit it into `open_risks` or leave it out.

### Step 4: Decision

When both subagents return:

1. Verify each result is non-empty and contains its required sections. If malformed, escalate to the user (interactive) or follow `../auto-mode.md` (auto).
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
- `reopen_clean` -> stop and reopen `clean`
- `reopen_protocol` -> stop and reopen `protocol`
- `reopen_formulate_plus_protocol` -> stop and reopen `formulate` and then `protocol`
- `data_insufficient` -> log why and present options (request more data, reformulate, archive)
- `archive` -> stop with documentation of why
- `override` -> user states the specific reason a FAIL is incorrect; logged as `override: {reason, criterion}`; forward actions unlock

Interactive mode: present the synthesized assessment and the allowed actions via `AskUserQuestion`. Wait for the user's answer before invoking any other tool.

Auto mode: apply the autonomous decision protocol from `../auto-mode.md`.

If the visible data cannot support the approved question inside the approved claim boundary, choose the matching backtrack action or `data_insufficient`.

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

Re-parse `04_examination.yaml` to confirm validity.

## Ending the Cycle Loop

The loop ends when all of the following hold:

- every mandatory cycle (A, B, C, E) has a closing `decision` of `pass` or an `override`
- every approved follow-up cycle (`D1`, `D2`, ...) is resolved
- interactive mode: the user explicitly approves the fragility review, support registry, and analysis handoff
- auto mode: the stage approval checkpoint in `../auto-mode.md` completes

Finalization requires explicit stage-close discipline.

## PCS Subagent Review

At stage close:

```text
Agent(
  model="{subagent_model}",
  description="PCS review of examine stage",
  prompt="""
  You are a PCS reviewer for a data science examine stage.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/04_examination.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/04_examination.py
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  4. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.yaml
  5. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.yaml

  Evaluate only the incremental risk introduced by examination. Do not restate
  the full formulation, protocol, or cleaning reviews.

  PREDICTABILITY:
  - Did examination characterize what the visible data can support, or did it
    overread first-pass patterns?
  - Does the support registry match what the visible data actually shows?
  - Are future validation needs still framed at the right level?

  STABILITY:
  - Which analysis-contract-relevant structures remained stable under reasonable
    examination alternatives, and which did not?
  - Would a different but still reasonable examination choice materially change
    the support picture or the route strength update?
  - Are fragile patterns correctly classified, or is any fragile pattern being
    carried into the handoff as if it were solid?

  COMPUTABILITY:
  - Is the support characterization and analysis handoff documented clearly
    enough that another analyst could follow it and reproduce it from the
    canonical YAML and script?
  - Are visibility decisions and restricted-artifact boundaries still explicit?
  - Is the audit trail strong enough that another analyst could understand
    why this examination was approved?

  MAIN RISK DRIVER:
  - What examination choice or framing choice introduced the most risk, if any?

  REOPEN CYCLE:
  - Should the examine stage reopen a cycle or route back upstream? Yes or no,
    and why?

  For each lens, state what holds up well, what is uncertain or risky, and any
  specific recommendations. Keep it concise.
  """
)
```

Digest the review into `pcs_review`: record `overall`, `blocking_findings`, `material_risks`, `material_findings`, `disposition`, and `disposition_reason`. Do not store the full review text unless a FAIL or override makes literal audit text necessary; if retained, store only a pointer in `full_review_pointer`.

- Interactive mode: present via `AskUserQuestion` with options `satisfied`, `valid_concern`, `disagree_override`. Wait for the user's answer before invoking any other tool.
- Auto mode: apply `../auto-mode.md` stage-close rules.

Record the chosen disposition and reason in `pcs_review.disposition` and `pcs_review.disposition_reason`.

The subagent advises. It does not silently widen scope or bypass a blocking concern.

## Finalization

After the PCS review clears or the user overrides it:

1. Finalize `fragility_review`: for every analysis-contract-relevant pattern surfaced in Cycles A-C, record the alternatives tested, the verdict (`stable` | `conditional` | `fragile`), and the downstream consequence. Demote any pattern that collapses under reasonable alternatives. If framing itself introduced risk, state it in `framing_incremental_risk`.

2. Finalize `analysis_handoff`: consolidate `supported_aspects`, `weakly_supported_aspects`, and `unsupported_aspects` from the support registry; set `route_strength_update`; list `analysis_constraints`, `unresolved_risks`, `open_issues_for_analyze`, and `tensions`; set `next_stage: analyze` and `contract_selection_disclaimer` stating examine does not select the analysis contract.

3. If examination surfaced recommended narrowing that `formulate` should adopt (added `verbs_forbidden`, tightened `generalization_limit`, narrower `scope`), record each entry in `claim_boundary_narrowing` with its source cycle. Narrowing entries become canonical only when `formulate` is reopened and adopts them; do not mutate the formulation YAML from `examine`.

4. Parse `04_examination.yaml` with a standard YAML loader. Repair if parsing fails.

5. Render `04_examination.md` from the canonical YAML. Keep the report compact: one `##` section per top-level YAML key that is populated (`Upstream Contract`, `Visibility`, `Support Registry`, `Structure Profile`, `Relationships`, `Anomalies and Contradictions`, `Fragility Review`, `Claim Boundary Narrowing` (only when populated), `Analysis Handoff`, `Decision Summary` with one line per cycle, `PCS Assessment`). Omit sections whose YAML keys are empty or absent. Reference the compact `pcs_review` fields through the YAML; the markdown is a rendered summary.

6. Update `README.md` with:

   ```markdown
   ## Examine [COMPLETE]
   Type: {question_type}
   Route: {active_route}
   Protocol mode: {protocol_mode}
   Visibility: {one-line summary from upstream.visibility_rules_summary}
   Support: {one-line summary of what the data appears able to support}
   Main tensions: {one-line summary of main support gaps or anomalies}
   Route pressure: {one-line summary of what inside the active route looks stronger or weaker}
   Next: Analyze - lock and execute the analysis under protocol constraints
   ```

7. Set `status.locked_at: {ISO timestamp}`. Re-parse the YAML to confirm validity.

8. Read `README.md` and include the `## Examine [COMPLETE]` block exactly in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete; return to step 6. Only then tell the user the examine stage is complete.

## Backtracking

If a downstream stage reopens `examine`:

- Preserve every entry in `decision_ledger`. Append new iterations.
- Unlock the stage: set `status.locked_at: null`.
- Re-run the affected cycles and re-render the markdown at the end.
- If the reopen was driven by an `analyze` finding that narrows the claim boundary, update `claim_boundary_narrowing` (and, if the change must propagate to the contract, reopen `formulate` through the standard backtrack path).

If `examine` itself must reopen `clean`, `protocol`, or `formulate_plus_protocol`, close the current examine session with the matching `decision` and `decision_reason`; leave `status.locked_at: null` so examine can resume cleanly after the upstream fix.
