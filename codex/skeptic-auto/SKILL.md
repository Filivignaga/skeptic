---
name: skeptic-auto
description: Skeptic Auto Mode - run the full question-first Veridical Data Science lifecycle end to end with autonomous cycle execution, bounded escalation, stage-boundary approvals, and cross-stage audit. Use when Codex should run Skeptic automatically, run the full Skeptic lifecycle, invoke skeptic auto, or execute all Skeptic stages in order.
---

# Skeptic Auto Mode

This file defines the autonomous runtime for `/skeptic:auto`.

`core-principles.md` remains the architecture contract. This file only changes control flow. It does not weaken required-evidence coverage, acceptance-criteria evaluation, route discipline, PCS review, backtracking, canonical YAML updates, or logging.

## Activation and Precedence

Auto mode is active when either of these is true:

- the user invoked `/skeptic:auto`
- the current command explicitly loaded this file and said to follow it

Precedence rules:

1. `core-principles.md` defines the architecture.
2. this file defines runtime control flow for auto mode.
3. stage files define stage-specific work.
4. route files narrow stage behavior further.

If a stage file says "the user decides" or "the user reviews" during a cycle:

- interactive mode: obey the stage file literally
- auto mode: use the autonomous cycle protocol below unless the stage requires human input that cannot be inferred, such as `communicate` audience selection

## Goal

Auto mode runs the seven-stage Skeptic pipeline end to end without per-cycle user approval.

The user is still required at:

- startup intake when required inputs are missing
- escalation triggers
- `communicate` audience and format selection
- stage-boundary approval

## Preflight

Before Stage 1, run a preflight. If any blocking item fails, stop and ask the user.

Required checks:

1. project name available or collectable
2. data source path(s) or access instructions available
3. rough domain question available
4. skill files readable:
   - `references/core-principles.md`
   - `references/stages/{stage}/{stage}.md` for all seven stages
   - `references/stages/{stage}/cycles/*.yaml` for all required cycles
   - route files under `references/routes/{route}/` when the route is known
5. Python available for project-side stage scripts
6. project directories resolvable from `skeptic.yaml` or defaults in `core-principles.md`

If any preflight check fails:

- explain the exact failure
- say whether the run is blocked or can continue with a degraded path
- ask the user only when the user can resolve it

## Startup Intake

Auto mode should ask only for what is missing:

- project name
- data source(s)
- rough domain question

Optional startup intake if needed:

- preferred project root if not discoverable from `skeptic.yaml`
- data access constraints
- audience information early if the user already knows the final audience

Do not run a long interview before `formulate`. `formulate` still does the real narrowing.

## Persisted Run State

Auto mode keeps a machine-readable run-state artifact at:

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
- `cycle_iterations`
- `followup_counts`
- `backtrack_count`
- `stage_attempts`
- `pending_escalation`
- `last_decision`
- `last_updated`

State update rules:

- Always write the full JSON object atomically. Read the existing state, modify the relevant fields in memory, then write the complete object.
- When the route is resolved during `formulate` or confirmed during `protocol`, update `route` immediately.
- When entering a new stage, reset `current_cycle` to the first cycle letter and increment `stage_attempts`.
- When a cycle completes, update `cycle_iterations` for the current stage and cycle.
- When a stage completes and is approved, set `current_cycle` to `null`.
- Treat `auto_mode_state.json` as a runtime cache. Canonical stage YAMLs remain the source of truth.

After every state write:

1. reread the file
2. parse it as JSON
3. verify required fields and expected types
4. verify `current_stage` appears in `stage_attempts` and `cycle_iterations`
5. verify `route` is not `null` after `formulate` is complete
6. verify reread values match the intended in-memory state

If the run is interrupted, resume from the state file and canonical stage YAMLs rather than guessing.

## Autonomous Cycle Protocol

This protocol replaces the interactive Step 2 and Step 4 flow. Steps 1, 3, and 5 from the stage file remain in force.

### Step 2 Replacement: Self-Review

After the stage script runs and before subagents:

1. inspect stdout JSON and stderr for:
   - execution errors
   - empty or malformed evidence
   - missing required evidence
   - artifact mismatches
   - route, visibility, or claim-boundary violations
2. if issues are found, edit the stage script or stage YAML and rerun the cycle
3. allow at most 2 self-correction rounds
4. if issues remain after 2 rounds, log them and continue to subagent review or escalate if the stage cannot proceed

Self-review is not a substitute for acceptance-criteria evaluation. It is only a fast sanity pass.

### Step 4 Replacement: Autonomous Decision

When subagents return or inline evaluation completes:

1. verify each result is non-empty and contains the expected structure
2. synthesize the cycle assessment
3. count `blocking_failures = unanswered_items + blocking_defects + failed_acceptance_criteria`
4. apply the stage decision matrix

Decision rules:

- if `blocking_failures == 0`, pass the cycle or iterate only for a clearly material improvement
- if `blocking_failures > 0`, iterate on the blocking issues unless escalation or backtracking is required
- if a follow-up cycle is recommended and the topic is material, auto-approve it subject to the caps below
- if backtracking is recommended, trigger an escalation instead of silently rewinding

Auto mode must write a compact decision ledger entry that records:

- why the cycle passed or failed
- which blocking issues drove the decision
- what changed during iteration
- whether a follow-up was opened
- the decision-relevance alternative when the cycle made a material judgment

## Iteration Budgets and Caps

| Scope | Limit | On Exhaust |
|-------|-------|------------|
| Self-review corrections per cycle | 2 rounds | continue to subagent review |
| Main iterations per cycle | 3 rounds | escalate |
| Same follow-up topic in one stage | 2 repeats after first occurrence | escalate |
| Total follow-up cycles per stage | 4 | escalate |
| Total backtracks per full run | 3 | escalate |

If a cap is hit, stop and ask the user. Do not continue autonomously past the cap.

## Escalation Triggers

Auto mode pauses only at defined triggers:

- domain ambiguity with more than one defensible operationalization
- route ambiguity or route contradiction
- data insufficiency
- claim-boundary widening request
- iteration budget exhausted
- follow-up cap exhausted
- backtracking recommendation
- environment failure that blocks script execution
- required human input cannot be inferred
- repeated stage rejection by the user

For every escalation:

- describe the exact blocking fact
- name the affected stage and cycle
- list the available actions
- write the pending escalation into `auto_mode_state.json`

## Follow-Up Cycles

Follow-up cycles stay narrow.

Rules:

- the evaluator may recommend a follow-up topic
- auto mode may approve it only if it is issue-specific and inside the active stage boundary
- every follow-up must define its own `required_evidence`, `acceptance_criteria`, and `writes`
- materialize the concrete follow-up spec inside the canonical YAML, not as a new file on disk
- if the same topic keeps recurring, escalate instead of looping

Follow-ups must appear in:

- the canonical stage YAML
- the rendered stage summary
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

Every stage ends with explicit stage-boundary approval.

Before presenting stage approval options, run a stage-boundary validator. Approval is blocked until the validator passes.

Stage-boundary validator requirements:

1. Confirm all mandatory cycles and approved follow-up cycles have a closing decision of `pass` or `override`.
2. Parse the canonical stage YAML with a standard YAML loader.
3. Verify every field required by the stage finalization section is populated or explicitly omitted as not applicable.
4. Verify the rendered stage markdown exists and was derived from the canonical YAML.
5. Verify the README contains the stage completion block specified by the stage finalization section.
6. Verify referenced project files exist on disk unless explicitly marked external or future work.
7. Verify the stage script exists, supports `--cycle`, and produced compact JSON evidence for the completed cycles.
8. Scan touched `.md`, `.json`, `.yaml`, `.yml`, and `.py` files for mojibake markers and unintended non-ASCII punctuation.
9. Verify `auto_mode_state.json` reflects the stage just completed.
10. If there is a next stage, read its required inputs and check that the current stage produced the required handoff.

The stage summary must include:

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

- interactive mode: the user usually dispositions the review immediately
- auto mode: record compact `pcs_review` fields, incorporate non-blocking fixes automatically, and pause only if the review creates a blocking concern or the stage hits its approval checkpoint

Do not store full review transcripts in canonical YAML. Use `full_review_pointer` only when a failure or override needs literal audit text outside the canonical YAML.

## Communicate Special Rule

`communicate` Cycle B is a required human-input checkpoint in both modes.

Do not infer:

- intended audience
- technical level
- delivery format
- decision context

Auto mode must ask for that input once, log it, and then continue autonomously.

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

For each stage, read the corresponding local stage file under `references/stages/{stage}/{stage}.md`:

1. read `references/core-principles.md`
2. read the stage file
3. read the active route file when applicable
4. run the stage precondition checks
5. execute mandatory cycles using the autonomous cycle protocol
6. execute approved follow-up cycles
7. run the stage-close review
8. run the stage-boundary validator
9. present the stage summary
10. require stage approval before continuing

At the end of the full run, run the cross-stage consistency audit:

1. Verify all seven canonical YAML files exist and parse.
2. Verify stage order and route consistency across canonical YAMLs.
3. Verify claim boundary changes are monotonic or backed by an explicit backtrack.
4. Verify every file path referenced in canonical YAMLs, rendered markdown, README, and deliverables exists or is marked external.
5. Verify protocol commitments are completed, explicitly deferred, or recorded as deviations.
6. Verify every deliverable is parseable in its declared format.
7. Verify `auto_mode_state.json` is complete and consistent with canonical stage YAMLs.

If any audit check fails, reopen the relevant stage for repair before declaring the run complete.

After the audit passes:

- report the final deliverables produced
- report any acknowledged gaps
- leave `auto_mode_state.json` in a completed state
