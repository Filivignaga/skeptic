---
name: examine-exploratory
description: Stage-specific route file for the DSLC examine stage for exploratory questions. Narrows the universal examine stage-core.
---

# Examine Route File: Exploratory

## What This Stage Protects
- The search-to-claim boundary.
- Clear labeling of candidate structure as supported, weakly supported, or unsupported.
- Explicit instability across views, encodings, subgroup definitions, and representations when those choices change the apparent pattern.
- A first-pass workflow that can start on a representative subsample when the full artifact is too dense for direct inspection.

## What This Stage Prohibits
- Presenting searched structure as confirmed evidence.
- Letting one embedding, clustering, anomaly view, or other single search result dominate the handoff.
- Using predictive, inferential, causal, or mechanistic language to stabilize exploratory patterns.
- Proliferating subgroup definitions, time windows, thresholds, or geometry-shaping transforms inside `examine`.
- Treating a single summary table or a single plot as sufficient when the visible structure still depends on reasonable alternatives.

## What This Stage Defers
- The exact exploratory method family, parameter grids, subgroup definitions beyond upstream-licensed slices, anomaly thresholds, latent dimensionality, and the concrete analysis specification.
- Any search program that belongs to `analyze`.

## Working Defaults
- Start with the simplest visible summaries and plots before layered or high-dimensional views.
- If the data are large or dense, inspect a representative subsample first and scale up only when the small view is insufficient.
- Use summary statistics as descriptive support, not as a replacement for seeing the shape of the data.
- Compare at least one reasonable alternative visualization before treating a structure as stable.
- Stop exploratory iteration when additional views only repeat the same support picture or when the next step would require final-analysis logic.

## What Triggers Backtracking In This Stage
- A candidate pattern collapses under minor examination perturbation.
- A candidate pattern aligns with cleaning artifacts, batch structure, merge artifacts, or unsupported slices.
- The work starts needing confirmation claims, population generalization, predictive performance claims, or causal interpretation.
- Grouping, time dependence, or interference matters more than `protocol` allowed.
- The current exploration keeps adding redundant displays or summaries without changing what the stage can support.
