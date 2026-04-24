---
name: examine-causal
description: Stage-specific route file for the Skeptic examine stage for causal questions. Narrows the universal examine stage-core.
---

# Examine Route File: Causal

## What This Stage Protects
- Treatment-outcome timing, overlap, treatment-support visibility, and the causal claim boundary.
- Support characterization centered on treatment variation, treatment timing, outcome observation timing, pre-treatment covariate support, overlap or positivity, and support within the approved population.
- First-class attention to interference, clustered assignment, treatment-dependent missingness, and timing contradictions.

## What This Stage Prohibits
- Converting descriptive or associational contrasts into effect evidence.
- Using post-treatment variables, mediators, colliders, descendants, future information, or protocol-forbidden fields in causal-diagnostic views.
- Running open-ended pairwise mining, "what predicts the outcome" scans, or subgroup searches aimed at rescuing a causal story.
- Letting `examine` silently pick DiD, matching, weighting, IV, RD, or another identification design.

## What This Stage Defers
- The exact identification strategy, adjustment set, nuisance models, weighting or matching design, overlap thresholds, event windows, falsification suite, sensitivity analysis, and heterogeneity specification.
- Any causal contract choice that belongs to `analyze`.

## What Triggers Backtracking In This Stage
- Treatment timing contradicts the approved question.
- Pre-treatment or post-treatment status of key variables is unresolved.
- Overlap fails in the approved population or collapses in protocol-relevant slices.
- Interference or grouped dependence is more central than `protocol` allowed.
- Cleaning removed critical pre-treatment support or treatment variation.
- No defensible identification family remains plausible inside the approved boundary.
