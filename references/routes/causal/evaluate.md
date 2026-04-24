---
name: evaluate-causal
description: Stage-specific route file for the Skeptic evaluate stage for causal questions. Narrows the universal evaluate stage-core.
---

# Evaluate Route File: Causal

## What This Stage Protects
- Causal claim boundary: claims stay within the identification assumptions, estimand, target population, and treatment variation actually justified by the analysis contract and upstream pipeline.
- Identification strategy integrity through evaluation: the locked strategy (selection-on-observables, IV, DiD, RD, front-door, synthetic control) is evaluated as executed, not reinterpreted or relaxed.
- Separation between effect evidence and association: stability, predictability, and validity verdicts enforce the distinction between "the intervention caused Y" and "X and Y co-occurred."
- Sensitivity-to-unmeasured-confounding accountability: the evaluation quantifies how strong an unmeasured confounder would need to be to explain away the result, rather than assuming conditional ignorability holds.
- Falsification suite adjudication: pre-specified falsification tests from the analysis contract are adjudicated here, not in analyze. Passing or failing the suite is an evaluation verdict, not an analysis output.
- Positivity and overlap verdict finality: whether positivity violations observed in analyze are fatal to the causal claim is determined here.
- Average-effect interpretation: causal estimates are average effects over the locked population and estimand, not deterministic individual responses.

## What This Stage Prohibits
- Re-running the causal estimator, refitting nuisance models, re-matching, re-weighting, or re-trimming.
- Switching or relaxing the identification strategy after seeing evaluation results.
- Widening the estimand (e.g., upgrading ATT to ATE) or the target population after seeing results.
- Post-hoc falsification tests not in the analysis contract's pre-specified falsification plan.
- Post-hoc subgroup searches for heterogeneous treatment effects to rescue a failing claim.
- Treating sensitivity analysis as a tuning exercise: adjusting Gamma, bias parameters, or E-value thresholds to manufacture robustness.
- Interpreting a narrow confidence interval as evidence of causal identification: precision is not validity.
- Dismissing judgment-call perturbations (e.g., alternative adjustment sets, alternative overlap rules) as less important than sampling perturbations.
- Converting "conditionally stable" or "unstable" stability verdicts into "stable" without new evidence from upstream.
- Generating causal language beyond what the identification strategy licenses: no "X causes Y" when the design supports only "X is associated with Y conditional on measured covariates."
- Packaging findings for an audience, recommending policy actions, or framing results for stakeholders.

## What This Stage Defers
- Audience framing, narrative structure, and communication format.
- Policy or action recommendations based on the causal estimate.
- Whether and how to communicate claims that survived with caveats versus claims that did not survive.
- Visual presentation of causal results (e.g., forest plots, coefficient plots, DAG annotations).
- Any determination about what the findings mean for future research, interventions, or decisions.

## What Triggers Backtracking In This Stage
- All claims fail stability: no causal claim survives perturbation across alternative adjustment sets, alternative estimators, overlap rules, and challengers. Return to `analyze` to revise the perturbation plan or contract, or to `protocol` if the validation logic is wrong.
- Sensitivity analysis reveals that a weak unmeasured confounder (low E-value, low Gamma-bound, or low robustness value) would explain the entire effect. Return to `analyze` if a different specification might survive, or to `formulate` plus `protocol` if the question is unanswerable with observational data.
- Falsification suite fails: negative control outcomes show effects, placebo treatments show effects, or pre-trend tests reject. Return to `analyze` if execution was sound but identification is broken, or to `protocol` if the falsification plan was mis-specified.
- Positivity violations are fatal: the analysis population excludes so many units that the estimand no longer corresponds to the approved target population, and no overlap rule rescues a meaningful causal quantity. Return to `analyze` or `protocol`.
- Predictability check contradicts the primary result: placebo or falsification reality check reveals the design cannot distinguish the treatment effect from artifacts. Return to `analyze` or `protocol`.
- Construct validity has drifted: the operationalized treatment or outcome no longer maps to the causal quantity the question asks about. Return to `formulate` plus `protocol`.
- Deviation impact from the analysis deviation register invalidates results. Return to `analyze` to re-execute with corrected contract.
- No claims survive evaluation at all. Return to `protocol` to reassess what causal claims are achievable, or to `formulate` if the question is unanswerable.

## Stability Checks
- Adjudicate every perturbation axis from the analysis contract: alternative adjustment sets (full DAG-implied vs. minimal sufficient vs. data-driven), alternative estimators (IPW vs. g-computation vs. doubly robust), overlap rule perturbation (different PS trimming thresholds, ATO vs. ATM vs. ATE weights), functional form perturbation, and subgroup stability if pre-specified.
- Adjudicate every challenger from the analysis contract, including challengers that used a different identification family when data permitted.
- For each axis and challenger, classify divergence from the primary as: same direction and qualitatively equivalent conclusion (acceptable variation), same direction but materially different magnitude (instability requiring caveat), or different direction or qualitative conclusion (instability requiring claim downgrade or backtracking).
- Weight judgment-call perturbation axes (alternative adjustment sets, alternative overlap rules, alternative functional forms) alongside data perturbation axes (bootstrap, jackknife). Judgment-call sensitivity often dominates total uncertainty in causal inference.
- Compute the range of point estimates across all specifications (primary + sensitivity + challengers). If the range spans zero or spans the minimally important effect size, flag as instability.
- Assess whether challenger divergence is structural (different identification strategy, different conclusion) or parametric (same strategy, same direction, different magnitude). Structural divergence is more threatening.
- Render per-claim stability verdicts: stable, conditionally stable, unstable.

## Predictability Checks
- The predictability reality check for causal routes is the falsification or placebo suite, not held-out prediction. Causal estimands do not have a held-out ground truth.
- Execute the protocol-specified falsification tests on actual data in the notebook: negative control outcomes (outcomes known not to be affected by treatment should show null effects), placebo treatments (treatments known to have no effect should produce null estimates), pre-trend tests (for DiD and event-study designs), predetermined-covariate balance tests (for RD designs), and any other protocol-specified falsification.
- For each falsification test, assess: does the test produce the expected null result, or does it show an effect that should not exist?
- A falsification test that shows an unexpected effect is evidence that the identification strategy may be confounded or that the design has a flaw the analysis did not detect.
- Adjudicate the falsification suite as a whole: does the suite pass, partially pass, or fail? A single failure in a battery of tests requires judgment about whether it reflects a narrow problem or a systemic identification failure.
- Render per-claim predictability verdicts: adequate (falsification suite passed), marginal (partial failures with plausible explanations), inadequate (falsification suite failed, identification strategy is suspect).

## Formal Validity Tools
- **E-values (VanderWeele & Ding 2017):** Compute the E-value for the point estimate and for the confidence interval bound closest to the null. The E-value states the minimum strength of association (on the risk ratio scale) that an unmeasured confounder would need to have with both treatment and outcome to explain away the observed effect. Report both values. A low E-value (e.g., below 2) means a weak confounder could explain the result. A high E-value (e.g., above 5) means a strong confounder would be needed.
- **Gamma-bounds / Rosenbaum bounds (Rosenbaum 2002):** For matched or stratified designs, compute the sensitivity parameter Gamma at which the conclusion would change. Report Gamma for the point estimate significance and for the confidence interval. Low Gamma (e.g., below 1.5) means the result is fragile to even small amounts of hidden bias.
- **Cinelli-Hazlett robustness values:** Compute the partial R-squared of the unmeasured confounder with treatment and with outcome that would be needed to explain away the effect. Compare these values against the partial R-squared of the strongest observed confounder. If a confounder with less explanatory power than an observed covariate could eliminate the effect, the result is fragile.
- **Negative control assessment:** For each negative control outcome and placebo treatment, assess whether the null result was obtained. Quantify the magnitude of any unexpected effect relative to the primary effect. A negative control effect that is a substantial fraction of the primary effect is a threat.
- **Falsification test adjudication:** For each pre-specified falsification test (pre-trends, McCrary, predetermined covariates, placebo), render: passed, marginal, or failed. Aggregate across the suite. A preponderance of failures signals identification breakdown.
- Apply formal tools on actual data in the notebook. Report numerical results. Do not substitute qualitative assertions for quantitative outputs.
- For each tool, state: what was tested, the numerical result, and what it implies for claim survival (defended, threatened, or fatal).

## Adversarial Review Guidance
- **Bias inversion for causal inference:** Assume the treatment has no causal effect. Reason backward: what specific unmeasured confounder, selection mechanism, measurement error, or reverse-causation pathway would produce the observed association? Assess the plausibility of each candidate explanation given the data-generating process, the DAG, the population, and the study design.
- **Confounding audit:** Enumerate the most plausible unmeasured confounders given domain knowledge. For each, assess: is it plausible that this variable is associated with both treatment and outcome? Could it explain the magnitude of the observed effect? Does the E-value or Gamma-bound analysis cover it?
- **Randomized-design audit:** If the design is randomized, inspect attrition and dropout by arm, adherence and crossover, unblinding risk, and baseline balance including missingness. If nonadherence or contamination is material, prefer ITT interpretation and document the limitation explicitly.
- **Post-treatment bias check:** Review whether any variable conditioned on in the analysis is plausibly affected by treatment. If so, assess whether the resulting bias could explain or inflate the effect estimate.
- **Interference and spillover audit:** If the analysis assumed SUTVA or bounded interference, assess whether violations could produce the observed result. Treatment of one unit affecting outcomes of another can inflate or mask true effects.
- **Treatment-version ambiguity:** Assess whether treatment as measured conflates distinct interventions with potentially different effects. If treatment versions are heterogeneous, the estimated effect is an average over versions that may not correspond to any single actionable intervention.
- **Construct validity for causal claims:** Does the operationalized treatment correspond to the intervention the question asks about? Does the operationalized outcome capture the effect the question targets? Drift in either direction means the causal estimate answers a different question than the one approved.
- **Expert falsification:** Present the real causal estimate alongside a plausible alternative estimate that could have emerged under a different but defensible identification strategy or adjustment set. Ask whether the real result makes more domain sense. If no domain expert is available, document the gap.

## Protected surface

Route overlays may narrow this stage's surface. They may not rewrite or remove fields from the protected surface declared in `references/core-principles.md` §4.8 (decision register, reconciliation table / chain, claim-critical helper set). A route-specific requirement that shrinks the decision register, breaks the reconciliation arithmetic, or removes a helper is rejected regardless of route-specific rationale.
