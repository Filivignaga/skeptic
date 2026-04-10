---
name: evaluate-mechanistic
description: Stage-specific route file for the Skeptic evaluate stage for mechanistic questions. Narrows the universal evaluate stage-core.
---

# Evaluate Route File: Mechanistic

## What This Stage Protects
- The claim boundary around mechanism rather than fit: mechanism is claimed only to the extent structural assumptions, calibration targets, and domain knowledge are defended. Good fit alone is not enough.
- Identifiability as a prerequisite for interpretability: parameters that are not identifiable cannot carry mechanistic meaning, regardless of calibration quality.
- Separation between structural adequacy and parametric adequacy: a model can be structurally wrong with well-estimated parameters, or structurally right with poorly estimated parameters. Evaluate must distinguish which failure mode applies.
- Falsifiability of the structural form: if no data pattern could have rejected the proposed structure, the mechanism claim is unfalsifiable and does not survive.
- Regime-bounded claims: mechanism claims survive only within the regime the calibration data covers. Out-of-regime extrapolation is not licensed by in-regime fit.
- Equifinality awareness: when multiple structurally distinct models fit equally well, the mechanism claim must be narrowed to what all surviving structures share, or it does not survive.

## What This Stage Prohibits
- Treating goodness-of-fit as mechanism evidence. A model that fits well but has non-identifiable, implausible, or non-unique parameters has not demonstrated a mechanism.
- Interpreting calibrated parameter values as biologically or physically meaningful without identifiability support. Non-identifiable parameters cannot carry causal or process interpretation.
- Dismissing structural alternatives that fit equally well. Equifinality is a direct threat to mechanism claims and must be adjudicated, not ignored.
- Narrative plausibility as a substitute for formal validation. A coherent story about why the mechanism makes sense is not evidence that the model is structurally correct.
- Post-hoc structural revision after seeing evaluation results. Adding compartments, feedback loops, or states to rescue a failing model converts evaluation into exploratory model building. Route back to analyze.
- Claiming mechanism beyond the calibrated regime. Boundary-condition and out-of-regime checks that fail restrict the claim to the calibrated domain.
- Overfitting through flexible structure: treating improved fit from added structural complexity as evidence of mechanism when identifiability or parsimony checks were not applied.
- Using simulation agreement alone as validation. A simulation that reproduces the calibration data proves the code is consistent with the fit, not that the mechanism is correct.
- Self-revision based on result quality. Evaluate adjudicates what analyze produced. It does not refit, recalibrate, or restructure.

## What This Stage Defers
- How to frame mechanism claims for a specific audience (communicate).
- Whether to recommend policy, intervention, or design changes based on the mechanism (communicate).
- Narrative packaging of surviving claims, limitations, and caveats (communicate).
- Whether a failed mechanism claim should motivate a new research question (outside this project scope).

## What Triggers Backtracking In This Stage
- All structural alternatives fit equally well and the primary structure cannot be distinguished: the mechanism claim is equifinal. Return to analyze to test additional structural discriminators, or to protocol if the claim boundary was set too broadly.
- Structural identifiability failure discovered or confirmed during evaluation that was missed or deferred in analyze. Return to analyze to reparameterize or reduce.
- Practical identifiability failure across the full parameter set: profile likelihoods are flat for parameters central to the mechanism claim. Return to analyze to assess whether reparameterization, data augmentation, or claim narrowing is feasible.
- Calibrated parameters fall outside domain-plausible ranges with no defensible explanation. Return to analyze to check calibration procedure and structural assumptions.
- Simulation-based validation fails: the calibrated model cannot reproduce known qualitative dynamics, boundary-condition behavior, or independent validation targets. Return to analyze if the structural form or calibration is suspect, or to protocol if the validation targets were mis-specified.
- Boundary-condition stress tests reveal catastrophic failure within the claimed regime. Return to analyze to reassess regime specification.
- Out-of-regime failure analysis reveals that the model fails immediately outside the calibration domain in ways that contradict the proposed mechanism. Return to analyze or protocol depending on whether the regime claim was too broad.
- Structural sensitivity analysis shows that minor changes in functional forms produce qualitatively different dynamics, undermining the structural claim. Return to analyze to assess whether alternative functional forms were adequately tested.
- No claims survive evaluation at all. Return to protocol to reassess what claims are achievable, or to formulate if the question itself is unanswerable with this data.

## Stability Checks
- Parametric sensitivity: adjudicate whether the primary result changes materially under the perturbation axes from the analyze contract (local sensitivity, global sensitivity, alternative initial conditions, alternative boundary conditions).
- Structural sensitivity: adjudicate whether alternative functional forms for rate laws and interaction terms produce qualitatively different dynamics or parameter estimates.
- Calibration sensitivity: adjudicate whether alternative calibration targets, methods, priors, or loss functions change the primary conclusion.
- Challenger adjudication: for each structural alternative (different ODE/compartment structures, topological perturbations, alternative observation models), assess whether it contradicts the primary, supports the primary, or is indistinguishable from the primary.
- Data perturbation stability: adjudicate whether subsampling, jackknife, or temporal-resolution perturbations change the qualitative conclusion.
- Convergence across perturbation axes strengthens the mechanism claim. Divergence across structural alternatives weakens it more than divergence across parametric perturbations. Weight accordingly.

## Predictability Checks
- Simulation-based validation: the calibrated model is simulated forward and compared against data not used in calibration, independent validation targets, or known qualitative dynamics. This is the primary predictability reality check for mechanistic routes.
- Boundary-condition checks: the model is tested at boundary conditions (extreme values, edge regimes, limiting cases) where the mechanism makes specific predictions. Failure at boundaries the mechanism claims to cover is a predictability failure.
- Out-of-regime behavior: assess whether the model produces physically or biologically plausible behavior when pushed beyond the calibration domain. Implausible out-of-regime behavior weakens the mechanism claim even if in-regime fit is good.
- Posterior predictive checks (when Bayesian): simulated data from the posterior predictive distribution are compared against observed data. Systematic discrepancies indicate model misspecification.
- Calibration-prediction separation: verify that the validation targets used in predictability checks are genuinely independent of the calibration targets. Overlap between calibration and validation data inflates predictability.

## Formal Validity Tools
- Structural identifiability analysis: verify that all parameters central to the mechanism claim are structurally identifiable (differential algebra, generating-series, or equivalent). If structural identifiability was established in analyze, confirm no contract amendments or deviations invalidated it. If it was flagged as uncertain, resolve it here.
- Practical identifiability (profile likelihood): for each parameter central to the mechanism claim, verify that profile likelihoods are bounded and produce finite confidence intervals. Flat profiles indicate the data cannot constrain that parameter regardless of structural identifiability.
- Parameter plausibility checks: verify that calibrated parameter values fall within domain-plausible ranges. Parameters with implausible values (negative rates, volumes exceeding physical bounds, affinities outside known ranges) undermine the mechanism claim even if identifiability is satisfied.
- Equifinality assessment: systematically assess whether multiple structurally distinct models produce statistically indistinguishable fits. When equifinality holds, the mechanism claim must be narrowed to what all surviving structures share. Use formal model comparison (AIC, BIC, Bayes factors, cross-validated likelihood) where applicable, but do not rely on information criteria alone to distinguish mechanisms.
- Simulation-based validation: simulate the calibrated model under conditions not used for fitting and compare against independent data or known qualitative behavior. This is both a predictability check and a validity tool.
- Boundary-condition stress tests: simulate the model at boundary conditions, extreme parameter combinations, and regime edges. Failure modes reveal where the structural assumptions break down.

## Adversarial Review Guidance
- Bias inversion for mechanism: assume the proposed mechanism is wrong. Identify what alternative process (different causal structure, confounded pathway, measurement artifact, or simpler explanation) could produce the same observed fit. Assess the plausibility of each alternative given the data, design, calibration results, and identifiability diagnostics.
- Equifinality as an adversarial test: the strongest adversarial challenge to a mechanism claim is a structurally different model that fits equally well. If the analyze contract included structural alternatives, evaluate whether any alternative produces indistinguishable outputs. If no structural alternatives were tested, flag this as a gap.
- Construct validity for mechanistic parameters: assess whether the parameters that carry the mechanism story actually measure what they claim. A "growth rate" parameter that absorbs model misspecification is not measuring growth rate. Cross-reference parameter estimates against independent domain knowledge.
- Overfitting through structure: assess whether the model's structural complexity is justified by identifiability and data support, or whether the fit would degrade substantially under a simpler structure. Flexible structures that fit well but collapse under structural perturbation are overfitting.
- Narrative coherence is not evidence: a biologically or physically compelling story about why the mechanism works does not count as validity evidence. Demand quantitative support (identifiability, parameter plausibility, simulation-based validation, boundary-condition behavior) for every element of the mechanism claim.
- Regime extrapolation pressure: present the user with the boundary of the calibrated regime and ask whether the mechanism claim implies behavior beyond that boundary. If yes, assess whether out-of-regime predictions are testable or whether the claim must be explicitly restricted.
