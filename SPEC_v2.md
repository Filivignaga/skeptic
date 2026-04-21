# Skeptic v2 Refactor Spec

## Goals

Reduce per-sub-skill context usage while preserving the Veridical Data Science rigor, PCS discipline, gate and route machinery, and full audit trail of the current skill.

The refactor is guided by six changes.

1. **Canonical contract first. One stage YAML as the primary memory.**
- Each `/skeptic` stage writes one canonical YAML file first.
- That canonical YAML is created at stage start and updated cycle by cycle as the stage progresses.
- That YAML contains the enforceable contract and the stage state: question type, route, claim boundary, data-usage mode, frozen artifacts, validation rules, forbidden variables, backtracking triggers, compact metrics, and cycle history.
- The stage reads that YAML on later steps. It does not reread long `.md` files as its main memory.
- Markdown is generated only at the end as a human-readable report.
- If markdown and YAML disagree, YAML wins.

2. **Script-first execution with a narrow script role.**
- Stage logic should run in Python scripts, not by constructing notebooks during the workflow.
- Each stage can use one Python file that contains the code for all the cycles of that stage.
- Inside that file, each cycle is a separate function such as `run_cycle_a()`, `run_cycle_b()`, and so on.
- The model runs only one cycle at a time by passing an argument such as `python formulate.py --cycle B`.
- Even if the file contains all cycles, only the requested cycle runs.
- The file is shared, but the execution stays narrow.
- The script analyzes the dataset and related data artifacts for the current cycle.
- The script returns structured evidence from that analysis.
- The model interprets that evidence together with project documentation, the user question, and cycle reasoning.
- The canonical YAML records the resulting stage decisions.
- Notebooks are optional derived reports only. They are not canonical and not required for stage execution.
- Preferred flow: run script -> inspect evidence -> interpret in cycle context -> update canonical YAML -> render final markdown.

3. **Keep artifact roles clean and complementary.**
- The Python script is the analysis tool for the project data.
- The canonical YAML is the stage memory and decision record.
- The markdown report is the final human-readable render.
- The script answers questions such as variable structure, missingness, units, cardinality, ambiguity flags, type hints, sampling clues, and other data-derived findings.
- The YAML records the approved question, claim boundary, route, handoff state, cycle outcomes, and other stage conclusions.
- The YAML combines dataset evidence, project documents, user intent, and cycle reasoning into one canonical state.
- This gives the skill one evidence layer, one decision layer, and one communication layer.

4. **Keep the formulate artifact set lean.**
- `formulate` should write only the files that carry distinct value for the stage:
  - project-side execution script
  - canonical stage YAML
  - final rendered markdown report
- Compact metrics, gate state, narrowing history, and cycle history should live inside the canonical YAML when they are small and stage-specific.
- `README.md` should hold a short summary block for stage completion and status visibility.
- This keeps the file surface small and gives later chats one authoritative place to reload stage state.

5. **Load one YAML file per cycle only when that cycle is executed.**
- Keep `SKILL.md` lean. It should define only the shared stage structure, the repeated cycle pattern, and the pointers to cycle-specific files.
- Put each cycle in a single YAML file named for that cycle.
- Each cycle YAML should contain the fields needed to run that cycle:
  - inputs
  - outputs
  - checklists
  - gates
  - dependencies
  - required artifacts
  - a small `guidance` section with short judgment rules and execution goals
- Each checklist and each gate should be defined once inside its own collection.
- The model reads a cycle YAML file only when that cycle is about to run.
- This keeps active context limited to the current cycle instead of the full stage design.

## Current Direction

The refactor should move the skill toward:

- Python scripts as the execution layer
- model interpretation that writes YAML stage state
- markdown as a final rendered report
- cycle-specific reference files loaded only when needed

## Example: `formulate` before vs after

### Current `formulate`

**What the model reads at the start**
- `SKILL.md`
- `references/core-principles.md`
- `references/formulate.md`
- any extra referenced files such as `references/data-formats.md`

**What execution looks like now**
1. read the long prose stage file
2. create or append notebook cells
3. execute the notebook
4. reread notebook outputs
5. write cycle logs into `01_formulation.md`
6. append rows to `metrics.md`
7. keep `README.md` in sync
8. write the claim-boundary YAML at finalization

**Current output shape**
- `notebooks/01_formulation.ipynb` -> working scratchpad, evidence, outputs
- `skeptic_documentation/01_formulation.md` -> cycle logs, raw subagent outputs, summary
- `skeptic_documentation/metrics.md` -> metrics and repeated context
- `skeptic_documentation/claim_boundary_registry.yaml` -> canonical claim boundary written late
- `README.md` -> summary and status

**Current mental model**

```text
large prose instructions loaded first
        ->
notebook-centered execution
        ->
many outputs updated in parallel
        ->
canonical YAML appears late
```

### Future `formulate` example

**What the model reads at the start**
- lean `SKILL.md`
- `references/core-principles.md`
- a small stage entry file for `formulate`

**What execution should look like then**
1. read the lean stage entry
2. enter Cycle A
3. read `A.yaml`
4. write and run the Python script for Cycle A
5. inspect the returned dataset-analysis evidence
6. combine that evidence with project context and cycle judgment
7. update stage YAML
8. enter Cycle B
9. read `B.yaml`
10. write and run the Python script for Cycle B
11. repeat

**What each file does**
- `01_formulation.py` -> project-side analysis script for the stage
- `01_formulation.yaml` -> canonical stage contract, state, metrics, and cycle history
- `01_formulation.md` -> final rendered human report
- `README.md` -> short stage summary only

**How the Python script and YAML work together**
- The Python script analyzes the dataset and related data artifacts for the current cycle.
- The Python script returns a compact structured evidence packet for that cycle.
- The model reads that evidence and interprets it with the rest of the project context.
- The canonical YAML records the resulting stage decisions and handoff state.

**Future mental model**

```text
lean stage entry
        ->
load current cycle YAML only
        ->
run Python script for current-cycle data analysis
        ->
inspect evidence in cycle context
        ->
write canonical YAML first
        ->
render markdown at the end
```

### Core difference

- Current `formulate` is a long prose workflow that writes artifacts.
- Future `formulate` is a small orchestrator that loads one cycle spec at a time, runs narrow data analysis, and writes structured stage state first.

## Style

The skill should stay lean. The goal is to reduce memory pressure while increasing control, reproducibility, and downstream clarity.
