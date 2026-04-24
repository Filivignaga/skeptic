# Constraint Specification Reference

## Purpose

This document is the technical contract for constraint generation and verification in `/skeptic:clean` post-cycle Phase 1 (Reproducibility).

- **Who reads it:** Claude when generating constraint files and verification cells
- **When to read it:** only during post-cycle Phase 1, after `clean_data()` and `preprocess_data()` have been extracted and snapshot validation is running
- **What it covers:** constraint file structure, constraint semantics, and verification output format

This file is not a workflow guide. Keep procedural stage logic in `clean.md`.

## Spec Format

## Two-Layer Design

Every constraint belongs to exactly one layer:
- **Declared constraints** — rules derived from the data dictionary, domain knowledge, or explicit cycle decisions. These are normative: a failure means the data or the function is wrong. Source: `domain` (from data dictionary or research), `business_rule` (from cycle decisions). Severity: `error` (must pass) or `warn` (flag but don't block).
- **Derived constraints** — empirical summaries observed from the training set output (e.g., actual min/max, observed cardinality). These are informational: included for monitoring and drift detection, never used as hard validation gates unless explicitly promoted to declared. Source: `empirical`. Severity: always `info`.

Do not blend the two layers. A constraint generated from `clean_data()` output is derived until a human confirms it as normative. The separation prevents a bad cleaner from blessing its own mistakes.

## Constraint Types

- Schema: column names and dtypes (declared, from data dictionary)
- Nullable/non-nullable per column (declared, from data dictionary or cycle decisions)
- Numeric ranges per variable (declared when domain dictionary specifies bounds; derived when using observed min/max)
- Allowed values for categorical columns (declared when the data dictionary enumerates valid levels; derived when inferred from training set)
- Primary key / uniqueness rules (declared, from data dictionary)
- Cross-variable consistency rules — only when expressible as a simple boolean predicate (e.g., `start_date < end_date`). Keep these as Python functions in `cleaning_functions.py`, reference them by name in the spec. Do not build a rule DSL.

## Split Scope

Each constraint specifies `applies_to`:
- `universal` — schema, domain ranges, uniqueness, business rules. These must hold for all data visible under the protocol's data-usage mode.
- `estimation_subset_only` — empirical ranges or thresholds derived from the estimation-visible subset that may not transfer to held-back or external data. Downstream stages verify `universal` constraints against all protocol-visible data but skip `estimation_subset_only` constraints for held-back or external partitions.

## Protocol-Mode Mapping

The `applies_to` field adapts to the protocol's chosen data-usage mode:

| Protocol mode | `universal` means | `estimation_subset_only` means |
|---------------|-------------------|-------------------------------|
| `full_data` | all data | not applicable (no subset distinction) |
| `frozen_holdout_split` | train + validation + test | train only |
| `temporal_split` | all temporal partitions | estimation window only |
| `group_split` | all groups | estimation groups only |
| `rolling_validation` | all windows | current estimation window only |
| `external_validation` | internal + external | internal only |
| `resampling_only` | all data | not applicable (no subset distinction) |
| `cross_fitting_authorized` | all folds | not applicable (folds rotate) |

If the protocol mode has no subset distinction (e.g., `full_data`, `resampling_only`), omit `estimation_subset_only` constraints. They describe what was observed and have no separate validation target.

## Tolerance (Row-Wise Checks Only)

Row-wise constraint families (range, set membership, regex, nullable) support an optional `tolerance` field (float 0.0-1.0, default 1.0) specifying the minimum fraction of applicable rows that must comply. `tolerance: 0.95` means up to 5% of rows may violate without failing the check. This field does NOT apply to dataset-level constraints (schema, uniqueness, cross-variable consistency) — those are always binary pass/fail. Omit `tolerance` from constraint types where it is inapplicable; do not set it to 1.0 as a no-op on binary checks.

`tolerance` and `severity` serve distinct roles: `tolerance` defines what compliance rate is acceptable (the rule itself), `severity` defines what happens when the rule fails (block execution vs. warn vs. inform). A constraint can have `tolerance: 0.95` and `severity: "error"` — meaning 95% compliance is the rule, and violating that rule blocks.

For declared domain constraints: default `tolerance: 1.0` (hard gate) unless the domain question or cycle decisions justify a softer threshold. For declared judgment-call constraints where some violation is expected: set explicitly with rationale in the decision log. For derived constraints: `tolerance` is always omitted (they describe what was observed, not what should be).

**Edge case rules for tolerance:**
- Denominator is always non-null rows for the checked column(s). Null handling is delegated to a separate nullable constraint. Implementation calls `verify_constraint(ser, constraint)` from the primitive registry (`references/script-primitives.md`); null-separation before membership/range checks is enforced by the helper — do not write inline `isin` or range comparisons that conflate null with non-membership.
- On small datasets (<30 applicable rows), `tolerance` rounds to the nearest whole row using `floor(element_count * (1 - tolerance))` as the max allowed failures. Document this in the verification cell output.

**Tolerance derivation requirement:** Any numeric tolerance used in a Verification Cell must carry a `derivation:` field under the constraint entry. Allowed modes: `empirical` (computed from the data before the check), `declared_external_standard`, `upstream_ratio`, `user_specified`. Mode `agent_chosen` is forbidden. Structural-binary predicates (hash equality, null-count = 0 on declared non-nullable columns, row count >= 1 at load) are exempt and do not carry derivation blocks.

**Semantic dtype checking:** Schema constraints that check column dtypes must use semantic dtype families, not literal dtype strings. Implementation calls `check_dtype_meaning(series, expected_meaning)` from the primitive registry. Recognized families: `numeric`, `string`, `categorical`, `date`, `boolean`, `identifier`. Literal string comparisons (`"object"` vs `"float64"`) fail silently on pandas 3.x StringDtype, ArrowDtype, nullable int, and categorical columns and are prohibited.

**Protected surface:** The `clean_data` / `preprocess_data` signatures and the declared-error/warn/info constraint families are part of the protected surface; refactors must preserve them.

## File Format

Save as `notebooks/clean_constraints.json` (from `clean_data()` contract) and `notebooks/preprocess_constraints.json` (from `preprocess_data()` contract). JSON, human-readable and hand-editable. Structure adapts to the project, but each constraint entry must include: `column` (or `columns` for cross-variable), `check` type, `params`, `source`, `severity`, and `applies_to`. Row-wise checks additionally include `tolerance`.

Example entries:
```json
{
    "column": "revenue_usd",
    "check": "range",
    "params": {"min": 0, "max": 1000000},
    "source": "domain",
    "severity": "error",
    "applies_to": "universal",
    "tolerance": 1.0
}
```
```json
{
    "column": "record_id",
    "check": "uniqueness",
    "params": {},
    "source": "domain",
    "severity": "error",
    "applies_to": "universal"
}
```
Note: the uniqueness constraint has no `tolerance` field — it is a dataset-level invariant, always binary.

## Generation Process

1. Claude reads the decision log (`03_cleaning.md`), data dictionary (`01_formulation.md`), and the sentinel values section to assemble declared constraints.
2. Claude reads the validated `clean_data()` / `preprocess_data()` output to derive empirical constraints.
3. Claude writes both layers into the constraint file, clearly separated.
4. Present the constraint spec to the user for review. The user may promote derived constraints to declared, adjust thresholds, adjust `tolerance` values, or remove entries.

## Verification Contract

## Verification Cells

Write notebook cells that load the constraint file and verify `clean_data(visible_df)` output against all declared constraints programmatically. Each check produces a structured result dict with a common envelope and a typed `details` key whose shape varies by check family:

Common envelope (always present):
```python
{
    "check": "range_check",        # which constraint
    "layer": "declared",           # declared or derived
    "severity": "error",           # error / warn / info
    "status": "FAIL",              # PASS or FAIL
    "element_count": 4950,         # non-null rows evaluated (denominator)
    "failure_count": 12,           # rows/items that failed
    "details": { ... }             # typed payload, varies by check family
}
```

Typed `details` payloads by check family:

*Row-wise checks* (range, set membership, regex, nullable):
```python
"details": {
    "column": "revenue_usd",
    "tolerance": 0.95,
    "unexpected_percent": 0.24,
    "max_allowed_failures": 247,
    "row_failures": [
        {"row": 42, "value": -5.2},
        {"row": 1087, "value": 1500000}
    ],
    "truncated": false,
    "message": "Below domain minimum 0"
}
```
Status is PASS if `failure_count <= floor(element_count * (1 - tolerance))`.

*Schema checks* (column existence, dtype):
```python
"details": {
    "expected": {"column": "revenue_usd", "dtype": "float64"},
    "actual": {"column": "revenue_usd", "dtype": "object"},
    "message": "dtype mismatch"
}
```

*Uniqueness checks*:
```python
"details": {
    "column": "record_id",
    "duplicate_groups": [
        {"key": "REC-00042", "count": 3, "row_indices": [42, 1087, 2201]}
    ],
    "truncated": false
}
```

*Cross-variable checks*:
```python
"details": {
    "columns": ["start_date", "end_date"],
    "rule": "start_date < end_date",
    "row_failures": [
        {"row": 42, "start_date": "2024-03-15", "end_date": "2024-01-10"}
    ],
    "truncated": false
}
```

For large failure sets (>20 entries in any list), truncate to the first 20 and set `"truncated": true`. Include total count in the summary table.

Collect all results into a list and display a summary table: check name, layer, severity, status, element_count, failure_count, and (for row-wise checks) tolerance and unexpected_%. Sort declared-error failures to the top.

Declared constraints with severity `error` must all pass. Derived constraints are displayed for informational review but do not block. If any declared-error constraint fails: fix functions, re-run.
