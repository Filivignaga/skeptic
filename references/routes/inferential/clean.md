---
name: clean-inferential
description: Stage-specific route file for the DSLC clean stage for inferential questions. Narrows the universal clean stage-core.
---

# Clean Route File: Inferential

## What This Stage Protects
- The link between observed units and the approved target population.
- Design-relevant structure, including eligibility, sampling-frame fields, weights, strata, clusters, repeated-measure identifiers, panel identifiers, and time order when relevant.
- Uncertainty credibility by avoiding cleaning moves that silently narrow the population or erase dependence.

## What This Stage Prohibits
- Dropping, trimming, capping, winsorizing, or pooling observations mainly to improve anticipated inferential behavior, normality, precision, or model convenience.
- Modifying, reconstructing, normalizing, or discarding weights, replicate weights, strata, cluster IDs, eligibility markers, or sampling-frame fields except for documented semantic repair.
- Choosing duplicate-resolution rules using the outcome, target relationship, or preferred estimate direction.
- Performing generic single imputation or model-based imputation for inferentially relevant fields in `clean`.
- Treating complete-case restriction as a harmless default.

## What This Stage Defers
- Missing-data strategy, weight use or trimming, estimator and variance choices, functional-form decisions, and outlier treatment tied to estimator behavior.
- Any derived variable whose acceptability depends on the exact estimand, estimator, link function, adjustment set, or identification strategy.

## What Triggers Backtracking In This Stage
- Cleaning materially changes the analyzable population relative to the approved target population or frame.
- Required inferential structure is missing, corrupted, or semantically ambiguous.
- Duplicate or linkage resolution changes whether units are independent, repeated, clustered, or otherwise design-relevant.
- Missingness is concentrated enough across inferentially relevant groups that simple deletion would change the population claim.
- Resolving a cleaning issue would require choosing among competing inferential assumptions instead of repairing data fidelity.
