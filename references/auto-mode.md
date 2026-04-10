# Skeptic Auto Mode

This file defines the autonomous runtime for `/skeptic:auto`.

`core-principles.md` remains the architecture contract. This file only changes control flow. It does not weaken checklist coverage, gate evaluation, route discipline, PCS review, scorecards, backtracking, or logging.

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
- `cycle_iterations` — object keyed by stage name, each value an object keyed by cycle letter with iteration count. Example: `{"formulate": {"A": 2, "B": 1}, "protocol": {"A": 2}}`
- `followup_counts`
- `backtrack_count`
- `stage_attempts` — object keyed by stage name with attempt count. Must be updated at the start of every stage, not only the first.
- `pending_escalation`
- `last_decision`
- `last_updated`

State update rules:

- Always write the full JSON object atomically. Read the existing state, modify the relevant fields in memory, then write the complete object. Never append fields to an existing JSON string or do partial text replacement.
- When the route is resolved during `formulate` (typically Cycle C) or confirmed during `protocol`, update `route` immediately.
- When entering a new stage, reset `current_cycle` and add the stage to `stage_attempts` (incrementing if already present). Initialize `cycle_iterations` for the new stage as an empty object.
- When a cycle completes, update `cycle_iterations` for the current stage and cycle letter.

State schema validation and read-back verification:

- Treat `auto_mode_state.json` as schema-validated state, not a freeform log blob.
- Required types:
  - `mode`, `project_name`, `current_stage`, `last_decision`, `last_updated`: string
  - `current_cycle`: string or `null`
  - `route`: string or `null`
  - `cycle_iterations`: object keyed by stage name, each value an object keyed by cycle letter with integer counts
  - `followup_counts`: object
  - `backtrack_count`: integer
  - `stage_attempts`: object keyed by stage name with integer counts
  - `pending_escalation`: `null` or object
- After every write, immediately reread the file and verify all of the following before continuing:
  - the file parses as one JSON object
  - every required field exists with the expected type
  - required fields match the in-memory state that was intended to be written
  - stage-scoped structures are internally consistent (`current_stage` exists in `stage_attempts`, the current stage has an entry in `cycle_iterations`, and `route` is persisted as soon as it is known)
- Duplicate-key shadowing is forbidden. Do not patch JSON text in place. Write a normalized object to a temporary file, atomically replace the target, reread it, and validate the reread object against the intended state.
- If schema validation or read-back verification fails, stop and repair the state file before continuing. Do not proceed with a partially trusted run state.

If the run is interrupted, resume from this state rather than guessing.

## Autonomous Cycle Protocol

This protocol replaces the interactive Step 2 and Step 4 flow.

Steps 1, 3, and 5 from the stage file remain in force.

### Step 2 Replacement: Self-Review

After notebook execution and before subagents:

1. inspect outputs for:
   - execution errors
   - empty or clearly malformed outputs
   - unanswered checklist items
   - artifact mismatches
   - obvious route or claim-boundary violations
2. if issues are found, write corrective cells and re-execute
3. allow at most 2 self-correction rounds
4. if issues remain after 2 rounds, log them and continue to subagent review

Self-review is not a substitute for gate evaluation. It is only a fast sanity pass.

### Step 4 Replacement: Autonomous Decision

When the subagents return:

1. synthesize the cycle assessment
2. count `blocking_failures = blocking_defects + failed_gates`
3. apply the stage decision matrix

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
- every follow-up must define its own checklist and success condition
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

- Confirm the current stage's mandatory cycles, approved follow-up cycles, post-cycle phases, and stage-close review all ran to completion.
- Parse the current stage file and treat concrete artifacts named in post-cycle sections, finalization sections, `Required outputs`, and `Gate to proceed` or `Gate to finish` blocks as binding requirements.
- Verify every required artifact exists, is readable, and is consistent with the stage summary, stage document, README, and `metrics.md`.
- Run a generated-artifact consistency pass over the project artifacts produced or updated in the stage:
  - every referenced file path in stage documents, summaries, scorecards, and README entries must exist unless it is explicitly marked as external or future work
  - stale references to removed or nonexistent artifacts are blocking defects
  - personal workspace paths, usernames, or machine-specific absolute paths in tracked project docs are blocking defects unless they are the explicit project root for this run or a deliberate portable source locator note
  - project README summaries must be regenerated from the actual filesystem contents and verified against the artifacts on disk, not written from memory or stale earlier plans
- Run the final mojibake and encoding scan required by `core-principles.md` for generated `.md`, `.json`, `.yaml`, `.yml`, and `.py` files touched in the stage.
- If any validator check fails, record the failure as a blocking concern, reopen the relevant stage-close work, and do not ask the user for approval yet.

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

At the end of the full run:

- report the final deliverables produced
- report any acknowledged gaps
- leave `auto_mode_state.json` in a completed state
