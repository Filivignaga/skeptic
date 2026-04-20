---
name: formulate
description: Use when starting a new data analysis project. Refine a rough domain question into a precise, data-answerable formulation through cycle-specific YAML specs, a project-side Python execution script, one canonical stage YAML file, and a final rendered markdown report.
---

# /skeptic:formulate - Problem Formulation and Data Context

Read `references/core-principles.md` first. It is the architecture contract.

## Required Inputs

| Input | Description |
|-------|-------------|
| Project name | Subfolder name under the configured `projects_root` |
| Data source(s) | Path, table, file list, or other portable locator for the raw data source |
| Rough domain question | What the user wants to answer with this data |

If any required input is missing, use `AskUserQuestion` before starting.

After collecting the project name:

1. Resolve the project path as `{projects_root}/{project-name}`.
2. Present the resolved path to the user for confirmation.
3. If the user gives an alternative path, use that path for this project only.
4. Keep all project-written files inside that project folder.
5. Copy local source files into the configured data directory.

Also ask whether documentation exists for the data, such as a codebook,
README, data dictionary, or collection notes. If it exists, copy it into the
project data directory and read it before Cycle A execution.

## Canonical Formulate Artifacts

Write these files in the project documentation directory:

```text
skeptic_documentation/
  01_formulation.py
  01_formulation.yaml
  01_formulation.md
```

Artifact roles:

- `01_formulation.py` -> project-side execution script for this stage
- `01_formulation.yaml` -> canonical stage contract and state
- `01_formulation.md` -> final rendered human-readable report only

If markdown disagrees with YAML, YAML wins.

## Stage-Specific Files

Load these files only when needed:

```text
references/formulate/cycles/A.yaml
references/formulate/cycles/B.yaml
references/formulate/cycles/C.yaml
references/formulate/cycles/D.yaml
references/formulate/cycles/E.yaml
```

Mandatory cycle order: A, B, C, D, E.

Follow-up cycles remain allowed after E, but each follow-up must define its own
checklist, gate IDs, and decision target before it runs.

## Stage Script Rules

Create the project-side script at:

`{project_root}/{docs_dir_name}/01_formulation.py`

The script is the execution layer for the whole stage. Keep it simple.

Required script shape:

1. One function per mandatory cycle:
   - `run_cycle_a()`
   - `run_cycle_b()`
   - `run_cycle_c()`
   - `run_cycle_d()`
   - `run_cycle_e()`
2. A CLI entrypoint that accepts `--cycle`.
3. Only the requested cycle may run.
4. The script must read the current `01_formulation.yaml`.
5. The script must emit one structured JSON object for the requested cycle.
6. Notebooks are optional derived reports only. They are not required for stage
   execution and are never canonical.

Required cycle JSON output keys:

```text
cycle
focus
status
checklist_answers
artifacts_checked
artifacts_written
gate_evidence
proposed_stage_updates
protocol_handoff_updates
questions_or_gaps
```

The agent runs one cycle at a time:

```text
python 01_formulation.py --cycle A
python 01_formulation.py --cycle B
...
```

## Canonical YAML Rules

Create `01_formulation.yaml` before Cycle A work begins. It is the primary
memory for the stage. Update it after every cycle.

Minimum required sections:

```yaml
stage: formulate
status: in_progress
updated_at: null
project:
  name: null
  root: null
  sources: []
  data_documentation: []
question_contract:
  rough_question: null
  approved_question: null
  question_type: null
  active_route: null
  route_candidates: []
  target_quantity: null
  unit_of_analysis: null
  target_context: null
  audience: null
  decision_anchor: null
  baseline: null
  minimum_useful_uplift: null
  unacceptable_errors: []
claim_boundary:
  scope: null
  evidence_ceiling: null
  verbs_allowed: []
  verbs_forbidden: []
  generalization_limit: null
  narrowing_log: []
protocol_handoff:
  data_usage_mode: pending_protocol
  frozen_artifacts: []
  validation_rule_candidates: []
  forbidden_variable_classes: []
  backtracking_triggers: []
  open_questions: []
cycle_state:
  current_cycle: A
  completed_cycles: []
  iteration_counts: {}
  followup_cycles: []
gates:
  latest: {}
  history: []
metrics:
  checklist_answered: {}
  blocking_failures: {}
  overrides: []
  acknowledged_gaps: []
cycle_history: []
artifacts:
  markdown_report: null
  readme_updated: false
```

Use additional fields when needed. Do not remove these sections.

## Cycle Loop

For each cycle:

1. Read `references/formulate/cycles/{cycle}.yaml`.
2. Read the current `01_formulation.yaml`.
3. Run `01_formulation.py --cycle {cycle}`.
4. Inspect the structured JSON output.
5. Apply the cycle YAML checklist and gate rules.
6. Update `01_formulation.yaml` first.
7. Record one compact cycle history entry inside `01_formulation.yaml` `cycle_history`.
8. Update the `metrics` block inside `01_formulation.yaml`.
9. Move forward only if the cycle decision allows it.

Do not keep the whole stage file or all cycle files in active memory.

## Shared Decision Rule

Use the standard Skeptic decision matrix from `core-principles.md`.

For formulate:

- pass -> move to the next cycle
- iterate -> rerun the same cycle after targeted fixes
- acknowledge gap -> only with written justification in `01_formulation.yaml`
- data insufficient -> stop, log why, and present options
- reopen formulate -> allowed inside the stage if a prior cycle needs repair
- user override -> log the exact override reason before moving forward

If the data cannot support the intended question:

- request additional data
- reformulate to a question the data can support
- archive with documentation

## Finalization

Finalize only after:

1. all mandatory cycles pass or are explicitly resolved by justified gap or
   override
2. the approved question is locked
3. the protocol handoff is complete
4. the claim boundary section is finalized inside `01_formulation.yaml`
5. the final markdown report is rendered from canonical YAML

Finalization outputs:

1. render `01_formulation.md` from the canonical YAML
2. update `README.md` with the short formulate summary block
3. verify the README block exists and is non-empty before declaring completion

Do not treat the markdown report as working memory. It is a final render only.

## Dependency Notes

- `protocol` is the mandatory next stage.
- `formulate` chooses the question and claim boundary.
- `protocol` chooses how that question may be answered.
- If question type, target quantity, or claim boundary changes later, reopen
  both `formulate` and `protocol`.
