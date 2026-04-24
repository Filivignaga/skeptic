---
name: formulate
description: Use when starting a new data analysis project. Refine a vague domain question into a precise, data-answerable question through iterative question-first cycles with format-aware dataset inspection. First stage of Skeptic.
---

# /skeptic:formulate - Problem Formulation and Data Context

IMPORTANT: Before executing, read `../core-principles.md`. `core-principles.md` is the architecture contract. If this file conflicts with it, `core-principles.md` wins.

## Guiding Principle

A good analyst updates the question instead of forcing the original wording through unsuitable data. Expect the question to evolve as data constraints become clear. That is the formulation process working correctly.

## Stage Outputs

`formulate` writes exactly three project-side artifacts plus a README block. Compact state lives in the canonical YAML.

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
  locked_at: null                   # set at stage close; presence = locked

provenance:                         # immutable audit facts only
  files: {}                         # {filename: {sha256, encoding}}

contract:
  approved_question:
  question_type:                    # descriptive|exploratory|inferential|predictive|causal|mechanistic
  target_quantity:
  unit_of_analysis:
  audience:
  decision_context:                 # stakeholder -> {stakeholder, actions, how_answer_changes_action}; academic -> {prior, evidence_threshold}
    mode:
  route_candidates: []              # ordered, best first
  baseline:
  minimum_uplift:
  error_costs: {}                   # {error_type: {cost, unacceptable: bool}}
  key_assumptions: []
  operationalization: {}            # {term: {chosen, rationale, rejected_alternatives: []}}
  derived_metrics: {}               # {name: formula}
  intended_uses: []
  prohibited_uses: []
  # Add target_population (central population) and hypothesis {null, alt, treatment, outcome} (inferential/causal) only when relevant.

claim_boundary:
  claim_type:
  scope:
  evidence_ceiling:
  generalization_limit:
  narrowing_log: []                 # appended by downstream stages only
  # Default verbs are implied by claim_type (see Finalization table). Add verbs_forbidden_added / verbs_allowed_added only when diverging.

protocol_handoff:
  data_usage_considerations: []     # collection purpose, sampling frame, upstream exclusions, structural notes (confounding / time-ordering / grouping / monitoring)
  leakage_risks: []
  forbidden_variable_candidates: []
  validation_needs: []
  route_family_stability:
  generalizability_risks: []
  open_questions: []

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
- Only downstream stages append to `claim_boundary.narrowing_log`.
- Write only fields that apply.
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

## Per-cycle Reference Files

Before running cycle X, load only `cycles/{X}.yaml`. Each cycle YAML carries:

- `upstream`: canonical-YAML fields that must be set before the cycle starts
- `setup_side_effects`: one-time actions (typically Cycle A only); omit when empty
- `required_evidence`: evidence keys or judgment outputs the cycle must produce
- `acceptance_criteria`: 3-5 verifiable conditions for cycle closure
- `writes`: mapping from evidence or judgment outputs to canonical-YAML fields
- `research_questions`: topics for the research subagent
- `format_aware_ingest` (Cycle A only): reference to `../data-formats.md` for per-format load checks
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
   - Cycle A: no prior state to recover.
   - First cycle entered in a fresh session (not Cycle A), or first cycle after a backtrack reopens the stage: read `01_formulation.yaml` once to load the contract, claim boundary, protocol handoff, and prior `decision_ledger`.
   - Every other case (continuing the same chat session): skip the re-read; the canonical YAML content is already in context from the cycle that just wrote it.
3. Cycle A only: execute the bootstrap sequence in `bootstrap.md`. It covers folder creation, raw-data and documentation copy, `README` init, canonical-YAML init (`stage`, `schema_version`, `project`, `status.current_cycle: A`), and creation of a project-specific `01_formulation.py` that follows `../script-contract.md`. One-time only; not rerun on backtrack.
4. Every cycle: extend `01_formulation.py` by writing or updating the cycle's function (`run_cycle_a`, `run_cycle_b`, ...). The function must produce every required evidence key named by the cycle spec.
5. Run `python {scripts_dir_name}/01_formulation.py --cycle {cycle}`. Capture stdout.
6. Parse stdout as JSON. Use the parsed dict as this cycle's candidate evidence for Step 2 and Step 3; Step 5 records a compact summary in `decision_ledger[*].script_evidence`. The script has already mirrored the same JSON to `{scripts_dir_name}/stdout/cycle_{cycle}.json` for external inspection; do not copy it into the canonical YAML.
7. Scan stderr and stdout for unhandled exceptions. Any unhandled exception is a blocking defect and must be fixed before continuing. Functions that intentionally demonstrate failure must be explicitly flagged with a `# expected_failure` comment.

Script contract: generate `01_formulation.py` for the actual data sources and follow `../script-contract.md`. The script must accept `--cycle`, run only the requested cycle, print exactly one JSON object to stdout, mirror that JSON to `stdout/cycle_{cycle}.json`, and never write canonical YAML. Use only the loaders and helpers the current dataset needs.

Script rules:
- The script prints exactly one JSON object to stdout. Nothing else on stdout.
- The script does not write to `01_formulation.yaml`. Only the model writes the canonical YAML.
- Heavy data (arrays, full DataFrames) is summarized, not dumped. Evidence packets stay compact.
- Per-file provenance (schema, encoding, sha256) is emitted only the first time a file is recorded -- typically Cycle A iter 1. After it lands in `provenance.files`, neither the stdout packet nor `decision_ledger[*].script_evidence` re-emits those fields; downstream cycles reference those files by filename.
- Seeds are set inside the function if any stochastic step runs.
- Stable helper functions or sibling helper modules are allowed when they reduce duplication and improve reproducibility. Helpers must be deterministic, documented briefly, and must not write canonical YAML or access restricted artifacts.

### Step 2: Human Review

Interactive mode:
1. Present the script evidence inline, concisely.
2. Scan the evidence for ambiguities, decision points the model cannot resolve alone, and research topics worth seeding into Step 3 beyond the cycle's default research_questions.
3. If at least one such item exists, dispatch `AskUserQuestion` with 1-3 questions targeting them. Otherwise proceed directly to Step 3.
4. When AskUserQuestion was dispatched, record the user's answers as `user_observations` in the pending decision_ledger entry. Pass them into Step 3 subagent prompts via the `User observations:` field.

Auto mode: apply the self-review loop from `../auto-mode.md`. Self-correct within the configured budget, then proceed unless an escalation trigger fires.

### Step 3: Subagent Review

Run subagents only when the cycle risk warrants it. Use the research subagent only when outside domain or methodological information can materially change a decision. Use the evaluation subagent on high-risk cycles, unresolved blocking issues, or stage close; otherwise perform the acceptance-criteria check inline.

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

  User observations: {decision_ledger entry's user_observations from Step 2, or "none"}

  Answer these research questions for Cycle {X} ({cycle focus}):
  {research_questions list from the cycle YAML}

  Return concise findings. For every citation-worthy claim, write or reference a `research_log.jsonl` row with URL, claim_used, verified_at, and status; canonical YAML keeps only `research_log#n` pointers. Organize findings by question. Focus on facts that
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
  User observations: {decision_ledger entry's user_observations from Step 2, or "none"}

  Produce this structured output, in order, with these exact section headings:

  EVALUATION: Cycle {X} - {focus}

  MISSING REQUIRED EVIDENCE (list required evidence keys or judgment outputs that are absent; evidence with a satisfied skip rule is not missing):
  - Unanswered: [list of IDs, or "none"]

  CYCLE-SPECIFIC PCS QUESTIONS (from `pcs_focus.items`, if any):
  {pcs_focus.items from the cycle YAML, one bullet per item, or "none defined"}

  DEFECT SCAN (adversarial mode):
  Assume the work contains errors. Actively falsify the acceptance criteria and material evidence rather than confirm them. Record only failures or non-obvious risks; do not write PASS notes for every criterion. Categories: unstated
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

  ACCEPTANCE CRITERIA ASSESSMENT (list only failed criteria or non-obvious criteria that materially affected the decision; missing required evidence fails dependent criteria):
  - {criterion_id}: PASS | FAIL - [evidence]

  ALTERNATIVES CONSIDERED:
  - Current approach: [description] - Score: [1-10] - [justification]
  - Alt 1: [different framing] - Score: [1-10] - [justification]
  - Alt 2: [different framing] - Score: [1-10] - [justification]

  GAPS REMAINING: [list, or "none"]
  PROTOCOL IMPLICATIONS: [facts this cycle surfaced for `protocol`, or "none"]
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
- `data_insufficient` -> log why and present options (request more data, reformulate, archive)
- `reformulate` -> pivot to a question the data can support
- `archive` -> stop with documentation of why
- `override` -> user states the specific reason a FAIL is incorrect; logged as `override: {reason, criterion}`; forward actions unlock

Interactive mode: present the synthesized assessment and the allowed actions via `AskUserQuestion`. Wait for the user's answer before invoking any other tool.

Auto mode: apply the autonomous decision protocol from `../auto-mode.md`.

If the data cannot answer the cycle's question, choose `data_insufficient`, `reformulate`, or `archive`.

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

Re-parse `01_formulation.yaml` to confirm validity.

## Ending the Cycle Loop

The loop ends when all of the following hold:

- every mandatory cycle (A through E) has a closing `decision` of `pass` or an `override`
- every approved follow-up cycle is resolved
- interactive mode: the user explicitly approves the final contract, claim boundary, and protocol handoff
- auto mode: the stage approval checkpoint in `../auto-mode.md` completes

Finalization requires explicit stage-close discipline.

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

Digest the review into `pcs_review`: record `overall`, `blocking_findings`, `material_risks`, `material_findings`, `disposition`, and `disposition_reason`. Do not store the full review text unless a FAIL or override makes literal audit text necessary; if retained, store only a pointer in `full_review_pointer`.

- Interactive mode: present via `AskUserQuestion` with options `satisfied`, `valid_concern`, `disagree_override`. Wait for the user's answer before invoking any other tool.
- Auto mode: apply `../auto-mode.md` stage-close rules.

Record the chosen disposition and reason in `pcs_review.disposition` and `pcs_review.disposition_reason`.

The subagent advises. It does not silently widen scope or bypass a blocking concern.

## Finalization

After the PCS review clears or the user overrides it:

1. Finalize `claim_boundary`: set `scope`, `evidence_ceiling`, and `generalization_limit` from Cycle D and Cycle E evidence. Add project-specific verb overrides under `verbs_forbidden_added` (and, rarely, `verbs_allowed_added`) when Cycle D operationalization tradeoffs or Cycle E bias findings demand narrowing beyond the defaults. Serialize only the `*_added` overrides; the default verb lists implied by `claim_type` live in the table below, and downstream stages derive the effective verb set from `claim_type` + the overrides.

   | question_type | verbs_allowed (defaults) | verbs_forbidden (defaults) |
   |---------------|--------------------------|----------------------------|
   | descriptive   | describe, summarize, compare, report, characterize, count | predict, cause, explain, generalize, infer, recommend |
   | exploratory   | explore, surface, suggest, hypothesize, identify candidates | confirm, prove, establish, demonstrate, predict, cause |
   | inferential   | estimate, generalize, quantify, test, infer | cause, predict deployment, explain mechanism, recommend treatment |
   | predictive    | predict, forecast, classify, score, rank | cause, explain, attribute, identify mechanism |
   | causal        | estimate effect, attribute, compare counterfactual | predict deployment, generalize beyond identification, explain mechanism from fit alone |
   | mechanistic   | model process, simulate, calibrate, explain mechanism | predict deployment, generalize beyond structural assumptions, claim causation from fit alone |

2. Parse `01_formulation.yaml` with a standard YAML loader. Repair if parsing fails.

3. Render `01_formulation.md` from the canonical YAML. Keep the report compact: one `##` section per top-level YAML key that is populated (`Approved Question`, `Decision Context`, `Operationalization`, `Route Candidates`, `Baseline / Uplift / Error Costs`, `Key Assumptions`, `Claim Boundary` with effective verbs derived from `claim_type` + overrides, `Intended and Prohibited Uses`, `Provenance`, `Protocol Handoff`, `Decision Summary` with one line per cycle, `PCS Assessment`). Omit sections whose YAML keys are empty or absent. Reference the compact `pcs_review` fields through the YAML; the markdown is a rendered summary.

4. Update `README.md` with:

   ```markdown
   ## Formulate [COMPLETE]
   Type: {question_type}
   Question: {approved_question}
   Data: {data source description}
   Protocol handoff: {one-line summary of the main data-usage or validation considerations}
   Next: Protocol - Project rules of the game
   ```

5. Set `status.locked_at: {ISO timestamp}`. Re-parse the YAML to confirm validity.

6. Read `README.md` and include the `## Formulate [COMPLETE]` block exactly in the stage-close user message. If the block is not present or any field is empty, finalization is incomplete; return to step 4. Only then tell the user the formulate stage is complete.

## Backtracking

If a downstream stage reopens `formulate`:

- Preserve every entry in `decision_ledger`. Append new iterations.
- Unlock the stage: set `status.locked_at: null`.
- Re-run the affected cycles and re-render the markdown at the end.
- Downstream narrowing entries already written to `claim_boundary.narrowing_log` remain in place.
