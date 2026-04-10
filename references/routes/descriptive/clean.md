---
name: clean-descriptive
description: Stage-specific route file for the Skeptic clean stage for descriptive questions. Narrows the universal clean stage-core.
---

# Clean Route File: Descriptive

## What This Stage Protects
- Reporting-frame fidelity, audited denominators, subgroup boundaries, missingness states, and original measurement meaning.
- The approved reporting grain and time window.
- Valid repeated units, episodes, or measurements until their denominator effect is resolved.

## What This Stage Prohibits
- Dropping rows with missing question-critical fields by default unless the approved reporting frame already excludes them.
- Deduplicating when valid repeats remain plausible and denominator effects are unresolved.
- Pooling rare categories, thresholding continuous fields, winsorizing, smoothing, or suppressing outliers just to make summaries cleaner.
- Imputing primary descriptive values for convenience.
- Constructing rates, percentages, standardized summaries, or weights unless already approved in `formulate` or explicitly authorized by `protocol`.
- Collapsing missing, unknown, not applicable, and not collected into one substantive state.

## What This Stage Defers
- Weighting, standardization, time aggregation, subgroup granularity, and display-oriented smoothing not already fixed upstream.
- Any descriptive quantity that depends on contested denominators, aggregation, or standardization choices.

## What Triggers Backtracking In This Stage
- The denominator or reporting frame cannot be identified unambiguously from visible artifacts.
- Duplicate resolution would materially change counts and valid repeat versus defect remains unresolved.
- Missingness handling materially changes key descriptive summaries and no upstream rule licenses the choice.
- A needed descriptive quantity depends on unresolved weighting, standardization, subgroup-boundary, or aggregation choices.
- Hidden filtering or pre-aggregation makes "what is present" unclear.
