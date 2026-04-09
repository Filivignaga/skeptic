---
name: protocol-inferential
description: Stage-specific route file for the DSLC protocol stage for inferential questions. Narrows the universal protocol stage-core.
---

# Protocol Route File: Inferential

## What This Stage Protects
- The population claim, the approved frame for generalization, and the dependence structure that claim assumes.
- Explicit representativeness limits.
- Separation between inferential claims and predictive or causal claims.

## What This Stage Prohibits
- Treating train, validation, or test logic as the default reality check.
- Allowing causal language, predictive performance claims, or generalization beyond the approved population or frame.
- Letting later stages use significance-driven specification search, silent reweighting, or post hoc subgroup carving as confirmatory evidence.

## What This Stage Defers
- The exact estimator or test, covariate set, weighting recipe, variance procedure, resampling implementation, multiplicity handling, and exact analysis specification.
- Any modeling choice that belongs to `analyze`.

## What Triggers Backtracking In This Stage
- The target population or sampling frame turns out to be ill-defined.
- Cleaning materially changes the analyzable population.
- Examination reveals stronger clustering, selection, or measurement distortion than protocol allowed.
- Weights are unstable, unsupported, or inconsistent with the approved frame.
- The intended claim starts needing causal identification or predictive deployment logic.
