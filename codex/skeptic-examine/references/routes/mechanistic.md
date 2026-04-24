---
name: examine-mechanistic
description: Stage-specific route file for the Skeptic examine stage for mechanistic questions. Narrows the universal examine stage-core.
---

# Examine Route File: Mechanistic

## What This Stage Protects
- Falsifiability, identifiability pressure, regime support, and process-relevant structure rather than visual fit or narrative coherence.
- Visibility of process conditions the question depends on, including states or proxies, transitions, ordering, regimes, boundary conditions, extremes, repeated trajectories, and domain constraints.
- Explicit warning when multiple incompatible mechanism stories fit the same visible pattern.

## What This Stage Prohibits
- Treating association, fit, or visual regularity as evidence of a unique mechanism.
- Inferring hidden states, feedback loops, thresholds, parameter variation, or process direction from one aggregation, one binning choice, or one descriptive dependence view.
- Using generic all-pairs association scans, cluster hunting, or feature-importance framing as mechanistic support.
- Letting `examine` choose equations, simulator classes, state layouts, lag structure, or parameter structure.

## What This Stage Defers
- The exact structural form, simulator family, calibration strategy, latent-state choices, parameterization, validation implementation, and exact perturbation set.
- Any structural specification that belongs to `analyze`.

## What Triggers Backtracking In This Stage
- Mechanistically critical variables, ordering, or support are cleaning-dependent or artifact-sensitive.
- Visibility, temporal, grouped, or validation rules are too weak for the mechanistic claim.
- The approved question requires unobserved states, inputs, regimes, or constraints the visible data cannot support.
- Boundary-condition or extreme-support coverage needed to test the mechanism is absent.
- Multiple rival mechanisms remain equally plausible with no visible way to narrow them.
