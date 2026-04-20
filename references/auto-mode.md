# Skeptic Auto Mode

This file defines the autonomous runtime for `/skeptic:auto`.

`core-principles.md` remains the architecture contract. This file only changes
runtime control flow. It does not weaken checklist coverage, gate evaluation,
route discipline, PCS review, backtracking, or logging.

## Activation and Precedence

Auto mode is active when either condition is true:

- the user invoked `/skeptic:auto`
- the current command explicitly loaded this file and said to follow it

Precedence rules:

1. `core-principles.md` defines the architecture
2. this file defines runtime control flow for auto mode
3. stage entry files define stage-specific work
4. route files narrow stage behavior further
5. cycle YAML files define cycle-specific requirements

If a stage file says the user decides during a cycle:

- interactive mode: obey the stage file literally
- auto mode: replace that with the autonomous cycle protocol below unless the
  stage explicitly requires human input that cannot be inferred

## Goal

Auto mode runs the full seven-stage Skeptic pipeline end to end without
per-cycle user approval.

The user is still required at:

- startup intake when required inputs are missing
- escalation triggers
- stage-boundary approvals
- any stage-specific human-input checkpoint that cannot be inferred safely

## Preflight

Before Stage 1, run a preflight. If any item fails, stop and ask the user.

Required checks:

1. project name available or collectable
2. data source path or access instructions available
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
5. Python execution for project-side stage scripts is available
6. project directories are resolvable from `skeptic.yaml` or defaults
7. if a stage has cycle YAML files, the cycle directory exists and is readable

If any preflight check fails:

- explain the exact failure
- say whether the run is blocked or degraded
- ask the user only when they can resolve it

## Startup Intake

Ask only for what is missing.

Minimum startup intake:

- project name
- data source or access instructions
- rough domain question

Optional startup intake if needed:

- preferred project root if not discoverable from `skeptic.yaml`
- audience information early if the user already knows the final audience

Do not run a long interview before `formulate`. `formulate` still does the real
narrowing.

## Persisted Run State

Keep a machine-readable run-state artifact at:

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

State rules:

- always write the full JSON object atomically
- after every write, reread the file and parse it as JSON
- verify required fields and types before continuing
- if the route is resolved during `formulate`, update `route` immediately
- when entering a new stage, increment `stage_attempts` and reset
  `current_cycle`
- when a cycle completes, update `cycle_iterations`
- when a stage completes and is approved, set `current_cycle` to `null`

If the run is interrupted, resume from this state instead of guessing.

## Autonomous Cycle Protocol

This protocol replaces the interactive review and decision loop.

### Step 1: Run the Current Cycle

For the current stage:

1. read the stage entry file
2. read the current canonical stage YAML if it exists
3. read the current cycle YAML only
4. run the project-side stage script for that cycle
5. inspect the structured output

### Step 2: Self-Review

After script execution and before subagent review:

1. inspect outputs for:
   - Python exceptions
   - malformed or empty structured output
   - unanswered checklist items
   - artifact mismatches
   - route or claim-boundary violations
2. if issues are found, repair the script or cycle state and rerun
3. allow at most 2 self-correction rounds
4. if issues remain after 2 rounds, log them and continue to subagent review

Self-review is not a substitute for gate evaluation.

### Step 3: Subagent Review

Stage files still define what research and evaluation review must happen. Auto
mode changes only when to pause for the user.

### Step 4: Autonomous Decision

When the cycle reviews return:

1. verify required result structure is present
2. synthesize the cycle assessment
3. count `blocking_failures = blocking_defects + failed_gates`
4. apply the stage decision matrix

Decision rules:

- if verdict is `PASS` and `blocking_failures == 0`, pass the cycle
- if verdict is `FAIL` or `blocking_failures > 0`, iterate on the blocking issues
- if a follow-up cycle is recommended and material, auto-approve it subject to
  the caps below
- if backtracking is recommended, escalate instead of silently rewinding

Auto mode must log:

- why the cycle passed or failed
- which blocking issues drove the decision
- what changed during iteration
- whether a follow-up was opened

## Iteration Budgets and Caps

| Scope | Limit | On Exhaust |
|-------|-------|------------|
| Self-review corrections per cycle | 2 rounds | continue to subagent review |
| Main iterations per cycle | 3 rounds | escalate |
| Same follow-up topic in one stage | 2 repeats after first occurrence | escalate |
| Total follow-up cycles per stage | 4 | escalate |
| Total backtracks per full run | 3 | escalate |

If a cap is hit, stop and ask the user.

## Escalation Triggers

Auto mode pauses only at defined triggers.

Escalate when:

- required inputs are missing and cannot be inferred safely
- a stage script cannot execute after repair attempts
- canonical stage artifacts cannot be parsed or repaired
- a backtrack is recommended
- an iteration cap is hit
- a stage-boundary validator fails repeatedly
- the user previously set a hard constraint that blocks autonomous resolution

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

Before presenting stage approval options, run a stage-boundary validator.
Approval is blocked until the validator passes.

Stage-boundary validator requirements:

1. cycle completeness: confirm the stage's mandatory cycles and approved
   follow-up cycles ran to completion
2. finalization outputs: verify every artifact listed in the stage file exists
   and has content
3. empty-section detection: if the stage renders markdown sections, verify no
   required section is empty
4. canonical artifact validation: parse the stage YAML and any additional
   stage-specific machine-readable artifacts required for that stage
5. next-stage precondition pre-check: read the next stage's precondition rules
   and verify the new outputs satisfy them
6. README consistency: verify the stage summary block exists and matches the
   actual outputs
7. artifact consistency pass: every referenced file path must exist on disk
8. encoding scan: run the mojibake scan required by `core-principles.md`
9. state file sync: verify `auto_mode_state.json` reflects the stage just
   completed

The summary must include:

- cycles completed
- iteration counts
- follow-up cycles and why they were opened
- key autonomous decisions
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

1. read the stage entry file
2. read the active route file when applicable
3. run the stage precondition checks
4. execute mandatory cycles using the autonomous cycle protocol
5. execute approved follow-up cycles
6. execute post-cycle phases defined in the stage file
7. run the stage-close review
8. run the stage-boundary validator
9. present the stage summary
10. require stage approval before continuing

At the end of the full run, run a cross-stage consistency audit:

1. stage completeness across all seven stages
2. route consistency across all route-aware stages
3. claim-boundary monotonicity
4. file reference integrity
5. protocol commitment reconciliation
6. deliverable format verification
7. internal metrics consistency

If any audit check fails, reopen the relevant stage for repair before declaring
the run complete.
