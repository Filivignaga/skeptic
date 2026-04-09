---
name: protocol-causal
description: Stage-specific route file for the DSLC protocol stage for causal questions. Narrows the universal protocol stage-core.
---

# Protocol Route File: Causal

## What This Stage Protects
- Identification, treatment-outcome timing, and the approved causal claim boundary.
- Explicit treatment, outcome, eligibility, and timing anchors.
- Separation between effect evidence and association, prediction, or generic model fit.

## What This Stage Prohibits
- Using predictive split logic or unseen-data scoring as a substitute for identification.
- Allowing post-treatment adjustment, bad-control conditioning, unsupported convenience controls, or causal language beyond the approved identification boundary.
- Letting later stages widen treatment timing, eligibility, or target population without reopening upstream.

## What This Stage Defers
- The exact identification strategy, adjustment set, estimator, cross-fitting details, falsification tests, sensitivity analysis, and heterogeneity specification.
- Any design-specific causal choice that belongs to `analyze`.

## What Triggers Backtracking In This Stage
- Treatment or outcome timing becomes ambiguous.
- Overlap or positivity collapses.
- Cleaning changes treatment eligibility or key pre-treatment covariates.
- Interference becomes central after protocol treated it as secondary.
- Only post-treatment controls remain for the intended comparison.
- No defensible identification family remains.
