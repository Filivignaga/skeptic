---
name: evaluate-inferential
description: Stage-specific route file for the Skeptic evaluate stage for inferential questions. Narrows the universal evaluate stage-core.
---

# Evaluate Route File: Inferential

## What This Stage Protects
- Per-claim survival verdicts grounded in the estimand-estimator-estimate alignment locked in analyze.
- The claim boundary: generalize only to the defined target population under stated assumptions. No causal language. No predictive deployment claims. No extrapolation beyond the approved frame.
- Stability verdicts that reflect total uncertainty, including judgment-call perturbation axes (specification, adjustment set, weighting, missing-data handling) weighted alongside sampling perturbation axes.
- Predictability verdicts anchored in resampling consistency or bootstrap stability, not held-out prediction performance.
- Uncertainty calibration integrity: whether intervals and standard errors honestly reflect the data-generating structure (clustering, stratification, repeated measures, weights).
- Dependence-structure fidelity through evaluation: the variance procedure and its assumptions survive scrutiny, not just the point estimate.
- Interpretation integrity: the sign, magnitude, interval, and p-value are read on the scientific scale, not treated as standalone significance symbols.

## What This Stage Prohibits
- Causal language in any verdict, caveat, or handoff: "effect of," "impact of," "due to," "caused by" are forbidden. Inferential claims estimate population quantities with uncertainty. They do not establish causes.
- Re-executing analysis: no refitting, no new specifications, no alternative estimators. Evaluate adjudicates locked outputs.
- Widening the claim boundary: if a claim requires broader generalization to survive, it does not survive.
- Treating significance as a survival criterion: a nonsignificant result is not grounds for "did not survive." A significant result is not grounds for automatic "survived." Survival depends on stability, predictability, and validity, not p-values.
- Treating all-challengers-disagree as automatic backtracking: challenger disagreement is a finding that informs the stability verdict, not a mechanical trigger.
- Post-hoc subgroup evaluation not pre-specified in the analysis contract.
- Substituting held-out prediction performance for the protocol-specified reality check. Inferential predictability is resampling consistency or bootstrap stability unless protocol explicitly specified otherwise.
- Generating new claims beyond what the analysis contract was designed to support.
- Audience framing, narrative shaping, or recommendations in any cycle or handoff section.
- Treating a confidence interval crossing zero as automatic failure without checking whether the magnitude still matters on the scientific scale.
- Treating a very large sample size as a substitute for substantive importance.

## What This Stage Defers
- Audience framing of survived claims.
- Communication packaging, narrative structure, and presentation choices.
- Action recommendations or policy implications.
- Whether the finding is practically important (communicate may contextualize; evaluate only adjudicates survival).

## What Triggers Backtracking In This Stage
- All claims fail stability because the primary estimate shifts materially under every perturbation axis and challenger, leaving no defensible point within the claim boundary. Return to analyze to revise the perturbation plan or contract, or to protocol if validation logic is wrong.
- Resampling consistency or bootstrap stability check contradicts the primary result: the estimate does not reemerge under resampling, or bootstrap intervals are radically different from analytic intervals. Return to analyze if execution was sound, or to protocol if the reality check was mis-specified.
- A fatal validity threat: unmeasured confounding, selection bias, or representativeness failure plausibly explains the entire result, and the threat cannot be bounded. Return to formulate plus protocol if the question is unanswerable with this data, or to analyze if a different specification might survive.
- The variance procedure is discovered to be incoherent with the actual dependence structure during evaluation (clustering, stratification, or weighting violated). Return to analyze.
- Deviation impact from the analyze deviation register materially compromised the analysis. Return to analyze for corrected execution.
- No claims survive at all. Return to protocol to reassess achievable claims, or to formulate if the question is unanswerable.
- The claim boundary must widen to produce any meaningful communication. Return to formulate plus protocol.

## Stability Checks
- Adjudicate every perturbation axis from the analysis contract: alternative specifications, alternative adjustment sets, alternative variance estimators, alternative weighting, alternative missing-data handling, alternative distributional assumptions, alternative estimand boundaries, and bootstrap or resampling variants.
- Adjudicate every challenger from the analysis contract.
- For each axis and challenger, compute direction and magnitude of divergence from the primary estimate. Classify whether the qualitative conclusion changes and whether the claim boundary would need narrowing.
- Weight judgment-call perturbation axes (specification choice, covariate selection, weighting recipe, missing-data strategy) alongside sampling perturbation axes. Do not dismiss judgment-call sensitivity as less important.
- Apply the convergence/divergence framework:
  - Convergent: primary and alternatives agree in direction, magnitude, and qualitative conclusion. Strengthens the claim.
  - Divergent-parametric: same direction, different magnitude. Requires calibration of how sensitive the estimate is to that axis. Caveat if the magnitude shift is large enough to matter substantively.
  - Divergent-structural: different method or specification produces a different qualitative conclusion. Diagnose whether divergence reflects genuine instability, a known method limitation, or an execution artifact.
- Render per-claim stability verdicts: stable, conditionally stable, unstable.
- When the variance procedure changes materially across perturbation axes (e.g., sandwich SE doubles under an alternative specification), flag this as a stability concern independent of the point estimate.

## Predictability Checks
- The default inferential reality check is resampling consistency: bootstrap the full estimation procedure (point estimate plus variance estimate) and assess whether the primary result reemerges.
- If protocol specified an alternative reality check (e.g., split-half replication, temporal replication, external corroboration), use that instead.
- Compare bootstrap confidence intervals against analytic confidence intervals. Material disagreement signals distributional-assumption failure or small-sample instability.
- Assess bootstrap coverage: if the primary point estimate falls outside the bootstrap percentile interval, or the bootstrap interval is drastically wider or narrower than the analytic interval, the predictability verdict is marginal at best.
- For weighted analyses, bootstrap the weight-adjusted estimator. Effective sample size compression under resampling is a predictability concern.
- For clustered or stratified designs, bootstrap at the cluster or stratum level, not the individual level. Mismatched resampling units invalidate the check.
- Render per-claim predictability verdicts: adequate, marginal, inadequate.

## Interpretation Sanity Checks

### Direction and magnitude
- Compare the primary estimate against the examine-stage expectation. If the sign or direction reverses, explain why or downgrade the claim.
- Translate the effect size into human-relevant units when possible.
- If the magnitude is tiny relative to the decision context, say that directly instead of hiding behind significance language.

### Null-model and interval reading
- State whether the estimate is meaningfully separated from the null on the scientific scale.
- Do not convert a confidence interval crossing zero into a blanket rejection of the result. Evaluate the magnitude, uncertainty, and decision context together.
- If bootstrap and analytic intervals disagree materially, treat that as a stability or assumption problem, not just a formatting mismatch.

### Sample size and error balance
- If the analyzed sample is very large, ask whether the effect is practically meaningful before elevating the claim.
- Type I and Type II error tradeoffs are context inputs, not verdicts. Use them to calibrate interpretation, not to override evidence.

## Formal Validity Tools
- Specification sensitivity assessment: systematically assess how the estimate changes across the alternative specifications from the perturbation plan. Produce a specification curve or equivalent summary showing the distribution of estimates across defensible specifications. Identify whether the primary estimate is central, extreme, or an outlier within the specification space.
- Uncertainty calibration assessment: compare nominal coverage of confidence or credible intervals against bootstrap coverage or simulation-based coverage. If nominal 95% intervals achieve substantially less than 95% bootstrap coverage, the uncertainty is underestimated. Flag as a validity threat.
- Effective sample size audit: for weighted, clustered, or stratified analyses, compute the effective sample size. If the effective n is drastically lower than the nominal n, assess whether the primary inference is trustworthy at that effective sample size. Small effective n with large nominal n is a representativeness warning.
- Design-effect assessment: compute the design effect for clustering and stratification. If the design effect is large (substantially above 1), verify that the variance procedure fully accounts for it. Residual design effect after variance adjustment is a validity threat.
- Influence diagnostics: identify observations or clusters with disproportionate influence on the primary estimate. If a small number of units drive the result, assess whether the claim generalizes to the target population or is an artifact of those units.
- Confounder-control review: list the candidate confounders that were available upstream, verify the adjustment strategy matches the design, and confirm that post-treatment variables or colliders were not treated as controls. If the confounder story is incomplete, narrow the claim boundary or document the limitation explicitly.

## Adversarial Review Guidance
- Bias inversion for inferential claims: assume the estimated population quantity is wrong. Reason backward to identify what systematic error would produce the observed result. Prioritize these candidate errors:
  - Selection bias: the analyzed sample is not representative of the target population in a way that systematically shifts the estimate.
  - Nonresponse or attrition bias: missing units differ systematically from observed units on the quantity of interest.
  - Measurement error: the operationalized variable does not capture the intended concept, or measurement error is differential across groups.
  - Confounding in the association (without causal language): an unmeasured variable associated with both the exposure and outcome variable inflates or deflates the estimated relationship.
  - Survivorship bias: units in the sample survived a selection process correlated with the quantity of interest.
  - Ecological fallacy: group-level association does not hold at the individual level (when the estimand is individual-level but data is aggregated).
- For each candidate error, assess plausibility given the data-generating process, sampling design, and upstream audit trail. Do not speculate without grounding.
- Construct validity check: verify that the operationalized measure from formulate still captures the intended concept after the full pipeline. Trace the measurement chain from the approved question through cleaning, examination, and analysis. Identify where drift could have occurred.
- Expert falsification: present the primary result alongside a plausible alternative that could have emerged under a different but defensible analytical path. Ask whether the primary makes more domain sense. If no expert is available, document the gap and state what expert input would resolve.
- Representativeness review: verify that the final analyzed sample still maps to the target population after all exclusions, cleaning, weighting, and missing-data handling. If the effective population drifted from the approved target, the claim boundary must narrow or the claim does not survive.
- Practical-significance review: determine whether the effect size is large enough to matter in the actual decision context, not merely large enough to reject the null.
