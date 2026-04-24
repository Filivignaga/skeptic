---
name: clean-exploratory
description: Stage-specific route file for the Skeptic clean stage for exploratory questions. Narrows the universal clean stage-core.
---

# Clean Route File: Exploratory

## What This Stage Protects
- Candidate heterogeneity, anomalies, rare strata, repeated events, and local structure unless a measurement-grounded reason requires change.
- Separation between source defects and candidate phenomena.
- Reversible, least-committing cleaning decisions.

## What This Stage Prohibits
- Removing, winsorizing, capping, or pooling anomalies, rare levels, or unusual repeats just because they destabilize apparent structure.
- Collapsing categories, binning time, smoothing series, or aggregating records just to make patterns easier to see.
- Justifying preprocessing by anticipated use of PCA, clustering, embeddings, anomaly detection, or subgroup discovery.
- Creating search-oriented derived variables in `clean`, including components, embeddings, cluster labels, anomaly scores, residualized variables, or feature-screened subsets.
- Resolving duplicate-like records for convenience when recurrence, intensity, or event structure may be real.

## What This Stage Defers
- Scaling, encoding, normalization, imputation, smoothing, aggregation, and latent construction choices whose rationale depends on the exploratory method.
- Any transform that mainly changes geometry, smoothness, density, or separability.

## What Triggers Backtracking In This Stage
- A cleaning choice materially changes anomaly counts, subgroup prevalence, tail mass, or correlation structure without measurement-grounded justification.
- Apparent structure aligns with source, batch, merge, coding, or timestamp artifacts.
- A needed preprocessing or derivation choice depends on the exact exploratory method family or tuning strategy.
- It remains unresolved whether unusual records are defects or the phenomenon the route is supposed to surface.

## Protected surface

Route overlays may narrow this stage's surface. They may not rewrite or remove fields from the protected surface declared in `references/core-principles.md` §4.8 (decision register, reconciliation table / chain, claim-critical helper set). A route-specific requirement that shrinks the decision register, breaks the reconciliation arithmetic, or removes a helper is rejected regardless of route-specific rationale.
