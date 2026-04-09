---
name: clean-predictive
description: Stage-specific route file for the DSLC clean stage for predictive questions. Narrows the universal clean stage-core.
---

# Clean Route File: Predictive

## What This Stage Protects
- Prediction-time information boundaries, deployment-faithful measurement meaning, and protocol-defined visibility restrictions.
- Drift, delayed-label, and availability structure instead of cleaning them away.
- A prediction problem that matches the real deployment setting.
- Fit-on-train-only preprocessing boundaries for any transform that will later be learned from data.

## What This Stage Prohibits
- Fitting or choosing cleaning or preprocessing rules using restricted holdouts, future windows, external validation sets, or any artifact reserved for later predictive validation.
- Using targets, target-adjacent fields, realized outcomes, or post-outcome updates to clean or encode candidate predictor variables.
- Dropping, relabeling, or harmonizing rows primarily because they hurt likely predictive performance.
- Treating prediction-time availability as an analysis detail that can wait when a touched field may later serve as a predictor.
- Performing class balancing, thresholding, supervised feature screening, target encoding, or other analysis-shaped feature engineering in `clean`.
- Fitting learned encoders, imputers, scalers, rare-level grouping rules, or category-expansion conventions on artifacts that are reserved for later predictive validation.
- Hiding dummy-variable or reference-level decisions inside cleaning when the resulting representation depends on the eventual model family.

## What This Stage Defers
- The exact predictor set, model family, fold-wise learned transforms, lag or window definitions, thresholds, calibration, class weighting, and resampling choices.
- Any preprocessing that must be fit from data for later predictive use, including fold-wise encoders, imputers, scalers, rare-level grouping, or dummy-variable handling tied to a later model family.
- The exact omitted-category convention or reference-level choice for categorical expansion when it depends on the locked analysis contract.

## What Triggers Backtracking In This Stage
- A touched field is unavailable at prediction time or only populated after the outcome.
- A candidate predictor is actually a proxy target, label echo, or downstream administrative consequence of the outcome.
- Duplicate resolution, missingness handling, or row filtering materially changes target prevalence, hard-case coverage, or deployment-relevant subgroup composition.
- A needed preprocessing step requires fold-wise fitting, horizon-specific logic, or other analysis-contract details.
- A categorical expansion or encoding choice would create a dummy-variable dependency, omitted-category ambiguity, or other convention that cannot be fixed without knowing the final model family.
- Timestamp semantics, refresh logic, or coding changes imply drift or delayed-label structure not captured in `protocol`.
