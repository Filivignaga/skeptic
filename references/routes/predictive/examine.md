---
name: examine-predictive
description: Stage-specific route file for the DSLC examine stage for predictive questions. Narrows the universal examine stage-core.
---

# Examine Route File: Predictive

## What This Stage Protects
- Deployment realism, prediction-time validity, and unseen-data claim integrity.
- A predictive support map built around target observability, prediction-time feature availability, label delay or censoring, event rate or target range compression, and support across deployment-relevant slices.
- Clear separation between in-sample structure and evidence about future predictive performance.

## What This Stage Prohibits
- Turning `examine` into generic feature-selection EDA.
- Inspecting restricted holdouts or other protected validation artifacts unless `protocol` explicitly authorizes the view for this stage.
- Treating in-sample association as evidence of unseen-data performance.
- Using deployment-unavailable variables, future information, post-outcome fields, direct target proxies, or label echoes as legitimate support.
- Reading predictive structure causally or mechanistically.

## What This Stage Defers
- The exact estimator, model family, feature set, representation choices, scoring rule, threshold logic, calibration method, ensemble strategy, and exact uncertainty outputs.
- Any model contract that belongs to `analyze`.

## What Triggers Backtracking In This Stage
- Predictive support relies on forbidden or deployment-unavailable variables.
- Target observability, as-of logic, or horizon definition is inconsistent with the approved question.
- Drift or regime change outruns the approved predictive claim.
- Dependence or repeated-entity structure is stronger than `protocol` allowed.
- Support is too thin for the stated deployment context.
