---
name: evaluate
description: Use after formulate, protocol, clean, examine, and analyze to adjudicate whether outputs and claims survive route-appropriate PCS checks, rendering per-claim survival verdicts that gate what communicate may package.
---

# /skeptic:evaluate - Route-Appropriate PCS Evaluation

IMPORTANT: Before executing, read `../core-principles.md`. `core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

Evaluate adjudicates whether analysis outputs survive route-appropriate PCS checks. It receives the locked outputs from `analyze` and renders per-claim survival verdicts. `communicate` receives only claims that survived. If no claims survive, say so and route the project back upstream. Do not manufacture survivable claims from insufficient evidence.

Evaluate does not re-execute analysis, generate new claims, widen the claim boundary, add post-hoc analyses, choose between methods, or package findings for an audience. Implications and recommendations belong to `communicate`.

## Stage Outputs

`evaluate` writes exactly three project-side artifacts plus a README block.

| Path | Role |
|------|------|
| `{scripts_dir_name}/06_evaluation.py` | Single Python file containing one function per cycle (`run_cycle_a`, `run_cycle_b`, ...). Invoked one cycle at a time. Returns a JSON evidence packet on stdout. |
| `{docs_dir_name}/06_evaluation.yaml` | Canonical stage memory. Holds the full upstream snapshot, reproducibility results, evaluation plan, per-cycle verdicts, claim survival registry, communicate handoff, cycle history, and PCS (integrity) review. Created at stage start, updated at the end of every cycle. |
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

upstream:                           # canonical snapshot read from prior-stage YAMLs at Cycle A
  approved_question:
  question_type:
  target_quantity:
  claim_boundary_as_narrowed: {}    # from 05_analysis.yaml (claim_type, scope, verbs_allowed, verbs_forbidden, evidence_ceiling, generalization_limit)
  protocol_mode:
  validation_logic:
  analysis_contract: {}             # {method_family, primary_specification, perturbation_axes: [], challengers: [], deviation_register: []}
  flags_for_evaluate: []            # [{id, description, affected_claim}]
  examine_support_registry: {}      # supported / weakly_supported / unsupported and fragility verdicts from 04_examination.yaml
  stakeholder_decision: {}          # from 01_formulation.yaml contract.decision_context

reproducibility:
  frozen_artifact_hashes: {}        # {path: {expected_sha256, observed_sha256, match: bool}}
  recomputed_metrics: {}            # {analysis_output_name: {expected, observed, match: bool}}

evaluation_plan:
  perturbation_axes: []             # mirrored from analysis_contract for adjudication
  challengers: []                   # mirrored from analysis_contract for adjudication
  route_specific_checks: []         # enumerated from the loaded route file and mapped to cycles B, C, D
  flag_coverage_map: {}             # {flag_id: {description, affected_claim, assigned_cycle}}
  divergence_triage: {}             # {axis_or_challenger_id: {magnitude, class: minor|notable|major}}

stability_verdicts: {}              # {claim_id: {verdict: stable|conditionally_stable|unstable, evidence, caveats: []}}
predictability_verdicts: {}         # {claim_id: {verdict: adequate|marginal|inadequate, evidence}}
validity_verdicts: {}               # {claim_id: {threats: [{domain, presence, direction, verdict: defended|threatened|fatal}], overall}}

claim_survival_registry: []         # list of {claim_id, description, stability, predictability, validity, deviation_impact, survival_verdict, caveats, evidence_summary}

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

cycle_history: []                   # append-only list, one entry per iteration
pcs_review: null                    # integrity check result at stage close
```

Each `cycle_history` entry:

```yaml
- cycle:                            # A|B|C|D|E|F|G1|...
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
  decision:                         # pass|iterate|acknowledge_gap|reopen_analyze|reopen_examine|reopen_protocol|reopen_formulate|archive
  # Optional: user_observations (captured in Step 2 when ambiguities required user input); decision_reason (required when decision != pass); override: {reason, gate} when a FAIL was overridden.
```

The main model reads both subagent replies, distills them, and writes the result into the `subagents` fields above; the replies themselves stay in memory. Populate those fields with the entries that materially shaped this iteration. `blocking_failures` (0 = PASS, >0 = FAIL) is the enforceable integer summary. Route per-gate reasoning into `cycle_history` through the specific `decisions[*]` or `rejected_alternatives[*]` entry that a gate produced. Keep the subagents block to the schema fields above; route any finding without a schema home into `open_risks`, or leave it out.

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
- `setup_side_effects`: one-time actions (typically Cycle A only)
- `checklist`: the items the cycle must answer. Each item has:
  - `id`: e.g. `A01`
  - `question`: the question text
  - `evidence_key`: the JSON key the script produces for this item (or `null` if judgment-driven)
  - `writes_to`: the canonical-YAML field (or list of fields) this item populates (or `null` if the item only feeds gates)
  - `skip_when`: only present when the item can be skipped under a specific condition; absent means "never skip"
- `gates`: verifiable conditions. Each gate has:
  - `id`: for a single-dep gate, the dep is encoded as a prefix (e.g. `A08-deviations-compliant` depends on A08); for a multi-dep gate, use a short name (e.g. `A-handoff-complete`) and list `depends_on`
  - `depends_on`: present only for multi-dep gates
  - `condition`: what it verifies
- `research_questions`: topics for the research subagent
- `guidance`: short, cycle-specific judgment rules
- `step4_additions`, `pcs_focus`, `log_extension`: present only when the cycle adds a specific discipline. `pcs_focus` holds cycle-specific PCS questions injected into the evaluation subagent prompt; it has no separate Step 5 application.

Follow-up cycles use `cycles/G_template.yaml` as a starting shape. Materialize the concrete Gn spec inside the canonical YAML (not as a new file on disk) when a follow-up is opened.

## Cycle Protocol

This protocol applies to every cycle, mandatory or follow-up.

### Step 1: Setup and Execution

1. Read `cycles/{cycle}.yaml`.
2. Recover prior stage state:
   - Cycle A: read upstream canonical YAMLs (`01_formulation.yaml`, `02_protocol.yaml`, `03_cleaning.yaml`, `04_examination.yaml`, `05_analysis.yaml`) and the `README.md`. Resolve the active route from `contract.question_type` in `01_formulation.yaml` cross-checked against the active route recorded in `02_protocol.yaml`. If they contradict or do not collapse to one route, stop and reopen `protocol`. Load the matching `references/routes/{route}/evaluate.md` once and keep it in context for the rest of the stage.
   - First cycle entered in a fresh session (not Cycle A), or first cycle after a backtrack reopens the stage: read `06_evaluation.yaml` once to load the upstream snapshot, evaluation plan, verdicts, and prior `cycle_history`. Reload the same route file named in `route.route_file_loaded`.
   - Every other case (continuing the same chat session): skip the re-read; the canonical YAML content is already in context from the cycle that just wrote it.
3. Cycle A only: initialize `06_evaluation.yaml` with `stage`, `schema_version`, `project`, `status.current_cycle: A`, `route.active_route`, and `route.route_file_loaded`; create `06_evaluation.py` with the shape specified below.
4. Every cycle: extend `06_evaluation.py` by writing or updating the cycle's function (`run_cycle_a`, `run_cycle_b`, ...). The function must produce every non-null `evidence_key` named in the cycle's checklist.
5. Run `python {scripts_dir_name}/06_evaluation.py --cycle {cycle}`. Capture stdout.
6. Parse stdout as JSON. Write the stdout verbatim to `{scripts_dir_name}/stdout/cycle_{cycle}_iter{iteration}.json` (create `{scripts_dir_name}/stdout/` on first use; `{iteration}` is the 1-based iteration number that will be written to `cycle_history` in Step 5). The parsed dictionary is the in-session candidate evidence driving Step 2 and Step 3. Only the compact summary derived from it is written into `cycle_history.script_evidence` in Step 5; the on-disk file is the full-JSON audit artifact referenced by `script_evidence_ref`.
7. Scan stderr and stdout for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing. Functions that intentionally demonstrate failure must be explicitly flagged with a `# expected_failure` comment.

If route context becomes ambiguous mid-stage, reread `01_formulation.yaml`, `02_protocol.yaml`, `05_analysis.yaml`, and the same route file before proceeding. If the active route cannot be resolved or the expected route file is missing, stop and route back upstream.

Script shape: one `run_cycle_*` function per cycle, a `load_state()` helper that reads `06_evaluation.yaml` plus the upstream canonical YAMLs it needs, an `argparse --cycle X` CLI, and a `main()` that prints exactly one JSON object to stdout. Claude writes the file from scratch in Cycle A and extends it with a new function at the start of every subsequent cycle.

Script rules:
- The script prints exactly one JSON object to stdout. Nothing else on stdout.
- The script does not write to `06_evaluation.yaml`. Only the model writes the canonical YAML.
- Heavy data (arrays, full DataFrames) is summarized, not dumped. Evidence packets stay compact.
- Each cycle's stdout is written verbatim to `{scripts_dir_name}/stdout/cycle_{cycle}_iter{iteration}.json`. `cycle_history[*].script_evidence` stores only a compact summary plus `script_evidence_ref` pointing at that file. Do not dump the full JSON into the canonical YAML.
- Per-file provenance (schema, encoding, sha256) is emitted only the first time a file is recorded -- typically Cycle A iter 1. After it lands in `provenance.files`, neither the stdout packet nor `cycle_history[*].script_evidence` re-emits those fields; downstream cycles reference those files by filename.
- Seeds are set inside the function if any stochastic step runs.
- The script does not re-execute analysis. It verifies hashes, recomputes declared metrics for reproducibility, executes the protocol-specified reality check, applies route-specific formal tools, and computes divergence statistics. It does not fit new models or produce new claims.
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
  - User observations: {cycle_history entry's user_observations from Step 2, or "none"}

  Answer these research questions for Cycle {X} ({cycle focus}):
  {research_questions list from the cycle YAML}

  Rules:
  - Stay inside the approved question, protocol, and active route.
  - Focus on methodological adjudication guidance, not domain discovery or method selection.
  - If a question does not apply, say "not applicable" with a one-line reason.
  - Cite sources for claims that would change an evaluation verdict.

  Return concise findings organized by research question. Every citation must include
  its URL inline after the claim it supports.
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
  User observations: {cycle_history entry's user_observations from Step 2, or "none"}

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

  UNANSWERED CHECKLIST ITEMS (list the IDs of any checklist item that was not answered -- absence of an item's evidence_key in the script output, or absence of the corresponding judgment, counts as unanswered):
  - Unanswered: [list of IDs, or "none"]

  CYCLE-SPECIFIC PCS QUESTIONS (from the cycle YAML `pcs_focus.items`; answer each one explicitly in the DEFECT SCAN below if any are defined, otherwise state "none defined"):
  {pcs_focus.items from the cycle YAML, one bullet per item, or "none defined"}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Actively falsify each gate and checklist answer
  rather than confirm them. For each gate marked PASS, state the specific failure
  mode you tested and ruled out. Categories: re-executed analysis, new claims,
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

  GATE ASSESSMENTS (use gate IDs from the cycle YAML; list every gate, not only failures. A gate whose depends_on includes any unanswered item fails automatically):
  - {gate_id}: PASS | FAIL - [evidence]

  ALTERNATIVES CONSIDERED:
  - Current approach: [description] - Score: [1-10] - [justification]
  - Alt 1: [different framing] - Score: [1-10] - [justification]
  - Alt 2: [different framing] - Score: [1-10] - [justification]

  GAPS REMAINING: [list, or "none"]
  BACKTRACKING IMPLICATIONS: [trigger IDs this cycle surfaced, or "none"]
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

Digest the subagent replies into `cycle_history[*].subagents`; the replies themselves stay in memory. Admit something to `subagents` when a future reader needs it to reconstruct why this path was chosen.

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

Keep the schema as the authoritative field list. If something the subagent surfaced has no schema home, fit it into `open_risks` or leave it out.

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
- `reopen_analyze` -> stop and reopen `analyze`
- `reopen_examine` -> stop and reopen `examine`
- `reopen_protocol` -> stop and reopen `protocol`
- `reopen_formulate` -> stop and reopen `formulate` plus `protocol`
- `archive` -> stop with documentation of why
- `override` -> user states the specific reason a FAIL is incorrect; logged as `override: {reason, gate}`; forward actions unlock

If backtracking is chosen, append a `backtracking_log` entry with `{cycle, trigger, return_to_stage, rationale}` and preserve the full `cycle_history` when the stage reopens.

Interactive mode: present the synthesized assessment and the allowed actions via `AskUserQuestion`. Wait for the user's answer before invoking any other tool.

Auto mode: apply the autonomous decision protocol from `../auto-mode.md`.

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

Re-parse `06_evaluation.yaml` to confirm validity.

## Ending the Cycle Loop

The loop ends when all of the following hold:

- every mandatory cycle (A through F) has a closing `decision` of `pass` or an `override`
- every approved follow-up cycle (G1, G2, ...) is resolved
- interactive mode: the user explicitly approved the claim survival registry in Cycle E
- auto mode: the stage approval gate in `../auto-mode.md` completes

Finalization requires explicit stage-close discipline.

## PCS Subagent Review

Evaluate is itself the PCS gate for the project's claims. The stage-close review is a mechanical integrity audit, not a meta-PCS review of evaluate's own reasoning. Dispatch at stage close:

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
  - Does any "survived" verdict in claim_survival_registry contradict a FAIL gate
    logged in cycle_history for Cycles B, C, or D? List contradictions.

  FLAG COVERAGE:
  - Was every flag in upstream.flags_for_evaluate addressed in at least one
    cycle_history entry? List unaddressed flags.

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

  CHECKLIST COVERAGE:
  - For each cycle, were all checklist items answered? List unanswered items and
    the dependent gates.

  Output each check as PASS or FAIL with specifics. End with OVERALL: PASS or FAIL.
  Be objective.
  """
)
```

Store the full output in `pcs_review.verbatim`.

- Interactive mode: present via `AskUserQuestion` with options `satisfied`, `valid_concern`, `disagree_override`. Wait for the user's answer before invoking any other tool.
- Auto mode: apply `../auto-mode.md` stage-close rules.

If any check FAILs, identify the cycle that introduced the problem and reopen it. Do not proceed to finalization until the integrity check is PASS or the user records an explicit `disagree_override` with rationale.

Record the chosen disposition and reason in `pcs_review.disposition` and `pcs_review.disposition_reason`.

## Finalization

After the integrity check clears or the user overrides it:

1. Finalize `claim_boundary_final`. If evaluate narrowed the claim boundary, ensure `narrowing_log` contains the entry with prior and new boundaries plus rationale. Evaluate may tighten `scope`, `generalization_limit`, `verbs_allowed` (by moving entries to `verbs_forbidden`), and `evidence_ceiling`. It may not loosen any of them.

2. Parse `06_evaluation.yaml` with a standard YAML loader. Repair if parsing fails.

3. Render `06_evaluation.md` from the canonical YAML. Keep the report compact: one `##` section per top-level YAML key that is populated (`Upstream Contract`, `Reproducibility`, `Evaluation Plan`, `Stability`, `Predictability`, `Threats to Validity`, `Claim Survival Registry`, `Final Claim Boundary`, `Communicate Handoff`, `Backtracking Events`, `Cycle Summary` with one line per cycle, `Integrity Check`). Omit sections whose YAML keys are empty or absent. Reference the subagent verbatims through the YAML; the markdown is a rendered summary.

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

6. Read `README.md` and quote the `## Evaluate [COMPLETE]` block verbatim in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete; return to step 4. Only then tell the user the evaluate stage is complete and the next stage is `communicate`.

## Backtracking

Evaluate may trigger backtracking to any upstream stage. Record each trigger in `backtracking_log` and preserve the full `cycle_history`.

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

- Preserve every entry in `cycle_history`. Append new iterations.
- Unlock the stage: set `status.locked_at: null`.
- Re-run the affected cycles and re-render the markdown at the end.
- `claim_boundary_final.narrowing_log` entries remain in place.
