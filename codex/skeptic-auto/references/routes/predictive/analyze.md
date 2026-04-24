---
name: analyze-predictive
description: Stage-specific route file for the Skeptic analyze stage for predictive questions. Narrows the universal analyze stage-core.
---

# Analyze Route File: Predictive

## What This Stage Protects
- Prediction-time information boundary: every feature, transform, and preprocessing step is available at scoring time. No train-serving skew.
- Validation hierarchy integrity: the test set is consumed exactly once for final evaluation in `evaluate`. The validation set is consumed by predictability screening and output-mode selection within `analyze`. Neither is re-used to revise the contract after seeing results.
- Contract-execution correspondence: the locked specification (method, features, hyperparameters, preprocessing, threshold logic, scoring rule) executes as locked.
- Scoring-rule propriety: the primary accuracy metric is a strictly proper scoring rule (Brier score, log loss) or a rule whose deployment-threshold assumptions are explicitly stated.
- Output-mode commitment: single PCS fit, PCS ensemble, or calibrated PPIs locked before execution, not switched after seeing primary results.

## What This Stage Prohibits
- Test-set feedback loop: any use of test-set performance to revise the contract, tune hyperparameters, select features, adjust thresholds, or choose the output mode.
- Preprocessing outside the fold: fitting scalers, encoders, imputers, or feature selectors on the full dataset before cross-validation or before the train-validation split.
- Post-hoc threshold tuning on restricted data.
- Causal language from feature importance: SHAP values, permutation importance, and coefficients measure correlation structure in the model, not causal effect.
- Post-hoc sensitivity or challenger addition after seeing primary results.
- Self-revision based on result quality.

## What This Stage Defers
- Predictability adjudication: whether the primary result meets the screening threshold. `evaluate` decides which fits pass.
- Stability verdict: whether perturbation and challenger divergence constitutes instability.
- Calibration sufficiency: whether calibrated probabilities are adequate for the deployment context.
- Output-mode final selection: `evaluate` performs predictability screening that determines which fits survive.
- Threshold operating-point adequacy: whether the locked threshold meets deployment cost requirements.
- Claim-scope licensing: whether the predictive claim is licensed by the evidence.

## Route Branching Guidance
- Use regression when the target is naturally continuous and the question cares about magnitude, not a discrete cutoff.
- Use classification when the downstream decision is discrete or thresholded and that threshold is part of the real action.
- Thresholding a continuous target is a question change, not a neutral preprocessing choice. Only do it when protocol explicitly approves that task shift.
- Do not choose classification simply because it is easier to score. Match the route to the substantive question.

## Metric, Loss, and Model Guidance
- Probabilistic outputs should use a proper scoring rule such as log loss or Brier score when probability quality matters.
- Continuous regression outputs should use a loss aligned with the error shape the user cares about: MAE or MAD for robustness to outliers, MSE or RMSE for stronger outlier penalties.
- Binary classification should keep the locked threshold separate from the scoring rule. The threshold is a deployment decision, not a substitute for the loss function.
- Use regularized linear models when transparency, stability, or coefficient-level sanity checking matters.
- Use trees or ensembles when nonlinear interactions, threshold effects, or feature interplay are likely important enough to justify the added complexity.
- Prefer the simplest model family that still matches the route, the loss, and the deployment setting.

## Deployment Tradeoffs
- Interpretability vs. accuracy: choose a more complex model only if the accuracy gain is meaningful enough to justify the loss of clarity.
- Speed vs. accuracy: real-time scoring or latency constraints may justify a simpler model even if a more complex model scores better.
- Simplicity vs. accuracy: if two models are materially similar, prefer the simpler one.
- Scalability vs. accuracy: large or rapidly refreshed deployments may favor a model that is easier to retrain, monitor, and explain.

## What Triggers Backtracking In This Stage
- Feature not available at prediction time discovered during execution.
- Target leakage discovered in the locked feature set.
- Data volume insufficient for the locked method's minimum viable sample or the K x L fit matrix.
- Class imbalance or target-range compression makes the locked scoring rule degenerate.
- Train-validation distribution mismatch exceeds protocol tolerance.

## Cycle B: Assumption Checks

- Leakage re-check: no locked feature is a proxy target, label echo, post-outcome field, or future-information variable.
- Prediction-time availability: every locked feature is available at the as-of time defined in protocol.
- Class balance and target distribution: target prevalence or response distribution matches what the locked method and scoring rule assume.
- Collinearity: variance inflation or condition number within the locked method's tolerance.
- Data volume adequacy: training sample size sufficient for the locked method's parameter count, perturbation axes, and K x L fit matrix.
- Feature cardinality and sparsity: categorical features do not exceed the training set's ability to estimate level effects.
- Temporal or group dependence: if protocol specifies temporal or group-based validation, the locked specification does not violate the ordering or boundary.

## Perturbation Axes

The predictive route operates on a K x L fit matrix:

- Preprocessing perturbation (K axis): K alternative cleaned and preprocessed dataset versions from the judgment-call combinations identified in `clean`. Same raw observations, different preprocessing.
- Algorithm perturbation (L axis): L structurally diverse algorithm families trained on each of the K preprocessed datasets.
- Hyperparameter perturbation: within each cell of K x L, the hyperparameter search space locked in the contract is explored.
- Data perturbation and bootstrap (PPI mode only): each surviving fit retrained on J bootstrap samples.
- Feature-subset perturbation: encoded as part of the K preprocessing axis through different feature-selection thresholds.

The contract must specify: number of preprocessing variants (K), number of algorithms (L), hyperparameter search space per algorithm, bootstrap count (J) if PPIs, and predictability screening threshold.

## Route-Specific Contract Fields

| Field | Description | Required |
|-------|-------------|----------|
| Algorithm family and specification | Each of the L algorithms: family, implementation, key structural parameters | Yes |
| Hyperparameter search space | Per algorithm: parameter grid or distribution, search strategy, budget | Yes |
| Scoring metric | Primary: strictly proper scoring rule. Secondary: deployment-relevant metrics. Justify each | Yes |
| Threshold logic | For classification: how the decision threshold is determined. Locked before execution or derived from training and validation data only | Yes |
| Calibration method | Platt scaling, isotonic regression, or none. Calibration data source and pipeline position | Yes |
| Ensemble and output mode | Single PCS fit, PCS ensemble, or calibrated PPIs. Locked before execution | Yes |
| Predictability screening threshold | Top x percent of fits retained by validation-set performance | Yes |
| K x L fit matrix specification | K preprocessing variants, L algorithms, J bootstrap count if PPIs, expected total fits | Yes |
| Baseline specification | Dummy or naive baseline (majority class, mean predictor, or domain-standard simple model) | Yes |
| Prediction horizon and as-of logic | Temporal definition of when the prediction is made and when the outcome is observed | Yes |
| Feature freeze list | Exact feature set with confirmation that each feature passes prediction-time availability | Yes |

## Internal Execution Sequence

Cycle C (Primary Execution) follows this order:

1. Baseline fit: fit a dummy or naive baseline on the training data. Record baseline performance on validation set using the locked scoring metric.
2. K x L fit matrix construction: for each of K preprocessing variants, train each of L algorithms using the locked hyperparameter search space. Record all K x L validation-set performance scores.
3. Predictability screening: rank all K x L fits by validation-set performance. Retain the top x percent per the locked threshold.
4. Output-mode construction: single PCS fit (best-performing fit), PCS ensemble (combine predictions of screened fits), or calibrated PPIs (bootstrap each screened fit, compute quantile intervals, calibrate on validation coverage).
5. Calibration if locked in contract: fit the locked calibrator on validation data. Record calibration curves and error metrics.
6. Record all outputs: point predictions, probability estimates, intervals, calibration diagnostics, computational diagnostics, seeds, parameters.

Cycle D (Sensitivity and Challenger Execution) additionally:

- Compare performance across K preprocessing variants (preprocessing perturbation).
- Compare performance across L algorithm families (algorithm perturbation).
- Compare performance across the hyperparameter search space.
- Execute pre-specified challengers structurally different from the primary.
- Report raw metric values without stability verdicts.
