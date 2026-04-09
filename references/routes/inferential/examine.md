---
name: examine-inferential
description: Stage-specific route file for the DSLC examine stage for inferential questions. Narrows the universal examine stage-core.
---

# Examine Route File: Inferential

## What This Stage Protects
- The population claim, target frame, and dependence structure that later generalization and uncertainty rely on.
- Clear separation between what is observed in visible data and what is credibly supportable as a population claim.
- Support characterization centered on eligibility, coverage, weights if present, strata, clusters, repeated-unit structure, and support within claim-relevant subgroups.

## What This Stage Prohibits
- Letting sample-only structure silently become a population statement.
- Importing predictive framing, significance hunting, or causal interpretation into `examine`.
- Using arbitrary subgroup carving, generic target-association screens, or analysis-shaped summaries chosen mainly because they look promising.
- Settling weighting, estimator, variance, adjustment, or multiplicity decisions here.

## What This Stage Defers
- The exact estimator, test, model form, weighting recipe, variance procedure, adjustment strategy, subgroup estimands, multiplicity handling, and exact analysis specification.
- Any inferential decision that belongs to `analyze`.

## What Triggers Backtracking In This Stage
- The target population or frame turns out to be ill-defined in practice.
- Required strata, groups, waves, or windows are unsupported.
- Analysis-relevant frame fields are unusable, contradictory, or cleaning-dependent.
- Dependence, selection distortion, or measurement distortion is stronger than `protocol` allowed.
- The intended claim starts needing causal identification or predictive deployment logic.
