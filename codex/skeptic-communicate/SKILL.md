---
name: skeptic-communicate
description: Skeptic communication of evaluated results. Use after formulate, protocol, clean, examine, analyze, and evaluate to package only claims that survived evaluation for the intended audience, without upgrading claims, widening the claim boundary, or introducing new analysis. Terminal stage of Skeptic. Use when Codex should run the Skeptic communicate stage as a standalone skill, including requests like skeptic communicate --auto to run this stage with autonomous cycle execution.
---


## Codex Invocation

Use this skill for `skeptic communicate`. If the user writes `skeptic communicate --auto`, run this same stage in auto mode: read `references/auto-mode.md` and apply its autonomous cycle protocol only to the `communicate` stage. This folder is self-contained for this stage.

# /skeptic:communicate - Communication of Evaluated Results

IMPORTANT: Before executing, read `references/core-principles.md`. `core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

`communicate` is the terminal stage. There is no downstream stage to catch errors. Every fidelity violation -- claim inflation, caveat suppression, boundary widening, misleading visualization, narrative overreach -- goes directly to the audience. Package only claims that survived `evaluate`, with their mandatory caveats, for the identified audience. Translate. Present. Do not re-analyze, re-evaluate, or generate new claims.

## Stage Outputs

`communicate` writes exactly three project-side artifacts plus a README block plus the audience-facing deliverables. Compact state lives in the canonical YAML.

| Path | Role |
|------|------|
| `{scripts_dir_name}/07_communication.py` | Single Python file containing one function per cycle (`run_cycle_a`, `run_cycle_b`, `run_cycle_c`, `run_cycle_d`, `run_cycle_e`, `run_cycle_f`). Invoked one cycle at a time. Returns a JSON evidence packet on stdout. Read-only against upstream artifacts; read-and-scan against `deliverables/`. |
| `{docs_dir_name}/07_communication.yaml` | Canonical stage memory. Holds upstream references and a compact communication contract, communication plan, audience profile, translations, recommendations, deliverable metadata, cycle history, and the terminal fidelity review. Created at stage start, updated at the end of every cycle. |
| `{docs_dir_name}/07_communication.md` | Human-readable report. Rendered once at finalization from the canonical YAML. |
| `deliverables/` | Audience-facing deliverables. Contains exactly one primary deliverable plus zero or more companion data files. Created/reused at Cycle A. |
| `{readme_name}` | Short `## Communicate [COMPLETE]` block added at finalization. |

The canonical YAML is the single source of truth. If the rendered markdown or the deliverable content disagrees with the YAML, the YAML wins for process state; the deliverable is the audience product and must be re-rendered to match.

## Required Inputs

| Input | Description |
|-------|-------------|
| Project folder path | Path to an existing project under the configured `projects_root` |

`communicate` requires completed `formulate`, `protocol`, `clean`, `examine`, `analyze`, and `evaluate`. Cycle A verifies that the following upstream artifacts exist and contain the sections listed:

- `{docs_dir_name}/01_formulation.yaml` and `.md` -- approved question, question type, target quantity, initial claim boundary, decision_context, unit of analysis, key assumptions
- `{docs_dir_name}/02_protocol.yaml` and `.md` -- active route, data-usage mode, validation logic, leakage rules, prohibitions
- `{docs_dir_name}/03_cleaning.yaml` and `.md` -- final variable list, population-shift summary
- `{docs_dir_name}/04_examination.yaml` and `.md` -- support registry summary
- `{docs_dir_name}/05_analysis.yaml` and `.md` -- analysis contract, deviation register, claim boundary as narrowed
- `{docs_dir_name}/06_evaluation.yaml` and `.md` -- claim survival registry, final claim boundary, per-dimension summaries (stability, predictability, validity), mandatory limitations, unresolved risks, communicate handoff, handoff discipline
- `{readme_name}` -- confirms prior stage completion

If any upstream artifact or required section is missing or contradictory, stop at Cycle A and route back to the appropriate upstream stage. Do not invent communication permissions around gaps.

The evaluate handoff is the primary input. Keep its content -- claim survival registry, final claim boundary, mandatory limitations, unresolved risks, handoff discipline -- in active context throughout the stage.

No additional user input is required at stage start. The audience is identified during Cycle B via `AskUserQuestion`.

## Canonical YAML Schema

`07_communication.yaml` is the stage's memory. The model initializes it in Cycle A and extends it at the end of every cycle. The script never writes to this file.

Write only fields that apply to the project. Omit fields that would be null; readers treat a missing key as "not applicable."

```yaml
stage: communicate
schema_version: 3

project:
  name:
  started_at:                       # ISO date of this stage's start

status:
  current_cycle:                    # A|B|C|D|E|F|null
  completed_cycles: []
  locked_at: null                   # set at stage close; presence = locked

upstream_snapshot:                  # read-only snapshot from upstream artifacts
  approved_question:
  question_type:
  target_quantity:
  claim_boundary:                   # final boundary from evaluate (claim_type, scope, evidence_ceiling, generalization_limit, verbs_allowed/forbidden effective set)
  active_route:
  decision_context:                 # from formulate (stakeholder, actions, how_answer_changes_action, or academic alt)
  claim_survival_registry: []       # [{claim_id, statement, verdict, caveats, evidence_summary}]
  mandatory_limitations: []         # [{description, source}]
  unresolved_risks: []              # [{description, source}]
  handoff_discipline:               # literal handoff discipline statement from evaluate

upstream_contract:                  # compact communication-specific interpretation; not a copied upstream block
  approved_question_ref:
  question_type_ref:
  target_quantity_ref:
  claim_boundary_final_ref:
  active_route_ref:
  decision_context_ref:
  claim_survival_registry_ref:
  mandatory_limitations_ref:
  unresolved_risks_ref:
  handoff_discipline_ref:

plan:                               # derived in Cycle A from upstream_contract refs
  null_result_mode:                 # bool
  claims_to_communicate: []         # claim_ids
  limitations_to_disclose: []
  recommendations_possible: []
  sections_required: []             # default is the five mandatory sections
  decision_support_verified:        # bool; Cycle A09

audience:                           # set in Cycle B
  type:                             # customers|internal_team|technical_reviewers|executives|regulators|other
  technical_level:                  # non_technical|semi_technical|technical
  decision_context:
  action_capacity:
  expected_format:
  user_approved_at:                 # ISO timestamp of approval

delivery:                           # set in Cycle B
  format:
  format_justification:
  medium:
  layers: []                        # [{name, depth, sections: []}]
  scaffolding:
    section_structure: []
    depth_calibration: {}
    tone:
    vocabulary_register:
    jargon_translation: {}          # {term: plain_equivalent}

translations: []                    # set in Cycle C
  # [{claim_id, source_verdict, translated_text, language_strength, caveats_visible_list, boundary_respected}]

dead_claim_framings: []             # set in Cycle C
  # [{claim_id, limitation_text, reason_from_registry}]

recommendations: []                 # set in Cycle C
  # [{recommendation, parent_claim_id, caveats_inherited, within_boundary}]

boundary:
  narrowing: null                   # or {from, to, reason, cycle}; absent/null = unchanged from evaluate final boundary

uncertainty:                        # set in Cycle D
  depth_tier:                       # entry_level|informed|technical
  stability_summary_per_claim: {}   # {claim_id: stability_statement}
  predictability_summary:
  perturbation_axes_disclosed: []
  scope_disclosure:                 # what was tested AND what was not
  calibration_notes:                # guard against overstatement or understatement

visualizations: []                  # set in Cycle E
  # [{claim_id, primary_format, alternative_formats: [], stability_of_takeaway, chosen_format, uncertainty_encoding, misleading_violations: [], self_contained}]

deliverable:                        # set in Cycle F
  primary:
    path:
    filename:
    format:
    sections_present: []            # [Question, Findings, Confidence, Limitations, Methods Summary]
    self_sufficient:
    question_led:
    methods_grounded:
    problems_disclosed:
    encoding_scan:                  # ascii_clean|violations_found
  companion_files: []
    # [{path, filename, role, has_data_dictionary, temporal_columns_disambiguated, degeneracy_check}]

decision_ledger: []                   # append-only list, one entry per iteration
pcs_review: null                    # set at stage close; holds Terminal Fidelity Review
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
`pcs_review` when set (holds the Terminal Fidelity Review):

```yaml
pcs_review:
  overall:                          # PASS|FAIL, satisfied|valid_concern|disagree_override, or route-specific terminal verdict
  checks: {}                        # terminal fidelity checks parsed to PASS|FAIL|N/A
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
- `communicate` may narrow the claim boundary via `boundary.narrowing`. It may not widen it. Widening forces backtrack to `formulate` plus `protocol`.
- `upstream_refs` and `upstream_contract` are read-only after Cycle A closes. If upstream content changes, backtrack instead of rewriting the references or compact contract.
- Write only fields that apply.
- Use only ASCII characters in generated YAML content. Replace em dashes with `--`, curly quotes with straight quotes. Source-data strings may keep non-ASCII when the encoding is declared.

## Cycle Structure

| Cycle | Focus | Mandatory |
|-------|-------|-----------|
| A | Intake Audit and Communication Plan | Yes |
| B | Audience and Delivery Framing | Yes |
| C | Claim Translation and Caveat Calibration | Yes |
| D | Uncertainty and Evidence Presentation | Yes |
| E | Visualization and Representation Integrity | Yes |
| F | Communication Assembly and Terminal Fidelity Audit | Yes |

All six cycles are mandatory. There is no follow-up window. If a cycle uncovers issues that require rework on an earlier cycle, the standard Step 4 decision handles iteration. If the issue is upstream, backtrack per the rules below.

Null-result handling: when Cycle A determines `plan.null_result_mode: true` (zero claims survived), Cycles C through E run lighter (fewer or no surviving claims to translate or visualize). The same cycle protocol applies. The deliverable at Cycle F documents what was attempted and why nothing survived.

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

## Cycle Protocol

This protocol applies to every cycle.

### Step 1: Setup and Execution

1. Read `cycles/{cycle}.yaml`.
2. Resolve route context:
   - Cycle A: before anything else, verify every upstream artifact listed under Required Inputs exists and contains the expected sections. Abort with a concrete failure list if a precondition is violated; do not silently continue. Then read `01_formulation.yaml`, `02_protocol.yaml`, ..., `06_evaluation.yaml` once to load the upstream contract, the claim survival registry, the final claim boundary, mandatory limitations, unresolved risks, and handoff discipline. Resolve the active route from `02_protocol.yaml` (and the as-narrowed route from `05_analysis.yaml`). `communicate` does not load a route-specific overlay file: the route-specific constraints arrive encoded in the evaluate handoff. Keep the active route in memory so Step 3 subagents inherit it.
   - First cycle entered in a fresh session (not Cycle A), or first cycle after a backtrack reopens the stage: read `07_communication.yaml` once to load upstream_snapshot, plan, audience, delivery, translations, recommendations, boundary, and prior `decision_ledger`. The route context lives inside `upstream_snapshot.active_route`.
   - Every other case (continuing the same chat session): skip the re-read; the canonical YAML content is already in context from the cycle that just wrote it.
3. Cycle A only: create `deliverables/` under the project root if it does not already exist. Initialize `07_communication.yaml` with `stage`, `schema_version`, `project` (including `project.started_at` as ISO timestamp), `status.current_cycle: A`, and the `upstream_snapshot` scaffold populated from the upstream artifacts. Create `07_communication.py` with the shape specified below.
4. Every cycle: extend `07_communication.py` by writing or updating the cycle's function (`run_cycle_a`, `run_cycle_b`, ...). The function must produce every required evidence key named by the cycle spec.
5. Run `python {scripts_dir_name}/07_communication.py --cycle {cycle}`. Capture stdout.
6. Parse stdout as JSON. Use the parsed dict as this cycle's candidate evidence for Step 2 and Step 3; Step 5 records a compact summary in `decision_ledger[*].script_evidence`. Do not retain raw stdout by default. Write a debug sidecar only when the cycle fails, is rerun for diagnosis, or the user asks for retained raw evidence.
7. Scan stderr and stdout for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing. Functions that intentionally demonstrate failure must be explicitly flagged with a `# expected_failure` comment.

Script contract: generate `07_communication.py` for the current project and follow `references/script-contract.md`. Include only read-only helpers needed to inspect upstream artifacts and produce presentation-level evidence. Do not compute new statistics, fit models, or query raw/cleaned data for new claims.

Script rules:
- The script prints exactly one JSON object to stdout. Nothing else on stdout.
- The script does not write to `07_communication.yaml`. Only the model writes the canonical YAML.
- The script only scans and extracts. It does not compute new statistics, fit new models, or run new queries on raw or cleaned data. The only admissible script computations are presentation-level scans: ASCII encoding check, section-presence scan, data-dictionary scan, degeneracy count over existing companion files, regex diffs between deliverable text and the evaluate claim survival registry.
- Heavy data (arrays, full DataFrames) is summarized, not dumped. Evidence packets stay compact.
- Per-file provenance (schema, encoding, sha256) is emitted only the first time a file is recorded -- typically Cycle A iter 1. After it lands in `provenance.files`, neither the stdout packet nor `decision_ledger[*].script_evidence` re-emits those fields; downstream cycles reference those files by filename.
- Seeds are set inside the function if any stochastic step runs.
- Stable helper functions or sibling helper modules are allowed when they reduce duplication and improve reproducibility. Helpers must be deterministic, documented briefly, and must not write canonical YAML or access restricted artifacts.

### Step 2: Human Review

Interactive mode:
1. Present the script evidence inline, concisely.
2. Scan the evidence for ambiguities, decision points the model cannot resolve alone, and research topics worth seeding into Step 3 beyond the cycle's default research_questions.
3. If at least one such item exists, dispatch `AskUserQuestion` with 1-3 questions targeting them. Otherwise proceed directly to Step 3. Cycle B always has at least one ambiguity by design (the audience is not yet identified); the AskUserQuestion dispatch in Cycle B carries the audience questions listed in `cycles/B.yaml`.
4. When AskUserQuestion was dispatched, record the user's answers as `user_observations` in the pending decision_ledger entry. Pass them into Step 3 subagent prompts via the `User observations:` field.

Auto mode: apply the self-review loop from `references/auto-mode.md`. Self-correct within the configured budget, then proceed unless an escalation trigger fires.

### Step 3: Subagent Review

Run subagents only when the cycle risk warrants it. Use the research subagent only when outside domain or methodological information can materially change a decision. Use the evaluation subagent on high-risk cycles, unresolved blocking issues, or stage close; otherwise perform the acceptance-criteria check inline.

Research subagent:

```text
Agent(
  model="{subagent_model}",
  description="Domain research for Communicate Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are a communication-conventions research assistant for a data science
  communicate stage.

  Context:
  - Approved question: "{approved question}"
  - Question type: {question type}
  - Target quantity: {target quantity}
  - Final claim boundary: {final claim boundary, literal}
  - Active route: {active route}
  - Audience: {audience description from Cycle B, or "not yet identified" if Cycle A or B}
  - Delivery format: {format from Cycle B, or "not yet chosen" if Cycle A or B}
  - Script evidence for this cycle: {compact summary of script_evidence}

  User observations: {decision_ledger entry's user_observations from Step 2, or "none"}

  Answer these research questions for Cycle {X} ({cycle focus}):
  {research_questions list from the cycle YAML}

  Rules:
  - Focus on communication conventions, not domain discovery or method selection.
  - Research audience-appropriate presentation standards, visualization conventions,
    uncertainty communication formats, and reporting guidelines.
  - If a question does not apply, say "not applicable" with a one-line reason.
  - Create or reference a `research_log.jsonl` row only for sources that materially change a decision or will be cited in a deliverable; canonical YAML keeps only `research_log#n` pointers.

  Return concise findings organized by question. Focus on facts that materially
  change communication decisions.
  """
)
```

Evaluation subagent:

```text
Agent(
  model="{subagent_model}",
  description="Evaluation for Communicate Cycle {X}: {focus}",
  run_in_background=true,
  prompt="""
  You are an objective evaluator for a data science communicate-stage cycle.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/07_communication.yaml
  2. {projects_root}/{project-name}/{scripts_dir_name}/07_communication.py
  3. {projects_root}/{project-name}/{docs_dir_name}/06_evaluation.yaml
  4. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml
  5. (Cycle F only) the rendered deliverable file(s) under {projects_root}/{project-name}/deliverables/

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
  Assume the work contains errors. Actively falsify the acceptance criteria and material evidence rather than confirm them. Record only failures or non-obvious risks; do not write PASS notes for every criterion. Categories: claim inflation,
  caveat suppression, boundary widening, computation-boundary violations,
  recommendation overreach, selective reporting, visualization misleading,
  audience mismatch, narrative overreach, encoding corruption, data-dictionary
  gaps, value degeneracy, temporal-column ambiguity.
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

  FIDELITY CHECK (Cycles C, D, F):
  - Claim fidelity: all claims faithful | {n} issues found
  - Computation boundary: respected | violation found: [description]
  - Claim boundary: unchanged | narrowed from {X} to {Y} because {reason} | WIDENED (flag as blocking)

  DECISION-RELEVANT COUNTERFACTUAL:
  - Strongest plausible alternative that would change a downstream decision: [alternative, affected decision, why accepted/rejected]

  GAPS REMAINING: [list, or "none"]
  RECOMMENDED NEXT STEP: pass | iterate on {topic} | acknowledge gap | reopen evaluate | reopen formulate+protocol

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
- `reopen_evaluate` -> stop and reopen `evaluate` when surviving claims cannot be faithfully communicated within their boundary, or when mandatory caveats make a claim so hedged it communicates no useful information
- `reopen_formulate_protocol` -> stop and reopen `formulate` plus `protocol` when surviving claims do not address the original question at a useful level, or when the claim boundary would have to widen to produce any meaningful deliverable
- `null_result` -> confirm the null-result path already activated in Cycle A; valid when zero claims survived
- `archive` -> stop with documentation of why
- `override` -> user states the specific reason a FAIL is incorrect; logged as `override: {reason, criterion}`; forward actions unlock

Interactive mode: present the synthesized assessment and the allowed actions via `AskUserQuestion`. Wait for the user's answer before invoking any other tool.

Auto mode: apply the autonomous decision protocol from `references/auto-mode.md`.

`communicate` cannot backtrack to `analyze`, `clean`, or `examine`. If the issue is analytical, route through `evaluate` first.

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

Re-parse `07_communication.yaml` to confirm validity.

## Ending the Cycle Loop

The loop ends when all of the following hold:

- every mandatory cycle (A through F) has a closing `decision` of `pass` or an `override`, or the stage closed with `null_result` documented
- interactive mode: the user has explicitly approved the audience identification in Cycle B and has approved the assembled deliverable in Cycle F
- auto mode: the stage approval checkpoint in `references/auto-mode.md` completes

Finalization requires explicit stage-close discipline.

## PCS Subagent Review

At stage close, dispatch the Terminal Fidelity Review. It independently verifies that the rendered deliverable faithfully represents the evaluate handoff, without claim inflation, caveat suppression, boundary widening, or computation-boundary violations.

```text
Agent(
  model="{subagent_model}",
  description="Terminal fidelity review for communicate stage",
  prompt="""
  You are a terminal fidelity auditor for a Skeptic communicate stage.

  Read:
  1. {projects_root}/{project-name}/{docs_dir_name}/06_evaluation.yaml and 06_evaluation.md
  2. {projects_root}/{project-name}/{docs_dir_name}/07_communication.yaml
  3. {projects_root}/{project-name}/{scripts_dir_name}/07_communication.py
  4. Every file under {projects_root}/{project-name}/deliverables/
  5. {projects_root}/{project-name}/{docs_dir_name}/01_formulation.yaml

  Perform these mechanical checks and report each as PASS, FAIL, or N/A with
  evidence. Lenses below apply PCS to the terminal artifact: Computability
  covers mechanical fidelity and reproducibility; Stability covers whether
  the communicated claims survive alternative reasonable readings without
  changing substance; Predictability covers whether the audience can apply
  the findings without the analyst's help.

  1. CLAIM COMPLETENESS: Every claim from the evaluate claim survival registry
     appears in the deliverable. Survived and survived-with-caveats claims in
     Findings. Did-not-survive claims in Limitations.

  2. CAVEAT PRESERVATION: Every mandatory caveat from the evaluate handoff is
     present in the deliverable, visible and substantive (not buried in a
     footnote or appendix).

  3. CLAIM FIDELITY: No claim was upgraded from its evaluate verdict. No
     "survived with caveats" claim reads as if it survived without caveats.
     No "did not survive" claim reads as if the evidence was almost sufficient.

  4. BOUNDARY INTEGRITY: The final claim boundary in the deliverable equals or
     is narrower than the final claim boundary from evaluate. No sentence
     exceeds verbs_allowed (per claim_type + any verbs_forbidden_added),
     scope, or generalization_limit. If communicate narrowed, boundary.narrowing
     is populated with reason and cycle.

  5. LIMITATION COMPLETENESS: All mandatory limitations from the evaluate
     handoff are in the Limitations section. Unresolved risks are present.

  6. RECOMMENDATION SCOPE: Every recommendation cites its parent claim, stays
     within the claim boundary, and inherits the caveats of its parent.

  7. COMPUTATION BOUNDARY: The deliverable and the script contain no new
     statistics, new queries, new models, or any computation that changes the
     substance of a finding. Presentation-level transformations only.

  8. SELF-SUFFICIENCY: Someone with no prior project context can understand
     the deliverable. Technical terms are explained. The opening is
     question-led, not method-led.

  9. MANDATORY SECTIONS: All five mandatory sections are present (Question,
     Findings, Confidence, Limitations, Methods Summary). Methods Summary
     states provenance, processing, route, and what was actually done in plain
     language, and includes intended-use and prohibited-use statements.

  10. ENCODING INTEGRITY: Every file under deliverables/ uses ASCII-only
      punctuation (no em dashes, curly quotes, en dashes, or other non-ASCII
      typographic characters). Non-ASCII source-data strings are allowed only
      when the encoding is declared.

  11. COMPANION DATA QUALITY: If companion data files exist, they are
      referenced in the Deliverable Register, each has a data dictionary,
      every temporal column carries an explicit year range (in the name or in
      the dictionary), and disclosed value degeneracy (>30% identical values
      in a key output column) is flagged as a limitation. N/A if no companion
      data files.

  Output format (use these exact headings, in order):

  CLAIM COMPLETENESS: PASS | FAIL - [evidence; list missing claims]
  CAVEAT PRESERVATION: PASS | FAIL - [evidence]
  CLAIM FIDELITY: PASS | FAIL - [evidence]
  BOUNDARY INTEGRITY: PASS | FAIL - [evidence]
  LIMITATION COMPLETENESS: PASS | FAIL - [evidence]
  RECOMMENDATION SCOPE: PASS | FAIL - [evidence]
  COMPUTATION BOUNDARY: PASS | FAIL - [evidence]
  SELF-SUFFICIENCY: PASS | FAIL - [evidence]
  MANDATORY SECTIONS: PASS | FAIL - [evidence]
  ENCODING INTEGRITY: PASS | FAIL - [evidence]
  COMPANION DATA QUALITY: PASS | FAIL | N/A - [evidence]

  OVERALL: PASS | FAIL - [one-sentence summary]
  """
)
```

Digest the review into `pcs_review`: record `overall`, `blocking_findings`, `material_risks`, `material_findings`, `disposition`, and `disposition_reason`. Do not store the full review text unless a FAIL or override makes literal audit text necessary; if retained, store only a pointer in `full_review_pointer`. Parse the per-check verdicts into `pcs_review.checks`. Set `pcs_review.overall` to PASS only when every check returned PASS or N/A.

- Interactive mode: present the review via `AskUserQuestion` with options `satisfied`, `valid_concern`, `disagree_override`. Wait for the user's answer before invoking any other tool.
- Auto mode: apply `references/auto-mode.md` stage-close rules.

Record the chosen disposition and reason in `pcs_review.disposition` and `pcs_review.disposition_reason`. If any check FAILs and the user does not override, reopen the cycle that introduced the fault (typically Cycle C, E, or F) and re-run the affected steps. Do not proceed to Finalization until `pcs_review.overall == PASS` or a formal override is recorded.

## Finalization

After the terminal fidelity review clears or the user overrides it:

1. Finalize `boundary.narrowing`: if any cycle narrowed the boundary, confirm `boundary.narrowing` contains `from`, `to`, `reason`, and `cycle`. If no narrowing occurred, omit the key. Widening is never allowed here; if widening is implied anywhere in the deliverable, return to the responsible cycle before closing the stage.

2. Parse `07_communication.yaml` with a standard YAML loader. Repair if parsing fails.

3. Render `07_communication.md` from the canonical YAML. Keep the report compact: one `##` section per top-level YAML key that is populated:
   - `Dataset` (project + upstream data description)
   - `Upstream Contract` (approved question, question type, target quantity, final claim boundary, active route, handoff discipline)
   - `Audience Profile`
   - `Delivery`
   - `Communication Plan`
   - `Claim Translations` (one row per translation with verdict and caveats)
   - `Dead-Claim Limitations`
   - `Recommendations`
   - `Boundary` (narrowing, if any)
   - `Uncertainty Presentation`
   - `Visualizations`
   - `Deliverable Register` (primary + companion files)
   - `PCS Assessment` (overall from pcs_review, per-check summary, disposition)

   Omit sections whose YAML keys are empty or absent. Reference the compact `pcs_review` fields through the YAML; the markdown is a rendered summary.

4. Scan every file under `deliverables/` and every file touched in this stage under `{docs_dir_name}/` and `{scripts_dir_name}/` for non-ASCII typographic punctuation (em dashes, curly quotes, en dashes). Treat any violation as a blocking defect for stage closure until the affected files are rewritten cleanly.

5. Update `README.md` with:

   ```markdown
   ## Communicate [COMPLETE]
   Type: {question_type}
   Active route: {active_route}
   Audience: {audience.type}
   Format: {delivery.format}
   Claims communicated: {n_with + n_with_caveats} ({n_with_caveats} with caveats)
   Claims excluded: {n_did_not_survive}
   Limitations disclosed: {n_mandatory_limitations}
   Deliverable: deliverables/{primary.filename}
   Next: none (terminal stage)
   ```

   If any field is empty, finalization is incomplete; repair the YAML and re-render before continuing.

6. Set `status.locked_at: {ISO timestamp}`. Re-parse the YAML to confirm validity.

7. Read `README.md` and include the `## Communicate [COMPLETE]` block exactly in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete; return to step 5. Only then tell the user the Skeptic project is complete and state the deliverable location.

## Backtracking

`communicate` has limited backtracking. Only two exit targets exist:

- Reopen `evaluate` when a surviving claim cannot be stated in audience-appropriate language without exceeding the boundary, or when mandatory caveats make a claim so hedged it communicates nothing useful.
- Reopen `formulate` plus `protocol` when the surviving claims do not address the original question at a level useful to any reasonable audience, or when producing any meaningful deliverable would require widening the claim boundary.

`communicate` cannot backtrack to `analyze`, `clean`, or `examine`. Analytical defects route through `evaluate` first.

When backtracking:

- Preserve every entry in `decision_ledger`. Append new iterations.
- Unlock the stage: set `status.locked_at: null`.
- Re-run the affected cycles and re-render the markdown at the end.
- Mark the superseded deliverable in `deliverable.primary` by renaming the stale file with a `.superseded` suffix rather than deleting it. Keep the audit trail intact.

Dependency notes:

- `formulate`, `protocol`, `clean`, `examine`, `analyze`, and `evaluate` are mandatory dependencies.
- `evaluate` produces the structured handoff that `communicate` packages. `communicate` does not modify or re-evaluate it.
- `communicate` may narrow the claim boundary. It may not widen it.
- `communicate` is terminal. There is no downstream stage.
- One primary deliverable per `communicate` run. If multiple audiences are needed, rerun `communicate` with a different audience specification, which reopens the stage from Cycle B.
