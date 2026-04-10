---
name: protocol-descriptive
description: Stage-specific route file for the Skeptic protocol stage for descriptive questions. Narrows the universal protocol stage-core.
---

# Protocol Route File: Descriptive

## What This Stage Protects
- The reporting frame, denominator logic, extract window, measurement scope, and descriptive claim boundary.
- Descriptive-only language. Do not let later stages smuggle in explanation, prediction, inference, or causal effect.

## What This Stage Prohibits
- Predictive-style split logic unless it is required to freeze the reporting frame itself.
- Protocol rules that let later stages change the reporting frame, denominator basis, or measurement scope without reopening `protocol`.
- Validation logic framed around unseen-data performance instead of denominator integrity, coverage, refreshed extracts, or external corroboration already inside the allowed claim.

## What This Stage Defers
- Exact summary statistics, subgroup sets, weighting or standardization formulas, aggregation conventions, visualization grammar, and exact sensitivity procedures.
- Any choice that belongs to `analyze`.

## What Triggers Backtracking In This Stage
- The reporting frame cannot be audited.
- Core denominators are unstable or contradictory.
- Refreshed extracts or external corroboration materially disagree and no protocol-approved explanation holds.
- The intended descriptive claim starts needing explanatory, inferential, predictive, or causal logic.
