---
name: clean-mechanistic
description: Stage-specific route file for the Skeptic clean stage for mechanistic questions. Narrows the universal clean stage-core.
---

# Clean Route File: Mechanistic

## What This Stage Protects
- Observational structure that can distinguish or falsify mechanisms, including direct observables, units, timestamp semantics, intervention timing, replicate or trajectory identity, and genuine extremes or transitions.
- Measurement meaning before structural interpretation.
- Information that separates competing mechanisms instead of making the data look more coherent than it is.

## What This Stage Prohibits
- Justifying cleaning actions by improved fit, calibration, or parameter stability.
- Enforcing structural laws or boundary behavior during cleaning unless already protocol-explicit as a measurement-fidelity step.
- Using model-based smoothing, filtering, deconvolution, latent-state reconstruction, or simulator-assisted imputation in `clean`.
- Collapsing trajectories, replicates, spatial units, or event histories when that could erase mechanism-relevant variation.
- Deriving hidden regimes, transition labels, rates, or state assignments from the observed series in `clean`.
- Removing apparent outliers merely because they contradict a plausible mechanism.

## What This Stage Defers
- Observation model choice, noise model, denoising or filtering family, temporal grid choice, interpolation rule, alignment rule, latent construction, and fit-driven transforms.
- Any transform that starts encoding state equations, rates, latent structure, or regime logic.

## What Triggers Backtracking In This Stage
- Raw-to-observable mapping is ambiguous enough that different defensible choices imply different mechanisms.
- Timestamp semantics, intervention timing, or replicate identity are unclear and could alter dynamic interpretation.
- Missingness, censoring, saturation, or truncation appears state-dependent or regime-dependent in a way central to the mechanism question.
- Different defensible cleaning policies materially change transitions, extrema, lag structure, or boundary-condition violations.
- Proceeding would require assuming a specific latent state structure, observation model, or dynamical law.

## Protected surface

Route overlays may narrow this stage's surface. They may not rewrite or remove fields from the protected surface declared in `references/core-principles.md` §4.8 (decision register, reconciliation table / chain, claim-critical helper set). A route-specific requirement that shrinks the decision register, breaks the reconciliation arithmetic, or removes a helper is rejected regardless of route-specific rationale.
