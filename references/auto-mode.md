# Skeptic Auto Mode

This file defines the autonomous runtime for `/skeptic:auto`.

`core-principles.md` remains the architecture contract. This file only changes control flow. It does not weaken required-evidence coverage, acceptance-criteria evaluation, route discipline, PCS review, scorecards, backtracking, or logging.

## Activation and Precedence

Auto mode is active when either of these is true:

- the user invoked `/skeptic:auto`
- the current command explicitly loaded this file and said to follow it

Precedence rules:

1. `core-principles.md` defines the architecture.
2. this file defines runtime control flow for auto mode
3. stage files define stage-specific work
4. route files narrow stage behavior further

If a stage file says "the user decides" or "the user reviews" during a cycle:

- interactive mode: obey the stage file literally
- auto mode: replace that with the autonomous cycle protocol below unless the stage file explicitly requires human input that cannot be inferred, such as `communicate` audience selection

## Goal

Auto mode runs the full seven-stage Skeptic pipeline end to end without per-cycle user approval.

The user is still required at:

- startup intake when required inputs are missing
- escalation triggers
- `communicate` audience and format selection
- every stage boundary approval

## Preflight

Before Stage 1, run a preflight. If any item fails, stop and ask the user.

Required checks:

1. project name available or collectable
2. data source path(s) or access instructions available
3. rough domain question available
4. skill files readable:
   - `references/core-principles.md`
   - `references/formulate.md`
   - `references/protocol.md`
   - `references/clean.md`
   - `references/examine.md`
   - `references/analyze.md`
   - `references/evaluate.md`
   - `references/communicate.md`
5. notebook runner available from `skeptic.yaml` or fallback runner
6. Jupyter execution environment available, or the user explicitly accepts manual notebook execution
7. project directories resolvable from `skeptic.yaml` or defaults. Read `skeptic.yaml` first and use its values for `projects_root`, `data_dir_name`, `docs_dir_name`, `notebooks_dir_name`, and `readme_name`. If `skeptic.yaml` is absent, use the defaults from `core-principles.md`. Use the resolved directory names for all subsequent directory creation and file path resolution throughout the run.
8. directory-name consistency: if the project directory already exists, verify that the actual subdirectory names on disk match the resolved config values. If a directory exists under a different name (e.g., `dslc_documentation` when config says `skeptic_documentation`), stop and ask the user whether to rename the existing directory or update the config. Do not silently use a directory name that contradicts the config.

If any preflight check fails:

- explain the exact failure
- say whether the run is blocked or can continue with a degraded path
- use `AskUserQuestion` only if the user can resolve it

## Startup Intake

Auto mode should ask only for what is missing.

Minimum startup intake:

- project name
- data source(s)
- rough domain question

Optional startup intake if needed:

- preferred project root if not discoverable from `skeptic.yaml`
- notebook execution constraints
- audience information early if the user already knows the final audience

Do not run a long interview before `formulate`. `formulate` still does the real narrowing.

## Persisted Run State

Auto mode must keep a machine-readable run-state artifact at:

`{projects_root}/{project-name}/{docs_dir_name}/auto_mode_state.json`

Update it after:

- preflight
- every cycle decision
- every follow-up cycle
- every escalation
- every backtrack
- every stage approval or rejection

Minimum fields:

- `mode`
- `project_name`
- `current_stage`
- `current_cycle`
- `route`
- `cycle_iterations` — object keyed by stage name, each value an object keyed by cycle letter with iteration count
- `followup_counts`
- `backtrack_count`
- `stage_attempts` — object keyed by stage name with attempt count. Must be updated at the start of every stage, not only the first.
- `pending_escalation`
- `last_decision`
- `last_updated`

Reference example (mid-run, during `clean` Cycle B):

```json
{
  "mode": "auto",
  "project_name": "example-project",
  "current_stage": "clean",
  "current_cycle": "B",
  "route": "predictive",
  "cycle_iterations": {
    "formulate": {"A": 2, "B": 2, "C": 1, "D": 2, "E": 2},
    "protocol": {"A": 2, "B": 2, "C": 2, "D": 1},
    "clean": {"A": 1}
  },
  "followup_counts": {},
  "backtrack_count": 0,
  "stage_attempts": {"formulate": 1, "protocol": 1, "clean": 1},
  "pending_escalation": null,
  "last_decision": "clean_cycle_A_passed",
  "last_updated": "2026-04-10"
}
```

Reference example (pipeline complete):

```json
{
  "mode": "auto",
  "project_name": "example-project",
  "current_stage": "communicate",
  "current_cycle": null,
  "route": "predictive",
  "cycle_iterations": {
    "formulate": {"A": 2, "B": 2, "C": 1, "D": 2, "E": 2},
    "protocol": {"A": 2, "B": 2, "C": 2, "D": 1},
    "clean": {"A": 1, "B": 1, "C": 1, "E": 1},
    "examine": {"A": 2, "B": 1, "C": 1},
    "analyze": {"A": 1, "B": 1, "C": 1, "D": 1, "F": 1},
    "evaluate": {"A": 1, "B": 1, "C": 1, "D": 1, "E": 1, "G": 1},
    "communicate": {"A": 1, "B": 1, "C": 1, "D": 1, "E": 1, "F": 1}
  },
  "followup_counts": {},
  "backtrack_count": 0,
  "stage_attempts": {"formulate": 1, "protocol": 1, "clean": 1, "examine": 1, "analyze": 1, "evaluate": 1, "communicate": 1},
  "pending_escalation": null,
  "last_decision": "communicate_stage_approved",
  "last_updated": "2026-04-11"
}
```

State update rules:

- Always write the full JSON object atomically. Read the existing state, modify the relevant fields in memory, then write the complete object. Never append fields to an existing JSON string or do partial text replacement.
- When the route is resolved during `formulate` (typically Cycle C) or confirmed during `protocol`, update `route` immediately.
- When entering a new stage, reset `current_cycle` to the first cycle letter and add the stage to `stage_attempts` (incrementing if already present). Initialize `cycle_iterations` for the new stage as an empty object.
- When a cycle completes, update `cycle_iterations` for the current stage and cycle letter.
- When a stage completes and is approved, set `current_cycle` to `null`. Do not use freeform values like `"done"` or `"COMPLETE"`.

State schema validation and read-back verification:

- Treat `auto_mode_state.json` as schema-validated state, not a freeform log blob.
- Required types:
  - `mode`, `project_name`, `current_stage`, `last_decision`, `last_updated`: string
  - `current_cycle`: single uppercase letter (`"A"` through `"G"`), a follow-up cycle ID matching the pattern `{letter}{number}` (e.g., `"F1"`, `"D2"`), or `null`. No other values.
  - `route`: one of `"descriptive"`, `"exploratory"`, `"inferential"`, `"predictive"`, `"causal"`, `"mechanistic"`, or `null` (only before route resolution)
  - `cycle_iterations`: object keyed by stage name, each value an object keyed by cycle letter with integer counts. Stage names must be one of: `formulate`, `protocol`, `clean`, `examine`, `analyze`, `evaluate`, `communicate`.
  - `followup_counts`: object
  - `backtrack_count`: integer
  - `stage_attempts`: object keyed by stage name with integer counts
  - `pending_escalation`: `null` or object
- After every write, run these verification checks before continuing:
  1. Reread the file from disk.
  2. Parse it as JSON. If parsing fails, stop and repair.
  3. Verify zero duplicate keys. The write procedure must construct the object in memory and serialize it, never concatenate JSON strings.
  4. Verify every required field exists with the expected type from the list above.
  5. Verify `current_stage` appears as a key in `stage_attempts`.
  6. Verify `current_stage` appears as a key in `cycle_iterations` (even if the object is empty for a stage that just started).
  7. Verify `route` is not `null` after `formulate` is complete.
  8. Verify all completed stages appear in `stage_attempts` and `cycle_iterations`.
  9. Verify the reread values match the in-memory state that was intended to be written.
- If any verification check fails, stop and repair the state file before continuing. Do not proceed with a partially trusted run state.

If the run is interrupted, resume from this state rather than guessing.

## Autonomous Cycle Protocol

This protocol replaces the interactive Step 2 and Step 4 flow.

Steps 1, 3, and 5 from the stage file remain in force.

### Step 2 Replacement: Self-Review

After notebook execution and before subagents:

1. inspect outputs for:
   - execution errors
   - empty or clearly malformed outputs
   - missing required evidence
   - artifact mismatches
   - obvious route or claim-boundary violations
2. if issues are found, write corrective cells and re-execute
3. allow at most 2 self-correction rounds
4. if issues remain after 2 rounds, log them and continue to subagent review

Self-review is not a substitute for acceptance-criteria evaluation. It is only a fast sanity pass.

### Step 4 Replacement: Autonomous Decision

When the subagents return:

1. verify each subagent result is non-empty and contains the expected output structure. The evaluation subagent must include DEFECT SCAN, ACCEPTANCE CRITERIA ASSESSMENT, and FINAL COUNTS sections. The research subagent must include organized findings. If a subagent returned empty, errored out, or produced output missing its required structure, escalate to the user. Do not synthesize from partial results without flagging the gap.
2. synthesize the cycle assessment
3. count `blocking_failures = blocking_defects + failed_acceptance_criteria`
4. apply the stage decision matrix

Decision rules:

- if verdict is `PASS` and `blocking_failures == 0`, pass the cycle
- if verdict is `FAIL` or `blocking_failures > 0`, iterate on the blocking issues
- if a follow-up cycle is recommended and the topic is material, auto-approve it subject to the caps below
- if backtracking is recommended, trigger an escalation instead of silently rewinding

Auto mode must log:

- why the cycle passed or failed
- which blocking issues drove the decision
- what changed during iteration
- whether a follow-up was opened

## Iteration Budgets and Caps

These caps prevent infinite loops.

| Scope | Limit | On Exhaust |
|-------|-------|------------|
| Self-review corrections per cycle | 2 rounds | continue to subagent review |
| Main iterations per cycle | 3 rounds | escalate |
| Same follow-up topic in one stage | 2 repeats after first occurrence | escalate |
| Total follow-up cycles per stage | 4 | escalate |
| Total backtracks per full run | 3 | escalate |

If a cap is hit, stop and ask the user. Do not continue autonomously past the cap.

## Escalation Triggers

Auto mode pauses only at defined triggers.

Required escalation triggers:

- domain ambiguity with more than one defensible operationalization
- route ambiguity or route contradiction
- data insufficiency
- claim-boundary widening request
- iteration budget exhausted
- follow-up cap exhausted
- backtracking recommendation
- environment failure that blocks notebook execution
- manual execution required after Jupyter failure
- repeated stage rejection by the user

For every escalation:

- describe the exact blocking fact
- name the affected stage and cycle
- list the available actions
- write the pending escalation into `auto_mode_state.json`

## Follow-Up Cycles

Follow-up cycles stay narrow.

Rules:

- the evaluation subagent may recommend a follow-up topic
- Claude may auto-approve it only if it is issue-specific and inside the active stage boundary
- every follow-up must define its own required evidence and success condition
- if the same topic keeps recurring, escalate instead of looping

Follow-ups must appear in:

- the stage document
- `metrics.md`
- the stage summary
- `auto_mode_state.json`

## Backtracking

Backtracking remains first-class.

When a downstream stage finds an upstream invalid assumption:

1. preserve the prior record
2. mark superseded work rather than deleting it
3. write the proposed target stage and reason into `auto_mode_state.json`
4. ask the user before jumping upstream

Auto mode may recommend backtracking. It may not hide it.

## Stage Summaries and Approval

Every stage ends with an explicit stage-boundary approval.

Before presenting stage approval options, run a stage-boundary validator. Approval is blocked until the validator passes.

Stage-boundary validator requirements:

Run every check below. If any check fails, record it as a blocking concern, reopen the relevant stage-close work, and do not ask the user for approval yet.

**Check 1: Cycle and phase completeness.** Confirm the current stage's mandatory cycles, approved follow-up cycles, post-cycle phases, and stage-close review all ran to completion. Cross-reference the stage file's Stage Map and Post-cycle Evaluation sections.

**Check 2: Finalization outputs.** Parse the current stage file's finalization section (typically in `Post-cycle Evaluation > Phase 2` or `Phase 3`). Every artifact, scorecard, section update, and README update listed there is a binding requirement. Verify each one exists and has content.

**Check 3: Empty-section detection.** Read the current stage's documentation file (e.g., `05_analysis.md`). Every `##` section header that was created during Setup is a structural promise. If any such section contains no content between its header and the next `##` header (or end of file), that is a blocking defect. Sections that the stage file's finalization phase requires content in (e.g., `## PCS Assessment`, `## Summary`, `## Evaluation Handoff`, `## Communicate Handoff`, `## Deviation Register`, `## Support Registry`, `## Analysis Handoff`, `## Claim Survival Registry`) must have substantive content, not just a header or placeholder text.

**Check 4: Notebook existence and execution state.** Verify the stage's notebook exists (e.g., `05_analysis.ipynb` for analyze, `06_evaluation.ipynb` for evaluate, `07_communication.ipynb` for communicate). Additionally, read the notebook and verify that at least 80% of code cells have a non-null `execution_count`. If more than 20% of code cells are unexecuted, this is a blocking defect. Also scan executed cell outputs for Python exception tracebacks — any unhandled exception is a blocking defect unless the cell is explicitly marked as an expected-failure demonstration.

**Check 5: Metrics scorecard.** Verify that `metrics.md` contains a scorecard section for the current stage. Each stage's finalization phase specifies the scorecard it must append. If the scorecard is missing, it is a blocking defect.

**Check 6: Next-stage precondition pre-check.** Read the NEXT stage's reference file and run its Precondition Gate checks against the artifacts just produced. This catches missing handoff sections before the current stage is approved. For example, when approving `analyze`, run `evaluate`'s precondition gate; when approving `evaluate`, run `communicate`'s precondition gate. If the next stage's precondition gate would fail, that is a blocking defect in the current stage.

**Check 7: README consistency.** The current stage's finalization section specifies a README update template. Verify that `README.md` contains the expected section for this stage and that its content matches the actual outputs (not stale content from a prior stage or plan). Regenerate the README section from the actual filesystem contents and stage outputs if it was written from memory.

**Check 8: Artifact consistency pass.**
- Every file path referenced in the stage document, scorecard, and README must exist on disk unless explicitly marked as external or future work.
- Stale references to removed or nonexistent artifacts are blocking defects.
- Personal workspace paths, usernames, or machine-specific absolute paths in tracked project docs are blocking defects unless they are the explicit project root for this run.

**Check 9: Encoding scan.** Run the mojibake and encoding scan required by `core-principles.md` for all `.md`, `.json`, `.yaml`, `.yml`, `.py`, and `.ipynb` files produced or updated in the stage. For `.ipynb` files, scan cell `source` fields for mojibake markers and unintended non-ASCII punctuation. For all files in `deliverables/` regardless of extension (including `.csv`, `.json`, `.xlsx`, etc.), also verify zero non-ASCII typographic punctuation (em dashes, curly quotes, ellipsis characters, etc.) per the communicate `F-encoding-clean` gate.

**Check 10: State file sync.** Verify `auto_mode_state.json` reflects the stage just completed: `current_stage` matches, `stage_attempts` includes the stage, `cycle_iterations` has entries for the stage, and `route` is non-null if the route has been resolved.

**Check 10b: State derivation and repair.** Rather than trusting the state file as-is, re-derive the expected state from authoritative documents:
- Count actual cycles from log entries in the stage documentation file (e.g., `### Cycle A`, `### Cycle B` headers).
- Read the route from `02_protocol.md` if protocol is complete.
- Count stage attempts from `metrics.md` scorecards.
- Compare the derived state against `auto_mode_state.json`. If any field diverges, overwrite the state file with the derived values and log the repair. The state file is a cache of the authoritative documents, not a source of truth. If the documents and the state file disagree, the documents win.

The summary must include:

- cycles completed
- iteration counts
- follow-up cycles and why they were opened
- key decisions made autonomously
- major research findings
- major evaluation findings
- PCS or integrity review result
- acknowledged gaps and overrides
- proposed next stage

Stage approval options:

- approve and continue
- reject with feedback
- stop the run

If the user rejects a stage:

1. inject the feedback as a hard constraint
2. reopen only the affected cycles when possible
3. rerun the stage-close review
4. ask for stage approval again

## Stage-Close Reviews

Stage-end PCS or integrity reviews still run.

Auto mode changes only how the result is handled:

- interactive mode: the user usually dispositioned the review immediately
- auto mode: Claude records the review, incorporates non-blocking fixes automatically, and pauses only if the review creates a blocking concern or the stage hits its approval checkpoint

## `communicate` Special Rule

`communicate` Cycle B is a required human-input checkpoint in both modes.

Do not infer:

- intended audience
- technical level
- delivery format
- decision context

Auto mode must ask for that input once, log it, and then continue autonomously.

The response to that audience prompt counts as the required audience approval for the later communication cycles.

## Full-Pipeline Orchestration

Run order:

1. preflight
2. startup intake
3. `formulate`
4. `protocol`
5. `clean`
6. `examine`
7. `analyze`
8. `evaluate`
9. `communicate`

For each stage:

1. read the stage file
2. read the active route file when applicable
3. run the stage precondition checks
4. execute mandatory cycles using the autonomous cycle protocol
5. execute approved follow-up cycles
6. execute post-cycle phases as defined in the stage file — these are mandatory, not optional. A stage is not complete until all post-cycle phases have run. If the stage file defines reproducibility, robustness, PCS review, or finalization phases, all of them must execute before stage-boundary approval.
7. run the stage-close review
8. run the stage-boundary validator, including required-artifact checks, generated-artifact consistency checks, and the final encoding scan
9. present the stage summary
10. require stage approval before continuing

At the end of the full run, before declaring the pipeline complete, run the cross-stage consistency audit:

**Cross-stage consistency audit (mandatory):**

1. **Stage completeness.** Verify all 7 stages appear in `auto_mode_state.json` `stage_attempts` and `cycle_iterations`. Verify `metrics.md` contains a scorecard section for every completed stage (Formulation through Communicate). Missing scorecards are a blocking defect.
2. **Route consistency.** Read the active route from every stage document (`02_protocol.md` through `07_communication.md`). Verify the route is identical across all stages, or that any route change was logged as a backtrack with user approval.
3. **Claim boundary monotonicity.** Read the Claim Boundary Registry from `metrics.md` (or `claim_boundary_registry.yaml`). Verify it is parseable as YAML. Verify `narrowing_log` entries are chronologically ordered by stage. Verify no downstream stage widened `scope`, loosened `generalization_limit`, or removed entries from `verbs_forbidden` without a logged backtrack to `formulate` plus `protocol`.
4. **File reference integrity.** For each stage document and each scorecard in `metrics.md`, verify that every file path referenced exists on disk. Stale references to removed or renamed files are blocking defects.
5. **Protocol commitment reconciliation.** Read `02_protocol.md` `## Protocol Contract` and extract all items marked as required or committed. Cross-reference against `05_analysis.md` `## Deviation Register`. Every committed item must be either completed or logged as a deviation. Uncommitted items that were silently dropped are blocking defects.
6. **Deliverable format verification.** For each file in `deliverables/`, verify the file is parseable in its declared format (CSV loads without error, Markdown has valid structure, JSON parses). A corrupt or unparseable deliverable is a blocking defect.
7. **Scorecard internal consistency.** For each scorecard in `metrics.md`, verify: blocking failures resolved <= total blocking failures, no negative counts, cycle counts match the stage document log entries.

If any audit check fails, reopen the relevant stage for repair before declaring the run complete.

After the audit passes:

- report the final deliverables produced
- report any acknowledged gaps
- leave `auto_mode_state.json` in a completed state
