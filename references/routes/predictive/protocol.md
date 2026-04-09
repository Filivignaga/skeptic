---
name: protocol-predictive
description: Stage-specific route file for the DSLC protocol stage for predictive questions. Narrows the universal protocol stage-core.
---

# Protocol Route File: Predictive

## What This Stage Protects
- Credible unseen-data performance claims.
- The prediction-time information boundary.
- A deployment-matched validation frame and restricted-artifact access rules.

## What This Stage Prohibits
- Allowing predictive claims without a protected unseen-data or deployment-matched reality check.
- Letting later stages peek at restricted holdouts, choose the best split after seeing results, or tune thresholds or features on the final protected frame.
- Letting feature importance, coefficients, or proxy success turn into causal or mechanistic explanation.

## What This Stage Defers
- The exact estimator, feature set, metric specification within the approved metric family, tuning scheme, threshold selection, ensembling, and refit strategy.
- Any model-specific analysis detail that belongs to `analyze`.

## What Triggers Backtracking In This Stage
- Predictors are not truly available at scoring time.
- Labels or timestamps create leakage.
- Cleaning breaks the frozen validation frame.
- Group or temporal dependence invalidates the chosen mode.
- The external set is not truly external.
- Event support is too thin for the approved reality check.
