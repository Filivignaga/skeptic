---
name: evaluate-predictive
description: Stage-specific route file for the DSLC evaluate stage for predictive questions. Narrows the universal evaluate stage-core.
---

# Evaluate Route File: Predictive

## What This Stage Protects
- Per-claim survival verdicts grounded in unseen-data performance, not in-sample fit quality or training-set metrics.
- The test-set single-use rule: the held-out test set is consumed exactly once for final evaluation in this stage. No recycling, re-splitting, or threshold re-tuning on test outputs.
- The claim boundary: predictive performance only. No causal, mechanistic, or explanatory claims derived from model internals, feature importance, or coefficient magnitudes.
- Calibration integrity: probability outputs evaluated against observed frequencies on held-out data, not on training or validation data already used for model selection.
- Validation-frame fidelity: the validation scheme executed in `analyze` matches what `protocol` specified (holdout, rolling-origin, group split, cross-validation, external validation). Evaluate adjudicates the results of that scheme; it does not substitute a different one.
- Threshold operating-point adequacy: the locked decision threshold is evaluated against deployment cost structure on held-out data, not re-optimized after seeing test performance.

## What This Stage Prohibits
- Re-tuning hyperparameters, thresholds, feature sets, calibration parameters, or ensemble weights after seeing test-set performance.
- Using test-set outputs to select among fits, output modes, or specifications that `analyze` produced.
- Interpreting predictive model internals (SHAP, permutation importance, coefficients, partial dependence) as causal evidence. These measure correlation structure in the fitted model, not the effect of intervening on a variable.
- Substituting a different validation scheme than what `protocol` specified and `analyze` executed.
- Re-executing the K x L fit matrix, predictability screening, or output-mode construction. Those are locked in `analyze`.
- Generating new predictive claims beyond what the analysis contract was designed to support.
- Widening the claim boundary to include causal, mechanistic, or explanatory assertions.
- Treating baseline-beating as sufficient evidence of predictive value without assessing calibration, stability, and deployment-context fit.
- Dismissing poor calibration when the output mode produces probability estimates or prediction intervals.

## What This Stage Defers
- Audience framing, narrative construction, and communication packaging: `communicate` receives only claims that survived evaluation.
- Action recommendations, deployment decisions, or threshold revision proposals: those belong to `communicate` or to the decision-maker, not to the evaluation verdict.
- Re-specification of the predictive contract: if the contract must change, backtrack to `analyze` or `protocol`.

## What Triggers Backtracking In This Stage
- Test-set leakage discovered: any evidence that test-set information influenced model fitting, feature selection, threshold tuning, or output-mode selection during `analyze`. Return to `analyze` or `protocol`.
- Optimistic validation detected: cross-validation or holdout performance in `analyze` materially exceeds test-set performance in a pattern consistent with overfitting, data leakage, or improper preprocessing outside the fold. Return to `analyze`.
- Target drift or regime change: test-set distribution differs from training distribution in a way that invalidates the predictive claim (covariate shift, concept drift, label drift). Return to `protocol` if the validation frame was mis-specified, or to `analyze` if a drift-aware method was available but not used.
- Calibration failure: probability outputs are materially miscalibrated on held-out data and the output mode depends on calibrated probabilities (PPIs, risk stratification). Return to `analyze` if recalibration is possible within the locked contract, or to `protocol` if the calibration method was mis-specified.
- All fits fail predictability screening on test data: no fit from the K x L matrix outperforms the locked baseline on the held-out set. Return to `protocol` to reassess what claims are achievable, or to `formulate` if the question is unanswerable with this data.
- No claims survive evaluation: return to `protocol` to reassess or to `formulate` plus `protocol` if the predictive question itself is unanswerable.

## Stability Checks
- Adjudicate every perturbation axis from the K x L fit matrix: preprocessing perturbation (K axis), algorithm perturbation (L axis), hyperparameter perturbation within cells, and feature-subset perturbation if encoded in K.
- For each axis, compare test-set performance of perturbed fits against the primary fit. Classify divergence as:
  - **acceptable variation**: direction and qualitative conclusion unchanged, magnitude within expected range for the method and data profile
  - **instability requiring caveat**: direction unchanged but magnitude shift is notable, or qualitative conclusion is sensitive to specific perturbation choices
  - **instability requiring backtracking**: qualitative conclusion reverses or the primary fit is an outlier relative to the perturbation distribution
- Adjudicate every challenger from the analysis contract. Structural disagreement (different method family, different conclusion) is weighted more heavily than parametric disagreement (same direction, different magnitude).
- Weight judgment-call preprocessing perturbations equally alongside algorithmic and data perturbations. Preprocessing decisions that materially change test-set performance are stability-relevant, not secondary.
- For PCS ensemble or PPI output modes, assess whether the ensemble or interval adequately captures the perturbation-driven variation. If the ensemble collapses to near-identical fits or the interval excludes results from reasonable perturbation paths, flag as instability.
- Bootstrap instability (PPI mode): if bootstrap resamples produce intervals that fail to cover the test-set observed rate at the nominal level, flag as calibration-related instability.

## Predictability Checks
- Execute the protocol-specified validation reality check on held-out test data. This is the single-use test-set consumption authorized by `protocol`.
- Unseal the test set only at this point. Verify that `protocol` authorizes unsealing for `evaluate` and that no prior stage consumed it.
- Compare test-set performance against: (1) the locked baseline (dummy or naive predictor from `analyze`), (2) the primary fit's validation-set performance from `analyze`, and (3) the predictability screening threshold from the analysis contract.
- Assess performance degradation from validation to test: a material drop signals optimistic validation. Quantify the gap and classify as routine shrinkage, concerning degradation, or failure.
- For classification tasks: evaluate at the locked threshold operating point. Report confusion matrix, sensitivity, specificity, PPV, NPV, and the deployment-relevant metric at the locked threshold. Do not re-optimize the threshold on test data.
- For regression tasks: evaluate on the locked scoring metric. Report residual distribution, prediction interval coverage (if PPI mode), and performance across deployment-relevant subgroups.
- Calibration assessment: compare predicted probabilities or intervals against observed frequencies on held-out data. Report calibration slope, intercept, Brier score decomposition (reliability, resolution, uncertainty), and reliability diagram. For PPI mode, report empirical coverage at the nominal level.
- Subgroup predictability: assess whether predictive performance is stable across deployment-relevant subgroups identified in `examine` or `protocol`. Flag subgroups where performance degrades materially below the overall level.
- Rolling-origin or temporal validation (when protocol specifies): assess whether performance degrades over the prediction horizon. Flag temporal decay patterns.
- External validation (when protocol specifies): compare internal test-set performance to external-set performance. Classify the gap.
- Render per-claim predictability verdict:
  - **adequate**: test-set performance exceeds the baseline and the screening threshold, calibration is acceptable, no material subgroup failures, validation-to-test degradation is within routine shrinkage
  - **marginal**: test-set performance exceeds the baseline but falls below the screening threshold, or calibration is imperfect but not misleading, or specific subgroups underperform
  - **inadequate**: test-set performance does not exceed the baseline, or calibration failure makes probability outputs unreliable, or validation-to-test degradation indicates overfitting or leakage

## Formal Validity Tools
- **Calibration slope and intercept**: fit a logistic recalibration model on test-set predicted probabilities versus observed outcomes. Slope near 1 and intercept near 0 indicate good calibration. Material deviation flags miscalibration. Do not use this to recalibrate; use it to diagnose.
- **Reliability diagram**: bin predicted probabilities and plot observed frequency against predicted probability on held-out data. Visual assessment of calibration across the probability range.
- **Brier score decomposition**: decompose into reliability (calibration error), resolution (discrimination), and uncertainty (outcome base rate). High reliability component relative to resolution signals a calibration problem more than a discrimination problem.
- **Prediction interval coverage (PPI mode)**: compute empirical coverage of prediction intervals at the nominal level on held-out data. Material undercoverage flags overconfident intervals; material overcoverage flags uninformative intervals.
- **Drift assessment**: compare feature distributions and target distribution between training, validation, and test sets. Flag covariate shift (feature distributions differ) and concept drift (relationship between features and target differs). Use population stability index, KL divergence, or distributional tests as appropriate.
- **Proxy target and leakage re-check**: verify that no feature in the locked set is a post-outcome field, administrative consequence of the label, or variable with implausibly high predictive power. This re-check uses test-set evidence (e.g., a single feature explaining most of the predictive signal) to catch leakage that was not visible in `analyze`.
- **Threshold sensitivity on test data (diagnostic only)**: sweep the decision threshold across a range and report the performance frontier (ROC, precision-recall curve) on test data. This is diagnostic -- it shows what the locked threshold leaves on the table. Do not use it to re-select the threshold.

## Adversarial Review Guidance
- **Bias inversion for predictive claims**: assume the model's test-set performance is misleading. Reason backward to identify plausible systematic errors: test-set leakage through shared entities or temporal overlap, target contamination through proxy features, distribution shift between test and deployment, survivorship bias in the test population, label noise correlated with features, or threshold gaming where the locked threshold happens to exploit a test-set artifact.
- **Construct validity for the prediction target**: assess whether the operationalized target (the label column) still captures the intended deployment outcome after the full pipeline. Did label definitions drift during cleaning? Does the prediction horizon match the deployment decision point? Would the predicted quantity actually be actionable in the deployment context?
- **Deployment-context stress test**: the model was validated on the test set. Would it perform the same way on the actual deployment population? Identify differences between the test set and the deployment context: temporal gap, population composition, data quality, feature availability, and decision-making context. Each difference is a validity threat that must be disclosed.
- **Feature importance as validity signal, not causal evidence**: if `analyze` produced feature importance outputs (SHAP, permutation importance, coefficients), use them only as validity signals. A model that relies heavily on a single feature, on features with no domain rationale, or on features that are proxies for protected attributes is validity-threatened. Do not interpret importance as causal effect.
- **Expert falsification**: present the test-set results alongside a plausible alternative (e.g., a model that achieves similar performance using only demographic features, or a model that degrades sharply outside the test-set time window). Ask whether the primary model's performance reflects genuine predictive signal or an artifact of the validation setup. If no domain expert is available, document the gap.
