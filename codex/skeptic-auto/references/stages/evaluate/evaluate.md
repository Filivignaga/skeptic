
# /skeptic:evaluate - Route-Appropriate PCS Evaluation

IMPORTANT: Before executing, read `references/core-principles.md`. `core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

Evaluate adjudicates whether analysis outputs survive route-appropriate PCS checks. It receives the locked outputs from `analyze` and renders per-claim survival verdicts. `communicate` receives only claims that survived. If no claims survive, say so and route the project back upstream. Do not manufacture survivable claims from insufficient evidence.

Evaluate does not re-execute analysis, generate new claims, widen the claim boundary, add post-hoc analyses, choose between methods, or package findings for an audience. Implications and recommendations belong to `communicate`.

## Stage Outputs

`evaluate` writes exactly three project-side artifacts plus a README block.

| Path | Role |
|------|------|
| `{scripts_dir_name}/06_evaluation.py` | Single Python file containing one function per cycle (`run_cycle_a`, `run_cycle_b`, ...). Invoked one cycle at a time. Returns a JSON evidence packet on stdout. |
| `{docs_dir_name}/06_evaluation.yaml` | Canonical stage memory. Holds upstream references and a compact evaluation contract, reproducibility results, evaluation plan, per-cycle verdicts, claim survival registry, communicate handoff, cycle history, and PCS (integrity) review. Created at stage start, updated at the end of every cycle. |
| `{docs_dir_name}/06_evaluation.md` | Human-readable report. Rendered once at finalization from the canonical YAML. |
| `{readme_name}` | Short `## Evaluate [COMPLETE]` block added at finalization. |

The canonical YAML is the single source of truth. If the rendered markdown disagrees with the YAML, the YAML wins.

## Required Inputs

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` |

`evaluate` requires completed `formulate`, `protocol`, `clean`, `examine`, and `analyze`. Read these canonical YAMLs at stage start:

- `{docs_dir_name}/01_formulation.yaml`
- `{docs_dir_name}/02_protocol.yaml`
- `{docs_dir_name}/03_cleaning.yaml`
- `{docs_dir_name}/04_examination.yaml`
- `{docs_dir_name}/05_analysis.yaml`
- `{readme_name}`

Also read prior-stage scripts under `{scripts_dir_name}/` for reproducibility checks, protocol-frozen artifacts under `{data_dir_name}/` or the paths named in `02_protocol.yaml`, and cleaned artifacts named in `03_cleaning.yaml`.

If any upstream YAML is missing, incomplete, or contradictory, stop and repair the upstream stage. Do not invent evaluation permissions around gaps.

## Canonical YAML Schema

`06_evaluation.yaml` is the stage's memory. The model initializes it in Cycle A and extends it at the end of every cycle. The script never writes to this file.

Write only fields that apply to the project. Omit fields that would be null; readers treat a missing key as "not applicable."

```yaml
stage: evaluate
schema_version: 3

project:
  name:

status:
  current_cycle:                    # A|B|C|D|E|F|G1|G2|null
  completed_cycles: []
  locked_at: null                   # set at stage close; presence = locked

route:
  active_route:                     # descriptive|exploratory|inferential|predictive|causal|mechanistic
  route_file_loaded:                # path to references/routes/{route}/evaluate.md

upstream_refs:
  - file: skeptic_documentation/01_formulation.yaml
    sections: [approved_question, question_type, target_quantity, decision_context]
    sha256:
  - file: skeptic_documentation/02_protocol.yaml
    sections: [data_usage, validation_logic, prohibitions, backtracking_triggers]
    sha256:
  - file: skeptic_documentation/03_cleaning.yaml
    sections: [data_contract, dataset_fitness_reviews, robustness, claim_boundary_updates]
    sha256:
  - file: skeptic_documentation/04_examination.yaml
    sections: [support_registry, fragility_review, analysis_handoff]
    sha256:
  - file: skeptic_documentation/05_analysis.yaml
    sections: [contract, comparison_table, deviations, claim_boundary, evaluation_handoff]
    sha256:

upstream_contract:                  # compact evaluation-specific interpretation; not a copied upstream block
  approved_question_ref:
  question_type_ref:
  target_quantity_ref:
  claim_boundary_as_narrowed_ref:
  protocol_mode_ref:
  validation_logic_ref:
  analysis_contract_ref:
  flags_for_evaluate_ref:
  examine_support_registry_ref:
  stakeholder_decision_ref:

reproducibility:
  frozen_artifact_hashes: {}        # {path: {provenance_ref, observed_sha256, match: bool}}
  recomputed_metrics: {}            # {analysis_output_name: {expected, observed, match: bool}}

evaluation_plan:
  perturbation_axes: []             # mirrored by reference from analysis_contract for adjudication
  dependency_map_ref:               # dependency map used to expect coupled metric or claim movements
  challengers: []                   # mirrored by reference from analysis_contract for adjudication
  route_specific_checks: []         # enumerated from the loaded route file and mapped to cycles B, C, D
  flag_coverage_map: {}             # {flag_id: {description, affected_claim, assigned_cycle}}
  divergence_triage: {}             # {axis_or_challenger_id: {magnitude, class: minor|notable|major}}

stability_verdicts: {}              # {claim_id: {verdict: stable|conditionally_stable|unstable, evidence, caveats: []}}
predictability_verdicts: {}         # {claim_id: {verdict: adequate|marginal|inadequate, evidence}}
validity_verdicts: {}               # {claim_id: {threats: [{domain, presence, direction, verdict: defended|threatened|fatal}], overall}}

claim_survival_registry: []         # list of {claim_id, description, stability, predictability, validity, deviation_impact, survival_verdict, caveats, evidence_summary}; seeded from 05_analysis.yaml evaluation_handoff.claim_inventory

claim_boundary_final:
  claim_type:
  scope:
  target_quantity:
  verbs_allowed: []
  verbs_forbidden: []
  evidence_ceiling:
  generalization_limit:
  narrowing_log: []                 # appended when evaluate narrows further; each entry: {cycle, prior, new, rationale}

communicate_handoff:
  per_dimension_summaries: {}       # {stability, predictability, validity}
  mandatory_limitations: []         # [{limitation, evidence}] communicate may not drop these
  unresolved_risks: []              # [{risk, what_is_unknown, why}]
  handoff_discipline: []            # list of constraints communicate must respect

backtracking_log: []                # [{cycle, trigger, return_to_stage, rationale}]

decision_ledger: []                   # append-only list, one entry per iteration
pcs_review: null                    # integrity check result at stage close
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
- `claim_boundary_final.narrowing_log` is append-only. Evaluate may tighten the claim boundary; it never widens.
- Write only fields that apply.
- Use only ASCII characters in generated YAML content. Replace em dashes with `--`, curly quotes with straight quotes.

## Cycle Structure

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Intake audit and evaluation plan | Yes |
| B | Stability adjudication | Yes |
| C | Predictability adjudication | Yes |
| D | Threats to validity | Yes |
| E | Claim survival determination | Yes |
| F | Evaluation assembly and handoff | Yes |
| G1, G2, ... | Follow-ups | Conditional |

Follow-up cycles resolve a material ambiguity from Cycles B, C, or D that must be settled before Cycle E. Open them only when the ambiguity affects claim survival.

## Per-cycle Reference Files

Before running cycle X, load only `cycles/{X}.yaml`. Each cycle YAML carries:

- `upstream`: canonical-YAML fields that must be set before the cycle starts
- `setup_side_effects`: one-time actions (typically Cycle A only); omit when empty
- `required_evidence`: evidence keys or judgment outputs the cycle must produce
- `acceptance_criteria`: 3-5 verifiable conditions for cycle closure
- `writes`: mapping from evidence or judgment outputs to canonical-YAML fields
- `research_questions`: topics for the research subagent
- `guidance`: short, cycle-specific judgment rules
- decision-relevance check: for material judgments, name the plausible alternative most likely to change a downstream decision and store it in the relevant analytical field, not a new log
- `step4_additions`, `pcs_focus`, `log_extension`: present only when the cycle adds a specific discipline. `pcs_focus` holds cycle-specific PCS questions injected into the evaluation subagent prompt; it has no separate Step 5 application.

Follow-up cycles use `cycles/G_template.yaml` as a starting shape. Materialize the concrete Gn spec inside the canonical YAML (not as a new file on disk) when a follow-up is opened.

## Cycle Protocol

This protocol applies to every cycle, mandatory or follow-up.

### Step 1: Setup and Execution

1. Read `cycles/{cycle}.yaml`.
2. Recover prior stage state:
   - Cycle A: read upstream canonical YAMLs (`01_formulation.yaml`, `02_protocol.yaml`, `03_cleaning.yaml`, `04_examination.yaml`, `05_analysis.yaml`) and the `README.md`. Resolve the active route from `contract.question_type` in `01_formulation.yaml` cross-checked against the active route recorded in `02_protocol.yaml`. If they contradict or do not collapse to one route, stop and reopen `protocol`. Load the matching `references/routes/{route}/evaluate.md` once and keep it in context for the rest of the stage.
   - First cycle entered in a fresh session (not Cycle A), or first cycle after a backtrack reopens the stage: read `06_evaluation.yaml` once to load the upstream snapshot, evaluation plan, verdicts, and prior `decision_ledger`. Reload the same route file named in `route.route_file_loaded`.
   - Every other case (continuing the same chat session): skip the re-read; the canonical YAML content is already in context from the cycle that just wrote it.
3. Cycle A only: initialize `06_evaluation.yaml` with `stage`, `schema_version`, `project`, `status.current_cycle: A`, `route.active_route`, and `route.route_file_loaded`; create `06_evaluation.py` with the shape specified below.
4. Every cycle: extend `06_evaluation.py` by writing or updating the cycle's function (`run_cycle_a`, `run_cycle_b`, ...). The function must produce every required evidence key named by the cycle spec.
5. Run `python {scripts_dir_name}/06_evaluation.py --cycle {cycle}`. Capture stdout.
6. Parse stdout as JSON. Use the parsed dict as this cycle's candidate evidence for Step 2 and Step 3; Step 5 records a compact summary in `decision_ledger[*].script_evidence`. Do not retain raw stdout by default. Write a debug sidecar only when the cycle fails, is rerun for diagnosis, or the user asks for retained raw evidence.
7. Scan stderr and stdout for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing. Functions that intentionally demonstrate failure must be explicitly flagged with a `# expected_failure` comment.

If route context becomes ambiguous mid-stage, reread `01_formulation.yaml`, `02_protocol.yaml`, `05_analysis.yaml`, and the same route file before proceeding. If the active route cannot be resolved or the expected route file is missing, stop and route back upstream.

Script contract: generate `06_evaluation.py` for the current project and follow `references/script-contract.md`. Include only the helpers needed to read upstream canonical YAMLs, inspect analysis outputs, and produce route-appropriate evaluation evidence.

Script rules:
- The script prints exactly one JSON object to stdout. Nothing else on stdout.
- The script does not write to `06_evaluation.yaml`. Only the model writes the canonical YAML.
- Heavy data (arrays, full DataFrames) is summarized, not dumped. Evidence packets stay compact.
- Per-file provenance (schema, encoding, sha256) is emitted only the first time a file is recorded -- typically Cycle A iter 1. After it lands in `provenance.files`, neither the stdout packet nor `decision_ledger[*].script_evidence` re-emits those fields; downstream cycles reference those files by filename.
- Seeds are set inside the function if any stochastic step runs.
- The script does not re-execute analysis. It verifies hashes, recomputes declared metrics for reproducibility, executes the protocol-specified reality check, applies route-specific formal tools, and computes divergence statistics. It does not fit new models or produce new claims.
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
  description="Methodological research for Evaluate Cycle {X}: {focus}",
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
  - Script evidence produced this iteration: {compact summary of script_evidence}
  - User observations: {decision_ledger entry's user_observations from Step 2, or "none"}

  Answer these research questions for Cycle {X} ({cycle focus}):
  {research_questions list from the cycle YAML}

  Rules:
  - Stay inside the approved question, protocol, and active route.
  - Focus on methodological adjudication guidance, not domain discovery or method selection.
  - If a question does not apply, say "not applicable" with a one-line reason.
  - Cite sources for claims that would change an evaluation verdict.

  Return concise findings organized by research question. Create or reference a `research_log.jsonl` row only for sources that materially change a decision or will be cited in a deliverable; canonical YAML keeps only `research_log#n` pointers.
  """
)
```

Evaluation subagent:

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Evaluate Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a Skeptic evaluate-stage cycle.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/06_evaluation.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/06_evaluation.py
  3. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  4. {projects_root}/{project-name}/{docs_dir_name}/02_protocol.yaml
  5. {projects_root}/{project-name}/{docs_dir_name}/03_cleaning.yaml
  6. {projects_root}/{project-name}/{docs_dir_name}/04_examination.yaml
  7. {projects_root}/{project-name}/{docs_dir_name}/05_analysis.yaml
  8. The route file named in route.route_file_loaded

  Cycle focus: {cycle focus description}
  Cycle YAML for reference: {cycles/{X}.yaml full content}
  Script evidence produced this iteration: {the candidate script_evidence}
  User observations: {decision_ledger entry's user_observations from Step 2, or "none"}

  Claim boundary integrity rule:
  The claim boundary as-narrowed from analyze is the ceiling. Evaluate may narrow
  further but never widen. Any move, verdict, caveat, or handoff text that widens
  scope, loosens generalization_limit, or uses verbs outside verbs_allowed is a
  BLOCKING defect.

  Route overlay rule:
  The loaded route file may narrow or prohibit actions. Honor every route-specific
  prohibition. Any move beyond the route overlay is a BLOCKING defect.

  Produce this structured output, in order, with these exact section headings:

  EVALUATION: Cycle {X} - {focus}

  MISSING REQUIRED EVIDENCE (list required evidence keys or judgment outputs that are absent; evidence with a satisfied skip rule is not missing):
  - Unanswered: [list of IDs, or "none"]

  CYCLE-SPECIFIC PCS QUESTIONS (from `pcs_focus.items`, if any):
  {pcs_focus.items from the cycle YAML, one bullet per item, or "none defined"}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Actively falsify the acceptance criteria and material evidence rather than confirm them. Record only failures or non-obvious risks; do not write PASS notes for every criterion. Categories: re-executed analysis, new claims,
  widened claim boundary, post-hoc testing, audience framing, method comparison,
  unauthorized holdout access, unstated assumptions, unverifiable evidence,
  construct validity drift. If after genuinely adversarial scrutiny you find zero
  defects, state "No defects found" and name at least three specific failure modes
  you tested and ruled out. Do not fabricate defects.
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
  BACKTRACKING IMPLICATIONS: [trigger IDs this cycle surfaced, or "none"]
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
- `reopen_analyze` -> stop and reopen `analyze`
- `reopen_examine` -> stop and reopen `examine`
- `reopen_protocol` -> stop and reopen `protocol`
- `reopen_formulate` -> stop and reopen `formulate` plus `protocol`
- `archive` -> stop with documentation of why
- `override` -> user states the specific reason a FAIL is incorrect; logged as `override: {reason, criterion}`; forward actions unlock

If backtracking is chosen, append a `backtracking_log` entry with `{cycle, trigger, return_to_stage, rationale}` and preserve the full `decision_ledger` when the stage reopens.

Interactive mode: present the synthesized assessment and the allowed actions via `AskUserQuestion`. Wait for the user's answer before invoking any other tool.

Auto mode: apply the autonomous decision protocol from `references/auto-mode.md`.

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

Re-parse `06_evaluation.yaml` to confirm validity.

## Ending the Cycle Loop

The loop ends when all of the following hold:

- every mandatory cycle (A through F) has a closing `decision` of `pass` or an `override`
- every approved follow-up cycle (G1, G2, ...) is resolved
- interactive mode: the user explicitly approved the claim survival registry in Cycle E
- auto mode: the stage approval checkpoint in `references/auto-mode.md` completes

Finalization requires explicit stage-close discipline.

## PCS Subagent Review

Evaluate is itself the PCS checkpoint for the project's claims. The stage-close review is a mechanical integrity audit, not a meta-PCS review of evaluate's own reasoning. Dispatch at stage close:

```text
Agent(
  model="{subagent_model}",
  description="Evaluate stage integrity check",
  prompt="""
  You are an integrity auditor for a Skeptic evaluate stage.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/06_evaluation.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/06_evaluation.py
  3. {projects_root}/{project-name}/{docs_dir_name}/05_analysis.yaml
  4. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml

  Perform these mechanical checks:

  COMPLETENESS:
  - Does every claim in the analysis contract from 05_analysis.yaml have exactly
    one row in claim_survival_registry? List missing claims.

  CONSISTENCY:
  - Does any "survived" verdict in claim_survival_registry contradict a failed criterion
    logged in decision_ledger for Cycles B, C, or D? List contradictions.

  FLAG COVERAGE:
  - Was every flag in upstream.flags_for_evaluate addressed in at least one
    decision_ledger entry? List unaddressed flags.

  BOUNDARY INTEGRITY:
  - Is claim_boundary_final equal to or narrower than upstream.claim_boundary_as_narrowed
    on every axis (scope, generalization_limit, verbs_allowed, evidence_ceiling)?
    Flag any widening.

  REGISTRY DISCIPLINE:
  - If evaluate narrowed the claim boundary, does claim_boundary_final.narrowing_log
    contain an entry with {cycle, prior, new, rationale}? List missing narrowing entries.

  SCOPE DISCIPLINE:
  - Does any cycle log contain evidence of re-executing analysis, generating new
    claims, post-hoc testing, audience framing, or method comparison? Flag any
    violations.

  REQUIRED EVIDENCE COVERAGE:
  - For each cycle, were all required evidence keys produced or explicitly skipped, and did all acceptance criteria pass or get explicitly overridden?

  Output each check as PASS or FAIL with specifics. End with OVERALL: PASS or FAIL.
  Be objective.
  """
)
```

Digest the review into `pcs_review`: record `overall`, `blocking_findings`, `material_risks`, `material_findings`, `disposition`, and `disposition_reason`. Do not store the full review text unless a FAIL or override makes literal audit text necessary; if retained, store only a pointer in `full_review_pointer`.

- Interactive mode: present via `AskUserQuestion` with options `satisfied`, `valid_concern`, `disagree_override`. Wait for the user's answer before invoking any other tool.
- Auto mode: apply `references/auto-mode.md` stage-close rules.

If any check FAILs, identify the cycle that introduced the problem and reopen it. Do not proceed to finalization until the integrity check is PASS or the user records an explicit `disagree_override` with rationale.

Record the chosen disposition and reason in `pcs_review.disposition` and `pcs_review.disposition_reason`.

## Finalization

After the integrity check clears or the user overrides it:

1. Finalize `claim_boundary_final`. If evaluate narrowed the claim boundary, ensure `narrowing_log` contains the entry with prior and new boundaries plus rationale. Evaluate may tighten `scope`, `generalization_limit`, `verbs_allowed` (by moving entries to `verbs_forbidden`), and `evidence_ceiling`. It may not loosen any of them.

2. Parse `06_evaluation.yaml` with a standard YAML loader. Repair if parsing fails.

3. Render `06_evaluation.md` from the canonical YAML. Keep the report compact: one `##` section per top-level YAML key that is populated (`Upstream Contract`, `Reproducibility`, `Evaluation Plan`, `Stability`, `Predictability`, `Threats to Validity`, `Claim Survival Registry`, `Final Claim Boundary`, `Communicate Handoff`, `Backtracking Events`, `Integrity Check`). Omit sections whose YAML keys are empty or absent. Reference the compact `pcs_review` fields through the YAML; the markdown is a rendered summary.

4. Update `README.md` with:

   ```markdown
   ## Evaluate [COMPLETE]
   Type: {question_type}
   Active route: {active_route}
   Claims assessed: {n}
   Claims survived: {n} ({n} with caveats)
   Claims did not survive: {n}
   Stability: {one-line summary}
   Predictability: {one-line summary}
   Main limitations: {one-line summary of mandatory limitations}
   Next: Communicate - package only claims that survived evaluation
   ```

5. Set `status.locked_at: {ISO timestamp}`. Re-parse the YAML to confirm validity.

6. Read `README.md` and include the `## Evaluate [COMPLETE]` block exactly in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete; return to step 4. Only then tell the user the evaluate stage is complete and the next stage is `communicate`.

## Backtracking

Evaluate may trigger backtracking to any upstream stage. Record each trigger in `backtracking_log` and preserve the full `decision_ledger`.

| Trigger | Typical cycle of discovery | Return to |
|---------|---------------------------|-----------|
| All claims fail stability across the analysis contract | B | `analyze` (revise perturbation plan or contract) or `protocol` (validation logic mis-specified) |
| Predictability reality check contradicts the primary result | C | `analyze` (execution sound but result fails reality) or `protocol` (reality check mis-specified) |
| A validity threat is fatal -- unmeasured confounder plausibly explains the entire result, or construct validity has drifted beyond repair | D | `formulate` + `protocol` if the question is unanswerable with this data, or `analyze` if a different specification might survive |
| Deviation register entries materially compromised the analysis | A | `analyze` (re-execute with corrected contract) |
| No claims survive evaluation | E | `protocol` (reassess achievable claims) or `formulate` (question itself unanswerable) |
| Claim boundary must widen to produce any meaningful communication | E | `formulate` + `protocol`; widening is never allowed within evaluate |

All challengers producing materially different results from the primary is NOT a backtracking trigger on its own. It is a finding that informs the stability verdict in Cycle B. Evaluate does not backtrack based on result quality alone; it backtracks based on adjudicated instability, validity fatality, or boundary-widening necessity.

If a downstream stage (communicate) later reopens `evaluate`:

- Preserve every entry in `decision_ledger`. Append new iterations.
- Unlock the stage: set `status.locked_at: null`.
- Re-run the affected cycles and re-render the markdown at the end.
- `claim_boundary_final.narrowing_log` entries remain in place.
