# Skeptic Skill - Fix Proposal v3

Status: draft. No changes applied. Each fix is approve/reject per block.

Scope rule: every fix must land on the skill side (`references/core-principles.md`, stage entry `{stage}.md`, per-cycle YAMLs under `references/{stage}/cycles/`, route overlays under `references/routes/{route}/{stage}.md`, commands in `commands/`) in a project-agnostic way. Any project-side YAML or script example is illustrative only; the spec rule must be expressible without naming any specific dataset, column, domain, or measurement device.

Layout of this document:
1. Fix list (author's proposal, verbatim).
2. Cross-skill propagation — one section per block, filled in by a parallel sub-agent pass over every Skeptic stage and route overlay.
3. Implementation map — aggregated table, one row per spec file to touch.
4. Proposed additions to `core-principles.md`.

Cross-skill propagation pass status: **complete** (7 parallel sub-agents, one per block).

---

## 1. Fix list (author's proposal, verbatim)

### A. Stop writing the same facts in 2, 3, or 4 places (biggest time saver)

#### Fix A1. Drop `upstream_snapshot` from the clean YAML
**Now:** Lines 27-159 of `03_cleaning.yaml` copy the question, the protocol rules, the prohibitions, etc. from `01_formulation.yaml` and `02_protocol.yaml`. Around 130 lines of copy-paste.
**Change:** Replace with one small block that just points to those files and records their hashes, so you can still detect drift.
**Where:** Skill spec (`~/.claude/skills/skeptic/references/clean/clean.md` schema) and this project's `03_cleaning.yaml`.
**Why it helps:** You read the same rules once instead of twice. ~130 fewer lines.

#### Fix A2. Keep the hash check once, not four times
**Now:** The SHA-256 of `eventi.csv` appears in `precondition_check`, `visibility`, `data_contract`, and `cycle_history[A]`.
**Change:** Record it in one place (`provenance.files`) and reference by filename after that.
**Where:** Skill spec + project YAML.
**Why it helps:** No hunting for "which copy is right?" ~30 fewer lines.

#### Fix A3. Delete the `visibility` top-level key
**Now:** It lists which files the stage is allowed to read. The same info is already in `02_protocol.yaml`.
**Change:** Remove the section. If we need integrity auditing, keep one line (`visibility_hash`).
**Where:** Skill spec + project YAML.
**Why it helps:** ~28 fewer lines.

#### Fix A4. Collapse the 4-way list duplication in Cycle C
**Now:** Each cleaning issue is written as 4 near-identical dicts: `policy_options`, `chosen_policies`, `action_code_trace`, `population_shift_per_action`. For 12 issues that's 48 dicts saying similar things.
**Change:** One list, one entry per issue, with sub-fields for `options`, `chosen`, `code_ref`, `population_shift`.
**Where:** Skill spec `cycles/C.yaml` and project YAML + script.
**Why it helps:** You see each issue once, in one place. ~300 fewer lines of YAML + script.

#### Fix A5. Collapse Cycle E's five look-alike "retain as raw" entries
**Now:** `preprocessing_decisions` has PP-E-02-01 through PP-E-02-05 saying "keep this column as-is" five times, once per column, with nearly identical rationale.
**Change:** One entry: `retained_as_is: [list of columns]` with a single shared rationale.
**Where:** Project YAML.
**Why it helps:** ~40 fewer lines; easier to see that five columns got the same treatment.

#### Fix A6. Shrink `pcs_review.verbatim` (352 lines)
**Now:** The PCS subagent's full reply is pasted into the YAML. Most of its bullets recite counts that already live in `row_count_reconciliation` and `dataset_fitness_reviews`.
**Change:** Keep only the three lens verdicts (Predictability, Stability, Computability), the user disposition, and any open conditions. Move the full reply to `pcs_review.json` as a side file if you want the audit trail.
**Where:** Skill spec + project YAML.
**Why it helps:** ~300 fewer lines. The verdict is easier to find.

#### Fix A7. Trim `cycle_history[*].script_evidence` to actual one-liners
**Now:** Some bullets are multi-clause paragraphs restating Cycle A gates or listing 7 transforms by name.
**Change:** Enforce the spec's own "4-8 one-line bullets" rule. One value per `evidence_key`. The detail already lives in `scripts/stdout/cycle_X.json`.
**Where:** Project YAML (and a reminder in the skill spec).
**Why it helps:** Reading the history feels like reading decisions, not a dump.

---

### B. Stop the YAML from inviting false narrative

#### Fix B1. Rule: no numbers in YAML prose unless they cite a script evidence key
**Now:** The YAML wrote "single row at 43,819" (wrong, it was 3 rows) and `idu_razza ∈ {00,01,02,03,15}` (wrong, actually `{00,02,04,07,15}`). Both errors came from the agent typing numbers into prose without checking the script's actual output.
**Change:** Any numeric or categorical claim in the canonical YAML must name the `evidence_key` it came from. A simple check scans the YAML for digit patterns without a nearby `evidence_key:` reference and flags them.
**Where:** Skill spec (new rule), plus a tiny check script.
**Why it helps:** Prevents the "I remember it was around X" bug class. Also makes the YAML shorter because you stop narrating numbers.

#### Fix B2. Move research citations out of the canonical YAML
**Now:** Research sources are written as free-form strings in `cycle_history[*].subagents.research_sources`. The fake "Probo et al <240-day abortion" citation and the fake "Yu & Barter taxonomy" survived several cycles this way.
**Change:** Research findings go to a separate `research_log.jsonl` (one line per finding with `cycle, url, claim_used, verified_at`). The YAML only keeps a pointer like `source: research_log#7`.
**Where:** Skill spec + new project file.
**Why it helps:** Fixing a bad citation is one line, not YAML surgery. Fake citations can be flagged and removed without rewriting history.

---

### C. Ask the user at the right moments

#### Fix C1. Mandatory check-in at Cycle B, Cycle C, and Cycle S
**Now:** The spec says "expect ambiguities in Cycles B, C" and invites `AskUserQuestion`, but in your session nothing was asked until the very end. The agent picked the Fossomatic cutoffs, the 365-day back-entry threshold, and every stability threshold by itself.
**Change:** At three fixed gates the agent must dispatch `AskUserQuestion`:
- Cycle B: one question summarizing the top missing-vs-censored policy choice
- Cycle C: one question about irreversible exclusions bigger than 0.1% of rows
- Cycle S: one question approving the stability thresholds
If you have no preference, you answer "agent decides" and the entry is recorded. But the question is always asked.
**Where:** Skill spec (per-cycle YAMLs).
**Why it helps:** Breaks the self-approving loop. The agent no longer grades its own choices.

---

### D. Make Cycle S actually test stability

#### Fix D1. Derive instability thresholds, don't let the agent pick them
**Now:** The agent sets its own thresholds and then checks its work against them. First Cycle S run failed; agent widened the "expected" map; second run passed.
**Change:** Thresholds are computed from the data (for example, `threshold = 2 × bootstrap std of metric`) or read from an external standard (ICAR, AIA, BDN) when one applies. User approves the computed number; the agent does not invent it.
**Where:** Skill spec `cycles/S.yaml` + project script `run_cycle_s`.
**Why it helps:** A cycle can actually fail on honest grounds and catch real instability.

#### Fix D2. Compute `expected_exceedances` from the dependency graph, not by hand
**Now:** The agent hand-writes which QCVs each perturbation "should" move. When arithmetic complements were missed (shifting `pa_short_pct` also shifts `pa_plausible_pct`), the cycle failed for the wrong reason.
**Change:** Derive the expected set automatically: if metric Y is a function of the perturbed parameter, it's expected. The agent cannot "forget" coupled metrics.
**Where:** Project script.
**Why it helps:** No more reruns to fix hand-written maps. Real exceedances stand out.

---

### E. Fix broken mechanics

#### Fix E1. Rewrite the constraint verifier as a one-liner
**Now:** `_verify_clean_constraints` has a two-branch null handler that confuses `NaN` with `None` and falsely flagged a valid row in Cycle R, costing ~5 minutes of debugging.
**Change:** Replace with `bad = ser[ser.notna() & ~ser.isin(allowed)]`. Null is handled by a separate `nullable: true/false` flag. One line, no edge cases.
**Where:** Project script (`scripts/03_cleaning.py`). Also the same code lives in `_verify_preprocess_constraints`, fix both.
**Why it helps:** Removes a whole class of false failures.

#### Fix E2. Load the raw CSV once, not six times
**Now:** `run_cycle_a`, `run_cycle_b`, `run_cycle_c`, `run_cycle_e`, `run_cycle_f`, `run_cycle_r`, `run_cycle_s` each reload and re-parse `eventi.csv`. They can even disagree on dtypes between cycles (that's what caused the false mismatch on `matricola` in Cycle A).
**Change:** One module-level `load_raw()` with memoization. Every cycle calls it.
**Where:** Project script.
**Why it helps:** Cuts ~200 lines. Removes the "cycle N and cycle N-1 see different dtypes" bug.

#### Fix E3. One dtype-meaning helper instead of ad-hoc checks per cycle
**Now:** Each cycle writes its own dtype comparison. The pandas 3.x string-dtype false positive in Cycle A is a symptom.
**Change:** A single helper `check_dtype_meaning(series, expected_meaning)` that handles pyarrow strings, nullable ints, etc.
**Where:** Project script.
**Why it helps:** Fixes are in one place.

---

### F. Trim the cycle spec itself (skill-side)

#### Fix F1. Merge Cycle E into Cycle C's closeout
**Now:** Cycle E is ~295 lines of script that mostly confirms "we didn't transform these columns because Cycle C already decided not to." It adds no new data understanding.
**Change:** Fold the two or three useful E checks (fit-scope leakage, deferred list) into Cycle C's final step. Drop the cycle.
**Where:** Skill spec (delete `cycles/E.yaml`, update `clean.md`).
**Why it helps:** One less cycle to run, ~300 script lines gone.

#### Fix F2. Delete checklist items that are pure bookkeeping
Items that can go with no loss:
- **B06** (restricted-artifact audit): skipped whenever no restricted artifact exists; when it applies it duplicates A01.
- **A08** (naming-convention audit): records style, never changes a decision.
- **C03** (action code trace): traceability already covered by Cycle R.
- **E04** (deferred transforms list): a code comment is enough.
- **R04** (constraint files present): a filesystem assertion.
- **F02** (derived-variable compatibility): repeats F01's inputs.
- **S06** (one-paragraph robustness summary prose): derivable from the structured fields.
**Where:** Skill spec cycle YAMLs.
**Why it helps:** Fewer gates to answer, fewer evidence keys to produce. Cycles feel like investigations, not compliance checks.

#### Fix F3. Only run the dual research+evaluation subagents when new domain knowledge can change an outcome
**Now:** Every cycle dispatches both subagents in parallel. In your session, Cycle E and Cycle R evaluations each returned "PASS with 0-3 documentation nits", and the Cycle F research agent stalled, costing ~6 min.
**Change:** Keep dual subagents only on Cycles B, C, and S (where judgment calls happen). Cycles A, E, F, R run evaluator-only.
**Where:** Skill spec.
**Why it helps:** Saves ~15-20 min per stage. No more stalls on cycles that don't need research.

---

### G. What I will NOT touch

So you know what stays:
- `cleaning_decisions` with rationale, source, reversibility, population shift, claim consequence. This IS the deliverable.
- `question_critical_variables` (the cl_pom structural zero, Fossomatic left-censoring, idu_razza Jersey correction, back-entry provenance).
- `row_count_reconciliation`, `narrowing_log`, `dataset_fitness_reviews`.
- The actual pandas work in `run_cycle_b` and `run_cycle_c`.
- The `clean_data` and `preprocess_data` helpers (the spec's whole reproducibility contract depends on them).
- The README's `## Clean [COMPLETE]` block.

---

## Summary of impact if you accept everything

| Metric | Before | After |
|---|---|---|
| `03_cleaning.yaml` lines | 1,799 | ~500-600 |
| `03_cleaning.py` lines | 3,341 | ~1,400 |
| Wall time per clean stage | ~148 min | ~60-80 min |
| Cycles run | A, B, C, E, F, R, S | A, B, C, F, R, S |
| Subagents per cycle | 2 × 7 = 14 | 2 × 3 + 1 × 3 = 9 |
| Sources of narrative drift | prose numbers + free-form citations | evidence-key references + research_log.jsonl |
| Self-approving loops | thresholds + expected exceedances | both derived or user-approved |

---

## Order to apply (lowest risk first)

1. **E1 + E2 + E3** mechanics fixes in the script. Zero spec risk, pure bug fixes.
2. **A4 + A5 + A6** trim the bloated sections in this project's YAML. Local, reversible.
3. **B1 + B2** evidence-key rule + research_log.jsonl. One new rule, one new file.
4. **A1 + A2 + A3 + A7** spec-side duplication removal. Touches the skill.
5. **F2 + F3** delete bookkeeping items, scale back dual subagents. Touches the skill.
6. **C1** mandatory user check-ins. Changes workflow; try on one stage first.
7. **F1** merge Cycle E into C. Biggest spec change; do after the rest is stable.
8. **D1 + D2** threshold derivation + auto expected_exceedances. Hardest to get right; do last.

---

## Project-agnostic abstraction target

Every fix above was discovered on one dataset, but the underlying pathology is not dataset-specific.

| Fix block | Pathology in abstract form |
|---|---|
| A | Canonical YAML duplicates upstream facts instead of referencing them |
| B | Natural-language prose in a machine-readable artifact invites fabrication |
| C | Agent self-approves judgment calls that the user should own |
| D | Agent picks its own pass/fail thresholds |
| E | Shared script logic is reimplemented per-cycle, spreading the same bug 6 ways |
| F | Cycles and checklist items survive past their usefulness |
| G | Deliverable content (the decisions themselves) stays protected |

The sub-agent pass below maps each pathology against every Skeptic stage (formulate, protocol, clean, examine, analyze, evaluate, communicate) and every route overlay (causal, descriptive, exploratory, inferential, mechanistic, predictive). Goal: the fix is expressed once in the core spec or once per stage, never once per project.

---

## 2. Cross-skill propagation

### A. Duplication removal

**Scope sweep.** One sub-agent read every stage entry `.md`, every `cycles/*.yaml`, every route overlay under `references/routes/`, `core-principles.md`, `constraint-spec.md`, `auto-mode.md`, every `commands/*.md`, and `SKILL.md`. All seven sub-fixes recur in at least two stages; A6 (`pcs_review.verbatim` full-reply paste) appears in every stage entry file without exception.

#### A1. `upstream_snapshot` — downstream stage copies prior-stage rules verbatim

| File | Section / key path | What is duplicated |
|---|---|---|
| `references/clean/clean.md` | `upstream_snapshot:` block (~lines 77-91) | `approved_question`, `question_type`, `target_quantity`, `claim_boundary`, `operationalization`, `unit_of_analysis`, `key_assumptions`, `data_usage_mode`, `leakage_rules`, `forbidden_variable_classes`, `clean_prohibitions`, `validation_logic_reserved`, `backtracking_triggers`, `protocol_required_artifacts` — all already canonical upstream |
| `references/clean/clean.md` | Step 1, bullet 3 | Instructs the copy at stage-start |
| `references/clean/cycles/A.yaml` | `setup_side_effects` item initializing `upstream_snapshot` | Operationalizes the copy |
| `references/clean/cycles/C.yaml` | `upstream:` lines 12-14 | References `upstream_snapshot.claim_boundary`, `.clean_prohibitions`, `.forbidden_variable_classes` — locks the copied fields into the cycle |
| `references/clean/cycles/E.yaml` | `upstream:` lines 12-14 | Same pattern, four keys |
| `references/clean/cycles/F.yaml` | `upstream:` lines 8-11 | Four `upstream_snapshot.*` keys |
| `references/clean/cycles/S.yaml` | `upstream:` line 14 | `upstream_snapshot.data_usage_mode` |
| `references/examine/examine.md` | `upstream:` block (~lines 66-84) | Parallel subset restatement |
| `references/examine/cycles/A.yaml` | `setup_side_effects` | Copy instruction |
| `references/communicate/communicate.md` | `upstream_snapshot:` block (~lines 69-79) | 10-field restatement from all prior stages |
| `references/communicate/cycles/A.yaml` | `setup_side_effects` | Copy instruction |

No analogous block in `formulate.md`, `protocol.md`, `analyze.md`, or `evaluate.md` — those stages read upstream YAMLs at cycle-start and use fields in memory.

**Abstracted fix.** A downstream stage YAML must not contain a top-level section that verbatim copies fields already canonical in an `<upstream_stage>` YAML. When `<stage>` needs a fact from `<upstream_stage>`, the agent reads it at cycle start and references it in memory. The only permitted downstream records about upstream are: (a) the artifact path(s) read (in `provenance` or `upstream.{stage}_yaml`), and (b) a compact verification verdict when the fact drives a gate (e.g., `precondition_check.raw_hash_verification`). Replace `upstream_snapshot:` blocks with:

```yaml
upstream_pointer:
  sources:
    - path: <docs_dir>/<upstream_file>
      content_sha256: <hex>
  note: "Read fields directly from source files; do not copy here."
```

**Target class.** `core-principles.md` Universal Rules; every stage-entry `.md` schema that carries `upstream_snapshot`.

#### A2. Same SHA-256 recorded in multiple sections

| File | Section / key path | Role |
|---|---|---|
| `references/formulate/cycles/A.yaml` | A07 `writes_to: provenance.files` | **Authoritative single source; keep.** |
| `references/clean/clean.md` | `precondition_check.raw_hash_verification` | Re-records `{expected, observed, match}` |
| `references/clean/cycles/A.yaml` | A00 hash verification + setup_side_effects | Instructs the copy |
| `references/analyze/analyze.md` | `provenance.upstream_artifacts: {path: sha256}` | Extends pattern to document-level artifacts |
| `references/analyze/cycles/A.yaml` | `setup_side_effects` item | Instructs the copy |
| `references/evaluate/evaluate.md` | `reproducibility.frozen_artifact_hashes` | Re-records expected+observed |
| `references/evaluate/cycles/A.yaml` | A09 | Instructs the re-verification |

**Abstracted fix.** Record each file's SHA-256 exactly once in `provenance.files.<filename>.sha256` at the stage that first ingests it. Downstream integrity checks compute the digest and emit a compact `{expected, observed, match: bool}` to a single verification field. Only the match verdict is written into the downstream canonical YAML; the hash value itself does not propagate.

**Target class.** `core-principles.md` Canonical Artifact Model + Stage Script Rules.

#### A3. `visibility:` top-level block restates protocol declaration

| File | Section / key path |
|---|---|
| `references/clean/clean.md` | `visibility:` block (visible_raw_files, visible_protocol_artifacts, restricted_artifacts, access_levels) |
| `references/clean/cycles/A.yaml` | A01 `evidence_key: visibility_snapshot`, `writes_to: visibility` |
| `references/examine/examine.md` | `visibility:` block (visible_cleaned_artifacts, ...) |
| `references/examine/cycles/A.yaml` | `setup_side_effects` + A01 `evidence_key: visibility_map` |
| `references/analyze/analyze.md` | `provenance.visibility_set:` |
| `references/analyze/cycles/A.yaml` | `setup_side_effects` |

**Abstracted fix.** The authoritative visibility set lives in `02_protocol.yaml` under `data_usage`, `frozen_artifacts`, and `evidence_rules`. Each downstream stage derives its operative set from those fields at cycle-start and records it as a single compact artifact list — `<stage>.visibility.visible_artifacts: [{name, access_level}]` — not as a re-documentation of protocol rationale. One optional `visibility_hash:` scalar is permitted for integrity auditing.

**Target class.** `core-principles.md` Universal Rules; `clean.md`, `examine.md`, `analyze.md` schemas.

#### A4. Four parallel lists for the same issue

| File | Current shape |
|---|---|
| `references/clean/cycles/C.yaml` | Items C01–C04 produce four lists keyed by `issue_id`: `policy_options` (C01), `chosen_policies` (C02), `action_code_trace` (C03), `population_shift_per_action` (inside C04) |
| `references/clean/clean.md` | `cleaning_decisions` schema expects composite records; the cycle spec emits four separate keys that merge only through `writes_to` |

**Abstracted fix.** When a cycle characterizes `N` issues along multiple dimensions, the cycle YAML emits one composite evidence record per issue: `{<issue_id>, <dimension_1>, ..., <dimension_k>}`. Parallel lists sharing the same index key are prohibited. The schema for `cleaning_decisions` (and equivalents in other stages) already accepts this shape; the cycle checklist must produce evidence in that shape directly. *(Block G narrowing: every field required by the spec's `cleaning_decisions[]` schema must remain present after the collapse; this is a convergence toward the schema, not a simplification away from it.)*

**Target class.** `references/clean/cycles/C.yaml` checklist; `core-principles.md` as a general principle for cycle evidence design.

#### A5. Near-identical singleton entries per column

| File | Section / key path |
|---|---|
| `references/clean/clean.md` | `preprocessing_decisions:` — schema permits one entry per decision, not per column, but lacks a prohibition against per-column repetition |
| `references/clean/cycles/E.yaml` | E02 `category_representation` and E03 `numeric_date_representation` produce one list element per column, even when all share the same rationale |

**Abstracted fix.** When `N` columns receive the same decision with the same rationale, rationale source, reversibility, and fit scope, the agent records one entry with `columns: [<col_1>, ..., <col_N>]`. A per-column entry is required only when any field differs between columns. Rule applies equally to `cleaning_decisions` entries sharing a policy across columns. *(Block G narrowing: collapse is only valid when reversibility, population_shift, and claim_consequence are genuinely identical across the listed columns; the schema's required fields are preserved per collapsed entry.)*

**Target class.** `references/clean/clean.md` schema rules; `references/clean/cycles/E.yaml` guidance (folded into Cycle C if F1 is approved).

#### A6. `pcs_review.verbatim` full paste

| File | Instruction |
|---|---|
| `references/formulate/formulate.md` | "Store the full output in `pcs_review.verbatim`" |
| `references/protocol/protocol.md` | Same |
| `references/clean/clean.md` | Same (also referenced in the Finalization scorecard) |
| `references/examine/examine.md` | Same |
| `references/analyze/analyze.md` | Same |
| `references/evaluate/evaluate.md` | Same |
| `references/communicate/communicate.md` | Same; additionally parses into `pcs_review.checks` |

**Abstracted fix.** `pcs_review` holds a structured digest: for each PCS lens (Predictability, Computability, Stability, plus any route-specific lens), one `verdict ∈ {holds_up, uncertain, risky}`, one `key_finding` (single sentence), one `recommendation` (single sentence or `null`). `disposition` and `disposition_reason` remain as specified. The full subagent reply stays in memory (or, if an audit trail is desired, lands in a side file `pcs_review.json` outside the canonical YAML). The field name changes from `verbatim` to `digest` to signal the contract.

**Target class.** `core-principles.md` Canonical Artifact Model (subagent output rule); every stage-entry PCS Subagent Review section.

#### A7. `cycle_history[*].script_evidence` multi-clause paragraphs

| File | Location |
|---|---|
| Every stage entry `.md` | schema comment on `cycle_history` ("4-8 one-line bullets, or one-line value per evidence_key") + Step 5 restatement |
| `references/core-principles.md` | Stage Script Rules — master statement |

The rule is stated correctly in all nine locations. The pathology is runtime non-compliance, not spec ambiguity.

**Abstracted fix.** Add to the schema comment and Step 5 in every stage entry: one compliant example (`- <evidence_key>: <one-line value>`) and one non-compliant example (multi-clause prose starting with "The script found that..."). Add to each stage's evaluation subagent prompt, DEFECT SCAN: "Verify each `cycle_history[*].script_evidence` entry is one line, no line wrap, no two independent clauses. Any violation is a non-blocking defect."

**Target class.** Every stage-entry `.md` schema comment + Step 5; `core-principles.md` Stage Script Rules; every evaluation subagent prompt.

#### Candidate universal rule for `core-principles.md` (Block A)

> **Single-source-of-truth discipline for canonical YAMLs.** Each fact has exactly one canonical home. (1) Facts from `<upstream_stage>` must be read at cycle-start and held in memory; they must not be copied into a new top-level block of the current stage's canonical YAML. The only permitted downstream record of an upstream fact is a compact verification verdict. (2) A file hash recorded in `provenance.files` of the ingesting stage is never re-recorded as a value in any downstream YAML; only the `match: bool` verification verdict travels downstream. (3) The visibility set for each stage is derived from `02_protocol.yaml` at cycle-start and stored as a compact artifact list, not a re-documentation of protocol rules. (4) When multiple items share the same decision, rationale, and fit scope, collapse them into one record with a `columns:` or `items:` list; per-item duplication is prohibited. (5) Subagent output is digested into `{lens, verdict, key_finding, recommendation}` per lens; full reply text never enters the canonical YAML. (6) `cycle_history[*].script_evidence` entries are one-line bullets; multi-clause prose is a defect the evaluation subagent must flag.

---

### B. Machine-readable artifacts free of narrative drift

#### B1. Numeric drift in YAML prose — inventory

| File | Section / key path | Current shape | Why it invites drift |
|---|---|---|---|
| All seven stage `.md` files | `cycle_history[*].script_evidence` | Unstructured bullets | Numbers typed from the stdout JSON go unchecked |
| All stage `.md` files | `cycle_history[*].subagents.decisions[*].why` | Free-form string | `why` restates quantitative findings without naming the `evidence_key` |
| All stage `.md` files | `cycle_history[*].subagents.rejected_alternatives[*].reason` | Free-form string | Same risk |
| All stage `.md` files | `cycle_history[*].subagents.open_risks` | `[str]` | Risk descriptions carry numeric thresholds, percentages, cardinality — unbound |
| `formulate.md` | `contract.operationalization.{term}.rationale` | Free-form string | Numeric cutoffs (minimum sample size) typed without evidence-key reference |
| `clean.md` | `cleaning_decisions[*].rationale`, `.population_shift.before/after` | Free-form string; struct | `before`/`after` row counts must come from `row_count_and_population` but are not pinned |
| `clean.md` | `row_count_reconciliation.*` | Scalars | No `evidence_key:` sibling; model may type from recollection |
| `clean.md` | `derived_variables[*].{distribution, missingness}` | Free-form prose | Distribution numbers unbound |
| `examine.md` | `structure_profile.distributions_and_coverage.{artifact}.{column}.compact_summary` | Free-form string | Range bounds, percentiles, counts typed from memory |
| `examine.md` | `structure_profile.subgroup_presence.{dimension}.*` | Free-form values | Category set literals and level counts unbound |
| `examine.md` | `anomalies_and_contradictions.inventory[*].description` | Free-form | Counts and codes embedded without cite |
| `examine.md` | `support_registry.*[*].{item, evidence_ref}` | `{item, evidence_ref: str}` | `evidence_ref` is a label, not a typed pointer |
| `analyze.md` | `contract.primary_specification` | Object | Parameter values untyped; no evidence-key link |
| `analyze.md` | `comparison_table[*].{primary, per_axis, per_challenger}` | Mixed | Point estimates and intervals without explicit pointer enforcement |
| `evaluate.md` | `stability_verdicts`, `predictability_verdicts`, `validity_verdicts` | `{verdict, evidence, caveats}` | `evidence` free-form; numeric thresholds unbound |
| `evaluate.md` | `claim_survival_registry[*].evidence_summary` | Free-form | Numbers summarizing effect sizes or pass rates unbound |
| All stages | `pcs_review.verbatim` | Long unstructured text | Subagent's numeric claims reused in `disposition_reason` without citation |
| `constraint-spec.md` | `params.{min, max}`, cardinality counts | JSON | Spec does not require naming the output key alongside each param |

**Abstracted fix.** Define a grammar of numeric tokens (decimal integers, decimal fractions, percentages, alphanumeric set literals in `{}`/`[]`, ISO-like date literals, unit-suffixed values) and require that any YAML prose field containing such a token carry a valid evidence-key citation: either a sibling `evidence_key: <key>` from the owning cycle's checklist, or an inline pointer `(source: <cycle_id>.<evidence_key>)`. Exempt keys: `sha256`, `schema_version`, cycle-ID strings, ISO-date metadata fields (`started_at`, `locked_at`, `last_updated`), `random_seeds`, `auto_mode_state.json` counters. The check runs at canonical-YAML write time; unbound tokens are a blocking defect.

**Linter pseudocode**

```python
import re, yaml

NUMERIC_TOKEN = re.compile(r"""
    (?<!\w)
    (?:
        \{[A-Za-z0-9,\s]+\}              # set literal: {00,02,07}
      | \[[0-9,\s]+\]                    # numeric list: [1,2,3]
      | [0-9]+(?:\.[0-9]+)?%             # percentage: 12.5%
      | [0-9]+\.[0-9]+                   # decimal: 3.14
      | [0-9]{4}-[0-9]{2}(?:-[0-9]{2})?  # date: 2024-01, 2024-01-15
      | [0-9]+                            # plain integer
    )
    (?!\w)
""", re.VERBOSE)

EXEMPT_KEYS = {"sha256", "schema_version", "current_cycle", "completed_cycles",
               "locked_at", "started_at", "last_updated", "random_seeds",
               "backtrack_count", "stage_attempts", "cycle_iterations"}

EVIDENCE_REF = re.compile(r"\(source:\s*[A-Z][0-9]+\.[a-z_]+\)")

def lint_numeric_bindings(yaml_path, cycle_evidence_keys):
    violations = []
    doc = yaml.safe_load(open(yaml_path))
    def walk(node, path):
        if isinstance(node, dict):
            for k, v in node.items(): walk(v, f"{path}.{k}")
        elif isinstance(node, list):
            for i, x in enumerate(node): walk(x, f"{path}[{i}]")
        elif isinstance(node, str):
            leaf = path.rsplit(".", 1)[-1]
            if leaf in EXEMPT_KEYS: return
            tokens = NUMERIC_TOKEN.findall(node)
            if tokens and not EVIDENCE_REF.search(node):
                violations.append(f"UNBOUND {tokens} at {path}: add (source: <cycle>.<evidence_key>)")
    walk(doc, "root")
    return violations
```

Word-boundary anchors (`(?<!\w)`/`(?!\w)`) keep `A01`, version strings, and hash prefixes from matching. The set-literal regex requires comma-separated alphanumerics and excludes YAML mapping braces by context.

**Target class (B1).** `core-principles.md` Universal Rules + Canonical Artifact Model; Step 5 in every stage entry; templates for follow-up cycles (`F_template.yaml`, `D_template.yaml`, `G_template.yaml`, `E_template.yaml`).

#### B2. Free-form citations in `research_sources`

| File | Section / key path | Current shape | Why it invites drift |
|---|---|---|---|
| All stage `.md` files | `cycle_history[*].subagents.research_sources` | `[{url, claim}]` | Neither field carries a verification timestamp or pointer to a durable log |
| All stage `.md` files | `cycle_history[*].subagents.decisions[*].source` | `int?` index | Links to `research_sources` whose contents are unverified |
| `formulate.md` Step 3 | Research subagent prompt | Free-form inline URL in prose | No verification step between subagent reply and YAML |
| Every Step 3 evaluation prompt | Instruction | Prose | Evaluation subagent repeats claims from research without independent fetch |

**Abstracted fix — `research_log.jsonl` schema**

```json
{
  "log_id":             "<stage>-<cycle>-<int>",
  "stage":              "<formulate|protocol|clean|examine|analyze|evaluate|communicate>",
  "cycle":              "<cycle_letter_or_id>",
  "iteration":          0,
  "url":                "<absolute URL>",
  "title":              "<page/paper title from fetch>",
  "author_year":        "<Author YYYY or null>",
  "claim":              "<one-sentence claim this source supports>",
  "fetched_at":         "<ISO-8601 datetime of subagent fetch>",
  "verified_at":        "<ISO-8601 datetime of main-model confirmation, or null>",
  "verified_by":        "<research_subagent|main_model|evaluation_subagent>",
  "http_status":        200,
  "influenced_decision":"<decision ID, or null>"
}
```

Cardinality: one record per `(stage, cycle, iteration, url, claim)`. Append-only. Location: `{docs_dir_name}/research_log.jsonl`. YAML entries change shape to `{log_id, url, claim}` where `log_id` is the primary key. Verification policy: the main model must fetch and content-check every null-`verified_at` citation before the cycle closes; unverified citations may not be the sole support for any `decisions[*]` entry. Evaluation subagent checks that every `log_id` resolves and every citation used as a decision source is `verified_at: non-null`.

**Target class (B2).** `core-principles.md` Canonical Artifact Model; every stage-entry `.md` Step 3 prompt + Step 5 Log + `research_sources` schema shape; cycle YAMLs defining `research_questions` (comment only).

#### Candidate universal rule for `core-principles.md` (Block B)

> **Machine-readable artifact integrity.** Canonical stage YAMLs hold only structured values or typed pointers to named evidence keys; narrative prose with embedded numeric or categorical claims is forbidden. Every integer, decimal, percentage, category set, or date literal in a YAML field must trace to a named `evidence_key` in the owning cycle's script output, cited as `(source: <cycle_id>.<evidence_key>)`. Research citations are stored as `log_id` pointers into `research_log.jsonl`; raw URL strings do not appear in `cycle_history`. Every citation in `research_log.jsonl` carries a `verified_at` timestamp before it may be the sole support for any `decisions[*]` entry. A canonical YAML is auditable only when every fact has a named, verifiable source; facts without named sources are blocking defects at cycle close.

---

### C. User-owned judgment gates

#### C1. Structural judgment gates across all seven stages

| Stage | Cycle | Section / key path | Current language | Judgment call exposed |
|---|---|---|---|---|
| formulate | C | C01–C04, `contract.question_type` | "If at least one ambiguity exists, dispatch AskUserQuestion" — conditional | Route type selection among six; alternative changes claim boundary |
| formulate | D | step4_additions `user_approval: required`; D02/D05/D07 | User approval at end; operationalization pre-committed | Proxy column, claim boundary type, ordered route candidates — all pre-decided |
| protocol | B | B01–B04, B04a, `data_usage.mode` | Conditional | Data-usage mode (8 options) fixes frozen-artifact logic + validation scope |
| protocol | B | B06, `frozen_artifacts.artifacts` | No question required | Cutoff values, seed, temporal windows, group-split criteria |
| protocol | C | C01–C07, `evidence_rules.*` | Conditional | Leakage verdict, forbidden-class enumeration, confounding centrality, validation logic |
| clean | B | B03, `data_contract.missing_vs_censored_rule` | "expect ambiguities" — suggestion | Missing-vs-censored classification changes analyzable population |
| clean | C | C02, `cleaning_decisions[*].policy` | Conditional | Cleaning policy per issue (keep/drop/impute/replace/split), rationale class, reversibility |
| clean | S | S01, `robustness.instability_thresholds` | Gate allows self-approval in auto mode | Threshold values per QCV; agent self-approves |
| examine | C | C03, `anomalies_and_contradictions.stability_classification` | Conditional | Perturbation scope and verdict (stable/conditional/fragile) |
| examine | C | C04, C05, `anomalies_and_contradictions.backtracking_decision` | Judgment-driven, null `evidence_key` | Backtrack vs. continue vs. reopen protocol |
| analyze | A | A02, A03, A05, A06, A07; step4 `user_approval: required` | Approval at end; pre-commitments uncontrolled | Method family, perturbation axes, challenger structure, assumption-failure policy |
| evaluate | B | B06, `stability_verdicts[*].verdict` | Conditional | Stability verdict class, divergence-classification |
| evaluate | C | C05, `predictability_verdicts[*].verdict` | Conditional | Marginal tier determines caveat severity |
| evaluate | D | D04, `validity_verdicts[*].overall` | Conditional | `fatal` verdict kills a claim |
| communicate | B | step4 `user_approval: required` | **Mandatory** | Audience and delivery format (already gate-mandatory) |
| communicate | E | E02, `visualizations[*].chosen_format` | No question required | Display format when takeaway stability differs across formats |

**Definition of a judgment gate.** A cycle contains a judgment gate iff all three hold:
1. No single mechanically correct answer exists — the choice is among defensible options, each producing a materially different downstream artifact (population, claim boundary, validation scope, stability verdict, claim survival).
2. The choice has lasting consequences — once committed, it propagates without a mandatory re-evaluation gate downstream.
3. The choice is not derivable from protocol rules plus arithmetic — computing a hash, applying a locked rule, or executing a frozen specification is not a gate.

**Mandatory vs. optional `AskUserQuestion`.** Mandatory gates must dispatch the question regardless of the agent's confidence; a user reply of `"agent decides"` is valid and unlocks forward movement, but the gate is recorded as run. Optional gates fire only on genuine residual ambiguity.

**Recorded form.**

```yaml
cycle_history:
  - cycle: S
    iteration: 1
    subagents:
      decisions:
        - what: "instability threshold for <metric_name> on <variable_class>"
          why: "no single standard threshold; sensitive to distribution shape"
          judgment_gate:
            gate_id: S01-thresholds-approved
            stage: clean
            cycle: S
            question_text: "Instability threshold for <metric>: agent proposes <v>, alternatives <a>, <b>. Reply with a value, a range, or 'agent decides'."
            options_presented:
              - option: "<v>"
                tradeoff: "flags <n> calls unstable under this scope"
              - option: "<a>"
                tradeoff: "stricter; forces more reopens"
              - option: "<b>"
                tradeoff: "looser; accepts wider variation"
            reply: "agent decides"
            reply_at: "<ISO timestamp>"
            agent_decision_if_delegated: "<v>"
            agent_rationale: "<one sentence>"
```

**Decision test for the evaluator.** Three binary checks per cycle with a mandatory gate: (1) at least one `cycle_history[*].subagents.decisions[*].judgment_gate.gate_id` matches the required gate ID; (2) `judgment_gate.reply` is a non-null string; (3) if `reply == "agent decides"`, both `agent_decision_if_delegated` and `agent_rationale` are non-null. Any failure is a blocking defect.

**Target class.** `core-principles.md` Universal Rules; cycle YAMLs for the structural gates listed above (clean B/C/S; protocol B/C; formulate C/D; analyze A; evaluate B/C/D; communicate E).

#### Candidate universal rule for `core-principles.md` (Block C)

> **Judgment gates.** A judgment gate is a choice that (a) has no mechanically correct answer derivable from protocol rules and the data alone, (b) selects among defensible options that produce materially different downstream artifacts, and (c) is not corrected by any downstream subagent scan. At every judgment gate the agent must dispatch `AskUserQuestion` before committing the choice. A user reply of `"agent decides"` is valid and permits the agent to proceed, but the gate must still be dispatched and the agent's chosen value plus a one-sentence rationale must land in the `judgment_gate` block of the relevant `cycle_history[*].subagents.decisions` entry. Mechanical choices — applying a locked rule, computing a hash, parsing a file — are not judgment gates. The distinction is structural, not difficulty-based: an easy-sounding threshold choice is still a gate if the spec does not derive it from first principles.

---

### D. Threshold derivation and dependency-graph exceedances

#### D1. Agent-chosen thresholds across stages

| Stage | Cycle | Section / key path | Agent-chosen today | Honest derivation source |
|---|---|---|---|---|
| clean | S | `robustness.instability_thresholds` / S01 | Numeric cutoff; self-approved | Bootstrap std, quantile spread, or external standard where applicable; user-approved |
| analyze | A | `contract.perturbation_plan`, `.accuracy_metric`; predictability screening threshold | Axes + threshold agent-authored | Ratio of baseline metric, declared external benchmark, or user-specified at contract lock |
| analyze | D | `comparison_table[*].threshold_used` / D05 | "Material difference" flag without required `derivation:` | Rule pre-declared in contract; ratio of primary metric, standard magnitude, or user minimum effect size |
| analyze | B | `assumptions.results[*].threshold_if_any` / B02 | Assumption thresholds (VIF, minimum effective n, balance p-value) ad hoc | Method-family standard, or user-declared in contract before B runs |
| evaluate | B | `stability_verdicts` / B07 | Stability classification relies on agent-typed magnitudes | Threshold locked in `contract.perturbation_plan`; agent may propose from benchmarks but may not apply unapproved values |
| evaluate | C | `predictability_verdicts` / C05 | Predictive screening threshold re-selected at evaluate time | Screening threshold locked in contract; evaluate applies, never re-selects |
| protocol | C | `evidence_rules.validation_logic` / C06; significance alpha | Alpha set in analyze and immediately tested | Declared in contract with `derivation: {mode, source, value}`; user-approved |
| protocol | B | `frozen_artifacts.artifacts[*].cutoffs` | Cutoff values agent-chosen | Derived from time-ordering, deployment gap, or domain event; user-approved before freeze |
| evaluate | B (predictive) | Bootstrap J for PPI | Agent-chosen J | Monte Carlo error budget or published minimum; user-approved |
| evaluate | B (inferential) | Effective-n threshold | Agent-authored | Ratio of total n or method-family minimum; declared in contract |
| clean | R | constraint tolerance per declared judgment-call constraint | Agent-chosen during verification | Domain spec or user-approved before R runs |

Structurally fixed (exempt): SHA-256 equality (evaluate A09); null-count = 0 on declared non-nullable columns; row count ≥ 1 at load. These are binary structural predicates.

**Abstracted fix (D1).** Every derivable pass/fail threshold carries a `derivation:` field. Allowed modes:
- `empirical` — computed from the data before the check runs (bootstrap std, IQR spread, percentile); computation runs in the same script call; derived value appears in the evidence packet so the evaluator can verify it.
- `declared_external_standard` — verbatim from a published or regulatory standard; source named specifically enough to look up.
- `upstream_ratio` — expressed as a ratio of an upstream canonical metric; the upstream metric is named.
- `user_specified` — user stated the value; requires `approved_by: user` and a timestamp or session reference.

Forbidden: `agent_chosen`.

Approval: `empirical` and `upstream_ratio` thresholds must be shown to the user (interactive) or logged with a self-approval reasoning trace (auto mode) before the cycle that checks against them advances.

YAML stub:

```yaml
instability_thresholds:
  <metric_name>:
    metric: <absolute_change_in_mean>
    threshold: <value>
    derivation:
      mode: empirical            # or declared_external_standard|upstream_ratio|user_specified
      source: <descriptor>
      computation: "<one-line description, empirical only>"
      value: <value>
      approved_by: user          # or auto_mode_reasoning
      approved_at: <ISO timestamp>
```

**Target class (D1).** `core-principles.md`; `references/clean/cycles/S.yaml`; `references/analyze/analyze.md` + `cycles/A.yaml`, `cycles/B.yaml`, `cycles/D.yaml`; `references/evaluate/cycles/B.yaml`, `cycles/C.yaml`; `references/protocol/cycles/B.yaml`, `cycles/C.yaml`; `references/constraint-spec.md` (tolerance derivation).

#### D2. Dependency-aware expected sets

When a cycle declares which metrics "should" move under a perturbation (clean S, analyze D comparison table, evaluate B stability adjudication), the expected set must be the transitive closure over a declared `metric_graph:`, not authored by hand.

```yaml
metric_graph:
  <raw_variable>:
    inputs: []
  <derived_metric>:
    inputs: [<raw_variable>, <other_input>]
    dependency_type: ratio          # arithmetic_complement | ratio | formula_parameter | shared_feature | indirect
  <complement>:
    inputs: [<derived_metric>]
    dependency_type: arithmetic_complement
```

Expected exceedance set for a perturbation to variable `X` = transitive closure of metrics whose `inputs` chain reaches `X`. The graph is authored once at contract lock, reviewed as part of user approval of the contract, and referenced read-only by all later perturbation cycles.

Placement: `contract.metric_graph` in `05_analysis.yaml`; `robustness.metric_graph` in `03_cleaning.yaml`. The evaluation subagent checks that the comparison table marks exactly the closure set as expected-to-move.

**Target class (D2).** `core-principles.md`; `references/clean/cycles/S.yaml`; `references/analyze/analyze.md` + relevant cycle YAMLs; `references/evaluate/cycles/B.yaml`.

#### Candidate universal rules for `core-principles.md` (Block D)

> **Threshold hygiene.** The agent must not select the numeric value it is being judged against. Every derivable numeric pass/fail threshold (stability tolerance, coverage, screening, significance, fairness gap, minimum cell count, perturbation magnitude, bootstrap iteration count, row-wise constraint tolerance) carries a `derivation:` field. Allowed modes: empirical-from-data (computed before the check), declared external standard, ratio of an upstream canonical metric, user-specified. Mode `agent_chosen` is forbidden. User approval (or a logged auto-mode reasoning trace) precedes any gate that checks against the derived value. Thresholds that are structurally binary (hash equality, null count equals zero, row count at least one) are exempt.
>
> **Dependency-aware expected sets.** When a cycle declares which metrics are expected to change under a perturbation, the expected set is computed as the transitive closure over a declared `metric_graph:`, not authored by hand. The graph names each metric's inputs and dependency type (arithmetic complement, ratio, formula parameter, shared feature). Hand-authored expected sets are prohibited because they systematically omit arithmetic complements and coupled rates.

---

### E. Shared script primitives

#### E1. Constraint verification

| Concern | File | Section | Current spec | Implied helper |
|---|---|---|---|---|
| `constraint_verification` | `constraint-spec.md` | Verification Contract, Verification Cells | Describes "set membership" as a check family without implementation guidance; nothing stops a project from writing `ser.isin(allowed)` that conflates NaN with non-membership | `verify_constraint(ser, constraint)` that excludes nulls before membership/range checks |
| `constraint_verification` | `constraint-spec.md` | Typed `details` payloads / Row-wise checks | `element_count` is non-null denominator; no code contract for separating nulls before `isin` | Same helper |
| `constraint_verification` | `clean/cycles/R.yaml` | R03 `constraint_check` | Delegates to project; no primitive specified | Helper called from `run_cycle_r` |

#### E2. Raw data loading

| Concern | File | Section | Current spec | Implied helper |
|---|---|---|---|---|
| `raw_data_loading` | `formulate/script_shape.py` | `read_csv` | Defined only for formulate; no dtype parameter; no memoization contract | `load_raw(path, schema)` memoized per path |
| `raw_data_loading` | `clean/clean.md` | Script shape | Names `load_state()`; no module-level raw loader | Same helper, shared across cycles |
| `raw_data_loading` | `examine/examine.md`, `analyze/analyze.md` | Script rules | "No generic helpers at module scope beyond those named in the Script shape above" — in tension with memoization need | Rule needs an exception for registered primitives |
| `raw_data_loading` | `core-principles.md` | Stage Script Rules | Same prohibition | Same exception |

#### E3. Dtype checking

| Concern | File | Section | Current spec | Implied helper |
|---|---|---|---|---|
| `dtype_checking` | `constraint-spec.md` | Schema constraint type + typed `details` | Literal string dtype comparison (`"object"` vs `"float64"`); fails silently on pandas 3.x StringDtype/ArrowDtype, nullable int, categorical | `check_dtype_meaning(series, expected_meaning)` |
| `dtype_checking` | `clean/cycles/A.yaml` | A02 `schema_and_type_issues` | Each Cycle A writes its own dtype comparison | Same helper |
| `dtype_checking` | `clean/clean.md` | Step 1, Step 5 | SHA-256 is treated as a shared primitive; dtype check is not | Extend primitive registry to include `check_dtype_meaning` |

#### Additional primitives currently reimplemented

| Concern | File | Current behavior | Implied helper |
|---|---|---|---|
| `sha256_computation` | `formulate/script_shape.py` `sha256_of` | Defined in formulate skeleton; other stages copy the 6-line function | Declare as required primitive |
| `null_policy_enforcement` | `constraint-spec.md` | "Null handling is delegated to a separate nullable constraint" without a code contract | Integrate into `verify_constraint` |
| `constraint_yaml_parsing` | `clean/cycles/R.yaml` R04 | Each Cycle R parses `clean_constraints.json` with an ad-hoc `json.loads` | `load_constraint_file(path) -> list[ConstraintEntry]` |
| `row_count_diff` | `clean/cycles/C.yaml` C04 | Each Cycle C reimplements `raw − exclusions == cleaned` | `reconcile_row_counts(raw, exclusions, cleaned)` |

**Helper registry (candidate contents for new `references/script-primitives.md`)**

No file with this name exists yet; `formulate/script_shape.py` defines four helpers for formulate only, which the new registry generalizes.

| Helper | Signature | Contract summary | Failure modes |
|---|---|---|---|
| `sha256_of` | `(path: Path) -> str` | Hex SHA-256, 1 MiB chunks | `FileNotFoundError` |
| `detect_encoding` | `(path: Path) -> str` | UTF-8 strict → UTF-16 BOM → cp1252 | `UnicodeDecodeError` if all three fail |
| `read_csv` | `(path: Path, **kwargs) -> pd.DataFrame` | Encoding-aware; thin wrapper, no cache | Propagates pandas errors |
| `load_raw` | `(path: Path, schema: Mapping[str, DTypeMeaning], encoding: str \| None = None) -> pd.DataFrame` | Memoized per path; first call reads via `read_csv` with dtypes from `schema`; subsequent calls return cache; every cycle in one process sees identical dtypes | `FileNotFoundError`, `KeyError` missing schema column, `UnicodeDecodeError` |
| `check_dtype_meaning` | `(series: pd.Series, expected_meaning: DTypeMeaning) -> bool` | Semantic dtype family check: numeric (incl. nullable Int64/Float32); string (object, StringDtype, ArrowDtype(pa.string\|pa.large_string)); categorical (CategoricalDtype only); date (datetime64 or ArrowDtype(pa.timestamp)); boolean (BooleanDtype or numpy bool_); identifier (string or integer) | `ValueError` on unrecognized meaning; pyarrow branches skipped if unavailable |
| `verify_constraint` | `(ser: pd.Series, constraint: Mapping[str, Any]) -> dict[str, Any]` | Excludes nulls from denominator; `bad = ser[ser.notna() & ~ser.isin(allowed)]` for set membership; analogous for range; returns the envelope dict from `constraint-spec.md` | Empty allowed list: all non-null values fail; entirely-null series: element_count=0, status PASS |
| `load_state` | `(yaml_path: Path) -> dict[str, Any]` | Read-only load of canonical stage YAML; empty dict when absent | Propagates `yaml.YAMLError` |

Cycles that must call each helper:

| Helper | Cycles |
|---|---|
| `sha256_of` | formulate A, clean A, analyze A |
| `load_raw` | clean A–S, examine A–E, analyze C–F |
| `check_dtype_meaning` | clean A (A02), clean R (R03) |
| `verify_constraint` | clean R (R03) |
| `load_state` | every cycle after A in every stage |

#### Candidate universal rule for `core-principles.md` (Block E)

> **Primitive registry.** Every stage script exposes a fixed set of project-side primitives defined in `references/script-primitives.md`: `sha256_of`, `detect_encoding`, `read_csv`, `load_raw`, `load_state`, `check_dtype_meaning`, `verify_constraint`. Cycle functions call these helpers; they do not reimplement I/O, dtype interpretation, or constraint verification. Bugs are fixed once in the helper. Any helper at module scope that is not in the primitive registry is a defect.

And the existing Stage Script Rule is revised from:

> "No generic helpers at module scope beyond those named in the Script shape above. Any helper introduced for a cycle lives inside that cycle's function and is removed once the cycle passes."

to:

> "No generic helpers at module scope beyond those declared in `references/script-primitives.md` and the Script shape above. Primitive-registry helpers are the explicit exception to the cycle-local rule because they must be called identically across cycles. Any other helper introduced for a cycle lives inside that cycle's function and is removed once the cycle passes."

---

### F. Cycle and checklist trimming

#### F1. Is the Cycle-E redundancy pattern unique to clean?

One sub-agent read every cycle in every stage against three criteria: (a) produces no new content beyond what a prior cycle already decided; (b) gates are purely conformance checks, not computations with downstream impact; (c) research questions ask for domain-fact lookups that could not change a gate outcome. Findings:

- **Formulate E** (Collection and Biases) — adds bias taxonomy, representativeness evidence, leakage field scan. New content. Not redundant.
- **Protocol A** (Handoff Audit from Formulate) — checks upstream field presence; produces the minimum-decisions charter. Has downstream impact. Not redundant.
- **Examine E** (Analysis Handoff Synthesis) — synthesizes prior cycles into new consolidated support matrix, route-strength update, analysis constraints. New content. Not redundant.
- **Analyze F** (Results Assembly + Reproducibility Re-run) — runs the full re-run + assembles the deviation register. New artifacts. Not redundant.
- **Evaluate A** (Intake Audit + Evaluation Plan) — verifies hashes, recomputes metrics, produces the evaluation plan. Downstream impact. Not redundant.
- **Evaluate F** (Evaluation Assembly + Handoff) — packages verdicts, writes communicate handoff. New content. Not redundant.
- **Communicate F** (Assembly + Terminal Fidelity Audit) — machine-checkable scans can block finalization. Not redundant.
- **Clean R** item R04 (constraint files present) — filesystem assertion only. Pathology criterion (c). Candidate for F2 removal (not full-cycle merge).

**Conclusion:** The F1 full-cycle redundancy is unique to **Clean E**. No other stage has a cycle that merges cleanly into an adjacent cycle's closeout.

**Migration map (clean E → clean C closeout)**

| Dropped cycle | Useful checks to migrate | Target cycle closeout |
|---|---|---|
| Clean E | E05 (fit-scope audit) — the only check with gate-failure potential from domain-fact lookup rather than execution conformance | Cycle C closeout: add a `fit_scope_decision` field per `preprocessing_decisions` entry. C already decides which transforms are permissible and records them |
| Clean E | E04 (deferred transforms list) — documents which transforms go to route/analyze | Cycle C closeout: fold into C01/C02 as a `deferred_to` field on any issue whose policy is to defer |
| Clean E | E01 scope conformance, E02 category representation, E03 numeric/date representation, E06 categorical expansion audit | Cycle C closeout sublist `preprocessing_scope`, or a D-series follow-up opened from C when preprocessing transforms are identified |

*(Block G narrowing: `preprocessing_decisions[]` must remain a distinct, fully populated list after the merge — same required fields as `cleaning_decisions[]` — and `preprocess_data` must still cover every recorded transform.)*

#### F2. Checklist items that fail the legitimacy test

Applied criteria: (a) duplicates another cycle's work, (b) records style without affecting any decision, (c) asserts a filesystem or config fact, (d) produces narrative prose derivable from structured fields.

| Stage | Cycle | Item | Current evidence_key | Reason to drop |
|---|---|---|---|---|
| clean | B | B06 | `restricted_artifact_audit` | (a) A01-visibility-confirmed + every evaluator defect scan already enforce this; B06 produces an audit record no one reads |
| clean | A | A08 | `structural_conventions_audit` | (b) naming-convention style; no downstream cycle conditions on it |
| clean | C | C03 | `action_code_trace` | (a) Cycle R evaluator already reads script + YAML and confirms match. *(Block G narrowing: may drop only if R01-signatures-stable is strengthened to verify every `cleaning_decisions` entry has a corresponding transform in `clean_data`.)* |
| clean | E | E04 | `deferred_transforms` | (a, b) documents style without gate consequence; migrates as a `deferred_to` field if Cycle E is dropped via F1 |
| clean | R | R04 | `constraint_files_present` | (c) constraint files are created in the cycle's own `setup_side_effects`; R03 already verifies content |
| clean | F | F02 | `derived_compatibility` | (a) F01 establishes the stage-core class; F02 restates it |
| clean | S | S06 | `robustness_summary` | (d) prose derivable from S01–S05 structured fields. *(Block G narrowing: the useful disposition-per-flagged-issue requirement moves onto S05, not dropped outright.)* |
| evaluate | A | A08 | `deviation_compliance_scan` | (a) same check the evaluator performs adversarially during Cycle B/C/D defect scans |

All other checklist items across all stages were reviewed and found to produce evidence that either (i) changes a downstream gate outcome, (ii) feeds a decision that cannot be reconstructed from other fields, or (iii) produces data-level evidence the evaluator uses adversarially.

**Abstracted fix (F2).** Every checklist item must satisfy at least one of:
1. Its `evidence_key` is required by a gate in this or a later cycle that cannot be answered without it.
2. Its answer changes which `writes_to` field is populated or the value that field carries, such that a downstream decision, prohibited action, or claim boundary would differ if the item were skipped.
3. It produces data-level script evidence the evaluator uses adversarially to falsify a gate (it can produce a FAIL that no other item would catch).

Items failing all three criteria are bookkeeping; move them to `provenance.notes` as pointers, or fold their gate into an existing gate's condition. Do not give them a checklist ID.

#### F3. Subagent dispatch per cycle

Decision tree:

```
Does the cycle involve a judgment call where domain knowledge
(outside the already-read project files) could change the outcome?
 ├─ YES ─ Does the research_questions list include a question whose
 │        answer would change a specific gate outcome or writes_to value?
 │          ├─ YES → dispatch [research, evaluator]
 │          └─ NO  → dispatch [evaluator]
 └─ NO ─ dispatch [evaluator]
```

Per-cycle sweep (abbreviated — full matrix in sub-agent report):

| Stage | Cycles dispatching `[evaluator]` only |
|---|---|
| formulate | none (A–E all judgment + domain) |
| protocol | A, D |
| clean | R; S partially (Layer execution is mechanical) |
| examine | E |
| analyze | C, D, F |
| evaluate | A, E, F |
| communicate | A, F |

All other cycles dispatch `[research, evaluator]`.

**Abstracted fix (F3).** Each cycle YAML carries a top-level `subagents:` field:

```yaml
subagents: [research, evaluator]    # or [evaluator]
```

Each stage-entry `.md` Step 3 reads the flag rather than hard-coding "Dispatch two subagents in parallel."

#### Candidate universal rule for `core-principles.md` (Block F)

> **Checklist legitimacy and subagent dispatch.** Every checklist item must satisfy at least one of: its evidence changes a gate outcome or `writes_to` value such that a downstream decision differs if the item is skipped; or it produces data-level script evidence the evaluation subagent uses adversarially to falsify a gate. Items that only assert filesystem facts, record style without affecting decisions, or produce narrative derivable from structured fields are bookkeeping — they belong in `provenance.notes` pointers, not in checklist IDs.
>
> Subagent dispatch is deterministic per cycle, not per stage. Each cycle YAML declares `subagents: [research, evaluator]` or `subagents: [evaluator]`. A cycle warrants the research subagent only when its `research_questions` include at least one question where a domain-fact lookup would change a specific gate outcome or judgment call. Cycles whose work is mechanical verification, execution recording, or results assembly run evaluator-only.

---

### G. Protected surface (no-change zone)

#### G1. Abstract names for the project-specific protection list

| Protected concept | Project name in v3 list | Abstract name | Stage that owns it | Skill file(s) |
|---|---|---|---|---|
| Register of judgment calls with rationale, source, reversibility, population shift, claim consequence | `cleaning_decisions` | **Decision register** | clean (Cycle C populates; Cycle R must cover every entry) | `clean/clean.md` schema; `clean/cycles/C.yaml` C02/C04/C05; `clean/cycles/R.yaml` |
| Per-term mapping from operationalization to columns + finding types (structural zero, censoring, correction, provenance gap) | `question_critical_variables` | **Claim-critical variable inventory** | clean (seeded in Cycle A from `contract.operationalization`; referenced by B/C/S and by examine, analyze) | `clean/clean.md` schema; `formulate/formulate.md` `contract.operationalization` |
| Row-count arithmetic closing raw → cleaned | `row_count_reconciliation` | **Population reconciliation table** | clean C04, gate C04-row-count-reconciled | `clean/clean.md`; `clean/cycles/C.yaml` C04 |
| Append-only log of every narrowing action | `narrowing_log` | **Claim narrowing log** | clean C05, gate C05-claim-impact-stated; cross-stage chain with formulate | `clean/clean.md` `claim_boundary_updates.narrowing_log`; `formulate/formulate.md` `claim_boundary.narrowing_log` |
| Per-cycle fit-for-question checkpoint | `dataset_fitness_reviews` | **Dataset fitness register** | clean C06, gate C06-fitness-checkpoint-run | `clean/clean.md`; `clean/cycles/C.yaml` C06 |
| Cycle functions producing decision-register evidence and reproducibility basis | `run_cycle_b`, `run_cycle_c` | **Claim-critical cycle functions** | clean B (integrity diagnostics) + clean C (cleaning resolution) | `clean/cycles/B.yaml`, `clean/cycles/C.yaml`, `clean/cycles/R.yaml` |
| Named rerunnable transformation helpers whose signatures cover every recorded transform | `clean_data`, `preprocess_data` | **Reproducibility helpers** | clean (Cycle R); referenced by examine/analyze/evaluate as upstream contract | `clean/clean.md` (Stage Outputs, Finalization); `clean/cycles/R.yaml` R01–R04; `constraint-spec.md` |
| Stage-close status block required by the next stage's precondition gate | README `## Clean [COMPLETE]` | **Stage-close status block** | clean Finalization + auto-mode Check 7 | `clean/clean.md` Finalization; `auto-mode.md` Check 7 |

#### G2. Abstracted protection rule

A refactor of any stage's cycle structure is permitted only when all three conditions hold:

1. **Decision register preserved.** Every judgment call passing through the stage remains expressible as a record containing: chosen policy, rationale class (measurement meaning, domain knowledge, data-generating process, protocol rule, transferability evidence), named alternatives, reversibility class, population effect, claim consequence. Collapsing entries, merging cycles, or removing checklist items is permitted only when the resulting cycle still writes every one of these fields for every judgment call the stage is responsible for.
2. **Reproducibility contract intact.** The stage still produces named, rerunnable transformation helpers whose signatures cover every recorded transform. Rerun output remains verifiable against stage-produced artifacts under a declared equality rule. Constraint files (declared-error, declared-warn, derived-info) are still emitted and verified. A refactor that removes a cycle with transforms covered by these helpers must assign those transforms to a surviving cycle that extends the same helpers before approval.
3. **Claim-support chain not weakened.** The claim narrowing log remains append-only and records every action with a claim consequence. The population reconciliation table still closes the raw → cleaned arithmetic. The claim-critical variable inventory remains accessible to downstream stages through the canonical YAML. The stage-close status block is still generated and verified against actual artifacts before the stage is marked complete.

A refactor preserving these three conditions by contract — regardless of field-name, cycle-letter, or function-name changes — is safe. A refactor dropping a required field, removing a cycle without absorbing its evidence obligations, or allowing a judgment call to proceed without its full record is a defect in the spec itself and must be rejected regardless of line-count savings.

#### G3. Target class

- `core-principles.md` — new "Protected Surface" subsection under Universal Rules
- `clean/clean.md` — schema preamble + Finalization section list what must survive any schema revision
- `constraint-spec.md` — Generation Process section depends on stable `clean_data`/`preprocess_data` signatures
- `references/routes/<route>/clean.md` — must cite the protected surface as non-narrowable (the existing "may narrow; may not override reproducibility rules or widen the claim boundary" rule already implies this but should name the protected surface explicitly)

#### G4. Sanity check of blocks A–F against the protected surface

- **A1, A2, A3, A6, A7**: no collision. None of these touch the decision register, reconciliation tables, or reproducibility helpers.
- **A4**: potential collision — the spec's `cleaning_decisions[]` already uses a composite shape; the collapse is a convergence toward the schema, not away from it. **Narrowed:** every required field of `cleaning_decisions[]` must remain present per collapsed record.
- **A5**: partial collision — collapse is valid only when reversibility, population_shift, and claim_consequence are genuinely identical across all listed columns. **Narrowed:** the gate C02-policies-chosen must still pass after the collapse.
- **B1, B2**: no collision.
- **C1**: no collision — increases user involvement at the exact cycles that write the decision register (C) and the stability output (S). Consistent with the protection principle.
- **D1, D2**: no collision — `robustness.instability_thresholds` and `metric_graph` are not protected concepts.
- **E1, E3**: no collision — strengthen the constraint verification and dtype interpretation layers that the reproducibility helpers depend on.
- **E2**: scope note — `load_raw()` is a new module-scope helper. The existing "No generic helpers at module scope" rule would prohibit it. **Narrowed:** `load_raw()` must be declared as an extension of the named script shape via the Block E primitive registry (which updates `core-principles.md`'s helper rule).
- **F1**: collision risk — Cycle E currently writes `preprocessing_decisions[]`, which is a peer of the decision register. **Narrowed:** after the merge, Cycle C's closeout must still write every required field of `preprocessing_decisions[]`; `preprocess_data` must still cover every transform from the merged section; the mandatory-cycle list in `clean.md` must be updated to show preprocessing decisions are made inside C's final step.
- **F2**: mixed. C03 (action code trace) is a near-collision because it writes `cleaning_decisions[*].code_reference`. **Narrowed:** C03 may be dropped only if Cycle R gate R01-signatures-stable is strengthened to verify that every `cleaning_decisions` entry has a corresponding transform in `clean_data`. R04 (constraint files present) is a safe filesystem assertion; S06's useful disposition requirement migrates to S05; all other targeted items are free to drop.
- **F3**: no collision — dispatch rule is about subagent economy, not decision register.

#### Candidate universal rule for `core-principles.md` (Block G)

> **Protected surface.** Every stage produces at least one register of judgment calls (decisions, alternatives, rationale class, population effect, claim consequence for every material choice), at least one reconciliation table or integrity chain (arithmetic or logical account closing the population or claim space), and, where the stage contributes executable transforms, at least one named rerunnable helper with a documented signature. These three categories — the decision register, the reconciliation table or chain, and the claim-critical helper set — are protected by contract, not by naming. A refactor that renames, restructures, or merges cycles is permitted when every entry in the decision register remains expressible with its full required fields, the reconciliation arithmetic still closes, the helper signatures still cover every recorded transform, and the claim-support chain from formulate through communicate is not weakened. A refactor that drops a required field, omits a judgment call from the register, breaks the reconciliation arithmetic, or removes a helper without transferring its obligations is a defect in the spec itself and must be rejected regardless of line-count savings.

---

## 3. Implementation map (aggregated)

One row per spec file to touch, with the fix IDs that apply and the kind of change.

| File | Fix IDs | Kind of change | Notes |
|---|---|---|---|
| `references/core-principles.md` | A1–A7, B1, B2, C1, D1, D2, E1–E3, F2, F3, G | Add 6 universal rules (one per block A/B/C/D/E/F/G) + revise Stage Script Rules helper exception | Single canonical home for all cross-block rules; added as new subsections under Universal Rules |
| `references/constraint-spec.md` | D1, E1, E3, G | Add `derivation:` field to judgment-call tolerance; specify `verify_constraint` contract (null-separation before set/range checks); extend dtype check to semantic families; cite protected surface as non-narrowable | Generation Process + Verification Contract sections |
| `references/script-primitives.md` (NEW) | E1, E2, E3 | Create file with the seven-helper registry + signatures + contracts + per-cycle call map | Currently no file of this name; closest precedent is `formulate/script_shape.py` |
| `references/auto-mode.md` | C1, D1, F3, G | Note auto-mode reasoning log for delegated judgment gates and threshold approvals; Check 7 protection reference | |
| `references/formulate/formulate.md` | A6, A7, B1, B2, F3 | PCS digest replaces verbatim paste; script_evidence examples + lint; evidence-key citation rule; research_log pointer; Step 3 subagents flag | |
| `references/formulate/cycles/A.yaml` | B2, F3 | `subagents: [research, evaluator]`; research_log citation schema | |
| `references/formulate/cycles/B.yaml` | C1, F3 | `subagents: [research, evaluator]`; may gain a judgment-gate entry | |
| `references/formulate/cycles/C.yaml` | C1, F3 | Mandatory judgment gate for question-type classification; `subagents: [research, evaluator]` |  |
| `references/formulate/cycles/D.yaml` | C1, F3 | Mandatory judgment gate fires before (not after) operationalization commitment | |
| `references/formulate/cycles/E.yaml` | F3 | `subagents: [research, evaluator]` | |
| `references/formulate/cycles/F_template.yaml` | B1, F3 | Add evidence-key citation to template; subagents flag | |
| `references/formulate/script_shape.py` | E2, E3 | Point to `references/script-primitives.md`; `read_csv` documented as wrapper around the shared `load_raw` | |
| `references/protocol/protocol.md` | A6, A7, B1, B2, F3 | PCS digest; script_evidence; evidence-key citation; research_log; subagents flag | |
| `references/protocol/cycles/A.yaml` | F3 | `subagents: [evaluator]` (mechanical field extraction) | |
| `references/protocol/cycles/B.yaml` | C1, D1, F3 | Mandatory judgment gate for data-usage mode + cutoffs/seed; `derivation:` on cutoff values; `subagents: [research, evaluator]` | |
| `references/protocol/cycles/C.yaml` | C1, D1, F3 | Mandatory judgment gate for leakage verdict + validation logic; alpha declared with derivation; `subagents: [research, evaluator]` | |
| `references/protocol/cycles/D.yaml` | F3 | `subagents: [evaluator]` (prohibitions/triggers derived mechanically) | |
| `references/protocol/cycles/F_template.yaml` | B1, F3 | Citation rule + subagents flag | |
| `references/clean/clean.md` | A1, A2, A3, A5, A6, A7, B1, B2, E2, F1, F2, G | Replace `upstream_snapshot` with `upstream_pointer`; drop `visibility:` block (keep optional `visibility_hash:`); `pcs_review.digest` replaces `pcs_review.verbatim`; schema comment for collapsing singleton entries; script_evidence examples; evidence-key citation rule; research_log pointer; Script shape names the registered primitives; delete Cycle E section + migrate preprocessing to C closeout; delete A08/B06/C03/F02/S06 guidance; schema preamble names the protected surface | |
| `references/clean/cycles/A.yaml` | A1, A2, A3, E3, F2, F3 | Drop instruction to copy `upstream_snapshot`; drop `visibility_snapshot` evidence key; A02 calls `check_dtype_meaning`; delete A08 `structural_conventions_audit`; `subagents: [research, evaluator]` | |
| `references/clean/cycles/B.yaml` | C1, F2, F3 | Mandatory judgment gate on missing-vs-censored classification; delete B06 `restricted_artifact_audit`; `subagents: [research, evaluator]` | |
| `references/clean/cycles/C.yaml` | A4, C1, F1, F2, F3, G | Collapse C01–C04 into one composite record per issue; mandatory judgment gate on irreversible exclusions; absorb E04/E05 as `deferred_to` + `fit_scope_decision` fields on `preprocessing_decisions[]`; delete C03; `subagents: [research, evaluator]` | |
| `references/clean/cycles/D_template.yaml` | B1, F3 | Citation rule; subagents flag | |
| `references/clean/cycles/E.yaml` | F1 | **DELETE** after migration of useful checks to Cycle C closeout (Block G narrowing: verify `preprocessing_decisions[]` schema is preserved intact) | |
| `references/clean/cycles/F.yaml` | F2, F3 | Delete F02 `derived_compatibility`; `subagents: [research, evaluator]` | |
| `references/clean/cycles/G_template.yaml` | B1, F3 | Citation rule; subagents flag | |
| `references/clean/cycles/R.yaml` | D1, E1, E3, F2, F3, G | Tolerance carries `derivation:`; R03 calls `verify_constraint`; delete R04; strengthen R01 to verify every `cleaning_decisions` entry maps to a transform in `clean_data` (absorbs C03's role); `subagents: [evaluator]` | |
| `references/clean/cycles/S.yaml` | C1, D1, D2, F2, F3 | Mandatory judgment gate on threshold approval; `derivation:` field on `instability_thresholds`; `metric_graph:` authored at contract lock; delete S06; move disposition requirement onto S05; `subagents: [research, evaluator]` (partial — Layer execution is mechanical, research covers S01/S02 only) | |
| `references/examine/examine.md` | A1, A3, A6, A7, B1, B2, E2, F3 | Replace `upstream:` with pointer; drop `visibility:`; PCS digest; script_evidence examples; citation rule; research_log pointer; Script shape names shared primitives; subagents flag | |
| `references/examine/cycles/A.yaml` | A1, A3, E3, F3 | Drop `upstream` + `visibility_map` copy instructions; subagents flag | |
| `references/examine/cycles/B.yaml` | B1, F3 | Citation rule on summary fields; `subagents: [research, evaluator]` | |
| `references/examine/cycles/C.yaml` | B1, C1 (examine C variant), F3 | Citation rule; judgment gate on backtracking decision; `subagents: [research, evaluator]` | |
| `references/examine/cycles/D_template.yaml` | B1, F3 | | |
| `references/examine/cycles/E.yaml` | F3 | `subagents: [evaluator]` (synthesis only) | |
| `references/analyze/analyze.md` | A2, A3, A6, A7, B1, B2, D1, D2, E2, F3 | `provenance.upstream_artifacts` becomes a pointer; drop `provenance.visibility_set`; PCS digest; script_evidence; citation rule; research_log; `contract.perturbation_plan` + `contract.metric_graph` carry `derivation:`; Script shape names shared primitives | |
| `references/analyze/cycles/A.yaml` | A2, C1, D1, D2, F3 | Drop hash copy instruction; mandatory judgment gates for method family, perturbation axes, assumption-failure policy dispatched *before* user_approval; `derivation:` on perturbation-plan thresholds; metric_graph authored here; `subagents: [research, evaluator]` | |
| `references/analyze/cycles/B.yaml` | D1, F3 | Assumption-check thresholds carry `derivation:`; `subagents: [research, evaluator]` | |
| `references/analyze/cycles/C.yaml` | F3 | `subagents: [evaluator]` (execution recording) | |
| `references/analyze/cycles/D.yaml` | D1, D2, F3 | Comparison-table thresholds tied to contract `derivation:`; expected exceedance from `metric_graph`; `subagents: [evaluator]` | |
| `references/analyze/cycles/E_template.yaml` | B1, F3 | | |
| `references/analyze/cycles/F.yaml` | F3 | `subagents: [evaluator]` (results assembly) | |
| `references/evaluate/evaluate.md` | A2, A6, A7, B1, B2, D1, F3 | `reproducibility.frozen_artifact_hashes` becomes a verdict only; PCS digest; script_evidence; citation rule; research_log; thresholds referenced from contract, never re-selected | |
| `references/evaluate/cycles/A.yaml` | A2, F2, F3 | A09 emits `{expected, observed, match}` verdict only; delete A08 `deviation_compliance_scan`; `subagents: [evaluator]` | |
| `references/evaluate/cycles/B.yaml` | C1, D1, D2, F3 | Mandatory judgment gate on divergence-classification; threshold derivation from contract; exceedance from metric_graph; `subagents: [research, evaluator]` | |
| `references/evaluate/cycles/C.yaml` | C1, D1, F3 | Mandatory judgment gate on marginal/inadequate verdict; screening threshold from contract (never re-selected); `subagents: [research, evaluator]` | |
| `references/evaluate/cycles/D.yaml` | C1, F3 | Mandatory judgment gate on fatal verdict; `subagents: [research, evaluator]` | |
| `references/evaluate/cycles/E.yaml` | F3 | `subagents: [evaluator]` (claim-survival derivation) | |
| `references/evaluate/cycles/F.yaml` | F3 | `subagents: [evaluator]` (assembly) | |
| `references/evaluate/cycles/G_template.yaml` | B1, F3 | | |
| `references/communicate/communicate.md` | A1, A6, A7, B1, B2, F3 | Replace `upstream_snapshot` with pointer; PCS digest; script_evidence; citation rule; research_log | |
| `references/communicate/cycles/A.yaml` | A1, F3 | Drop upstream copy; `subagents: [evaluator]` | |
| `references/communicate/cycles/B.yaml` | F3 | `subagents: [research, evaluator]` (audience conventions) | |
| `references/communicate/cycles/C.yaml` | F3 | `subagents: [research, evaluator]` | |
| `references/communicate/cycles/D.yaml` | F3 | `subagents: [research, evaluator]` | |
| `references/communicate/cycles/E.yaml` | C1, F3 | Mandatory judgment gate on visualization format when takeaway stability differs; `subagents: [research, evaluator]` | |
| `references/communicate/cycles/F.yaml` | F3 | `subagents: [evaluator]` (terminal fidelity) | |
| `references/routes/<route>/*.md` (6 routes × 5 stages) | G | Cite protected surface as non-narrowable in every route's `clean.md`, `analyze.md`, `evaluate.md` | Existing "may narrow; may not override reproducibility rules" becomes explicit about the protected surface |

**New artifact.** `<docs_dir>/research_log.jsonl` — project-side, append-only, created at first research-subagent dispatch. Schema defined in Block B2. Referenced by `core-principles.md` Canonical Artifact Model.

---

## 4. Proposed additions to `core-principles.md`

All rules below are expressible without naming a dataset, column, stage-specific symbol, or domain. Insert as new subsections under Universal Rules (or wherever the existing core-principles structure places cross-cutting rules).

### 4.1 Single-source-of-truth discipline (Block A)

Each fact has exactly one canonical home. Facts from `<upstream_stage>` must be read at cycle-start and held in memory; they must not be copied into a new top-level block of the current stage's canonical YAML. The only permitted downstream record of an upstream fact is a compact verification verdict. A file hash recorded in `provenance.files` of the ingesting stage is never re-recorded as a value in any downstream YAML; only the `match: bool` result travels downstream. The visibility set for each stage is derived from `02_protocol.yaml` at cycle-start and stored as a compact artifact list, not a re-documentation of protocol rules. When multiple items share the same decision, rationale, and fit scope, collapse them into one record with a `columns:` or `items:` list; per-item duplication is prohibited. Subagent output is digested into `{lens, verdict, key_finding, recommendation}` per lens; full reply text never enters the canonical YAML. `cycle_history[*].script_evidence` entries are one-line bullets; multi-clause prose is a defect the evaluation subagent must flag.

### 4.2 Machine-readable artifact integrity (Block B)

Canonical stage YAMLs hold only structured values or typed pointers to named evidence keys; narrative prose with embedded numeric or categorical claims is forbidden. Every integer, decimal, percentage, category set, or date literal in a YAML field must trace to a named `evidence_key` in the owning cycle's script output, cited as `(source: <cycle_id>.<evidence_key>)`. Research citations are stored as `log_id` pointers into `research_log.jsonl`; raw URL strings do not appear in `cycle_history`. Every citation in `research_log.jsonl` carries a `verified_at` timestamp before it may be the sole support for any `decisions[*]` entry. Facts without named, verifiable sources are blocking defects at cycle close.

### 4.3 Judgment gates (Block C)

A judgment gate is a choice that (a) has no mechanically correct answer derivable from protocol rules and the data alone, (b) selects among defensible options producing materially different downstream artifacts, and (c) is not corrected by any downstream subagent scan. At every judgment gate the agent must dispatch `AskUserQuestion` before committing the choice. A reply of `"agent decides"` is valid and permits the agent to proceed, but the gate must still be dispatched and the agent's chosen value plus a one-sentence rationale must land in the `judgment_gate` block of the relevant `cycle_history[*].subagents.decisions` entry. Mechanical choices — applying a locked rule, computing a hash, parsing a file — are not judgment gates. The distinction is structural, not difficulty-based.

### 4.4 Threshold hygiene (Block D)

The agent must not select the numeric value it is being judged against. Every derivable numeric pass/fail threshold carries a `derivation:` field. Allowed modes: `empirical` (computed from data before the check, with the computation echoed in the evidence packet), `declared_external_standard` (verbatim from a named source), `upstream_ratio` (ratio of a named upstream canonical metric), `user_specified`. Mode `agent_chosen` is forbidden. User approval (or a logged auto-mode reasoning trace) precedes any gate that checks against the derived value. Thresholds that are structurally binary (hash equality, null count equals zero, row count at least one) are exempt.

### 4.5 Dependency-aware expected sets (Block D)

When a cycle declares which metrics are expected to change under a perturbation, the expected set is the transitive closure over a declared `metric_graph:`, not authored by hand. The graph names each metric's inputs and dependency type (arithmetic complement, ratio, formula parameter, shared feature). Hand-authored expected sets are prohibited because they systematically omit arithmetic complements and coupled rates.

### 4.6 Primitive registry (Block E)

Every stage script exposes a fixed set of project-side primitives defined in `references/script-primitives.md`: `sha256_of`, `detect_encoding`, `read_csv`, `load_raw`, `load_state`, `check_dtype_meaning`, `verify_constraint`. Cycle functions call these helpers; they do not reimplement I/O, dtype interpretation, or constraint verification. Bugs are fixed once in the helper. Any helper at module scope that is not in the primitive registry is a defect. The existing Stage Script Rule is revised so primitive-registry helpers are the explicit exception to the cycle-local rule.

### 4.7 Checklist legitimacy and subagent dispatch (Block F)

Every checklist item must satisfy at least one of: its evidence changes a gate outcome or `writes_to` value such that a downstream decision differs if the item is skipped; or it produces data-level script evidence the evaluation subagent uses adversarially to falsify a gate. Items that only assert filesystem facts, record style without affecting decisions, or produce narrative derivable from structured fields are bookkeeping — they belong in `provenance.notes` pointers, not in checklist IDs. Subagent dispatch is deterministic per cycle, not per stage: each cycle YAML declares `subagents: [research, evaluator]` or `subagents: [evaluator]`. A cycle warrants the research subagent only when its `research_questions` include at least one question whose answer would change a specific gate outcome or judgment call.

### 4.8 Protected surface (Block G)

Every stage produces at least one register of judgment calls (decisions, alternatives, rationale class, population effect, claim consequence for every material choice), at least one reconciliation table or integrity chain (arithmetic or logical account closing the population or claim space), and, where the stage contributes executable transforms, at least one named rerunnable helper with a documented signature. These three categories — the decision register, the reconciliation table or chain, and the claim-critical helper set — are protected by contract, not by naming. A refactor that renames, restructures, or merges cycles is permitted when every entry in the decision register remains expressible with its full required fields, the reconciliation arithmetic still closes, the helper signatures still cover every recorded transform, and the claim-support chain from formulate through communicate is not weakened. A refactor that drops a required field, omits a judgment call from the register, breaks the reconciliation arithmetic, or removes a helper without transferring its obligations is a defect in the spec itself and must be rejected regardless of line-count savings.
