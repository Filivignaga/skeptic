---
name: analyze-inferential
description: Stage-specific route file for the Skeptic analyze stage for inferential questions. Narrows the universal analyze stage-core.
---

# Analyze Route File: Inferential

## What This Stage Protects
- Estimand-estimator-estimate alignment: the locked specification answers exactly the population question approved upstream.
- Variance procedure integrity: the variance estimator matches the data-generating structure (clustering, stratification, repeated measures, weights).
- Target population and frame fidelity: the contract does not silently redefine who the estimate generalizes to.
- Pre-specified multiplicity handling: correction method locked before execution, not chosen after seeing results.
- Dependence structure: clustering, stratification, repeated measures, and weighting honored in every computation.
- Inferential literacy: the contract makes the null model, distributional assumptions, confidence-interval interpretation, bootstrap role, and test-family choice explicit before execution.

## What This Stage Prohibits
- Post-hoc specification search (p-hacking): trying alternative specifications after seeing results and selecting the one that yields significance.
- Post-hoc subgroup carving: adding subgroup analyses not specified in the contract.
- Causal language: "effect of," "impact of," "due to" are forbidden. Inferential analysis estimates population quantities with uncertainty; it does not establish causal effects.
- Self-revision based on result quality: a nonsignificant or unexpected result is not grounds for contract amendment.
- Silent reweighting or re-stratification during execution.
- Selective reporting of perturbation results.
- Treating model diagnostics as pass/fail gates for result acceptability. Assumption checks in Cycle B gate the contract's viability, not the desirability of results.
- Choosing the test family, smoothing rule, or interpretation scale after seeing the estimate.
- Treating a tiny p-value as evidence of practical importance by itself.

## What This Stage Defers
- Result-quality adjudication: whether the estimate is precise enough or substantively meaningful.
- Stability verdict: whether perturbation divergence constitutes instability.
- Uncertainty calibration assessment: whether intervals have adequate coverage.
- Claim-scope decisions: whether the estimate supports the full claim boundary.
- External validity judgment.
- Multiplicity impact assessment.
- Model comparison verdict when challengers produce different results.
- Posterior predictive adequacy for Bayesian analyses.

## What Triggers Backtracking In This Stage
- All pre-approved estimators fail assumption verification with no viable fallback.
- Variance procedure is incoherent with the dependence structure discovered during execution.
- Estimand is unidentifiable from visible data.
- Weights are degenerate, extreme, or undefined for substantial subgroups.
- Sampling frame misalignment: actual data units do not match the target population assumed by the estimand.
- The question requires causal identification or predictive deployment logic.

## Cycle B: Assumption Checks

Mandatory checks for all inferential contracts:

- Sampling-frame alignment: units in cleaned data match the target population; no silent exclusions.
- Independence: residuals are not correlated across units, or dependence is correctly modeled.
- Normality of residuals: error distribution is approximately Gaussian, or method does not require it.
- Homoscedasticity: residual variance is constant across fitted values and key groups.
- Model specification: functional form captures the relationship; no omitted nonlinearities or interactions.

Conditional checks:

- Weight stability: when design or calibration weights are used. Check effective sample size and extreme-weight ratio.
- Random-effects normality: when mixed models are locked. Check Q-Q plot of BLUPs.
- Sphericity: when repeated measures with more than two levels.
- Working-correlation adequacy: when GEE is locked. Compare naive vs. robust SEs.
- Prior-data conflict: when Bayesian methods are locked. Run prior predictive checks.
- Strata and cluster adequacy: when stratified or cluster-based variance is planned. Minimum units per stratum; minimum clusters for sandwich estimator validity.

## Inferential Concepts and Appendix Guidance

### Distributions and null models
- Population distribution: the target quantity's distribution in the approved target population or frame.
- Empirical distribution: the observed distribution in the analyzed sample after cleaning and protocol restrictions.
- Sampling distribution: the distribution of an estimator across repeated samples or resamples under the locked design.
- Null model: the reference model used for hypothesis testing or calibration. It must be explicit before execution.
- P-values are tail probabilities under the null model, not effect sizes and not proofs.

### Confidence intervals and bootstrap logic
- Confidence intervals summarize uncertainty on the scientific scale, not just statistical significance.
- Bootstrapping approximates the locked estimation procedure under the visible data and protocol, not the entire world.
- If bootstrap and analytic intervals disagree materially, treat that as a signal about assumptions, not a formatting issue.
- A confidence interval crossing zero is not, by itself, a reason to discard the estimate when the estimand is meaningful and the uncertainty story is coherent.

### Practical significance and error types
- Report the estimate in human-relevant units when possible.
- Large samples can make trivial differences look decisive. If the magnitude is too small to matter, say so explicitly.
- Type I error is false positive risk. Type II error is false negative risk. Neither is a survival criterion by itself; they inform the locked alpha and power story.

### Test-family guidance
- Parametric tests belong when the locked model assumptions are defensible and the estimand matches the model.
- Non-parametric tests are for rank-based or distribution-light comparisons when the contract calls for them, not as a default replacement for all parametric work.
- Chi-square tests are for contingency-table structure and count comparisons when the expected-count conditions and independence assumptions are coherent.
- If the chosen test family is unclear, resolve it in protocol or formulate rather than improvising in analyze.

### Smoothing and structural dependence
- When the data are temporal, spatial, or sequential, the contract may lock a smoothing rule or dependence-aware model if that is the honest way to represent structure.
- State the smoothing choice explicitly: window, span, spline, loess, or none.
- Do not smooth just to make a noisy pattern look cleaner.

### Confounder-control checklist
- List candidate confounders before interpreting associations.
- State why each variable is included, excluded, or left as a design restriction.
- Separate design-stage control from model-stage control.
- Flag post-treatment variables and colliders; do not control them casually.
- If the confounding story is weak, the claim boundary should narrow before execution proceeds.

## Perturbation Axes

- Alternative model specifications: functional form, covariates included or excluded, interaction terms.
- Alternative adjustment sets: which covariates are adjusted for.
- Alternative variance estimators: model-based vs. sandwich or robust vs. bootstrap vs. design-based.
- Alternative weighting: weight construction or trimming.
- Alternative missing-data handling: complete-case vs. multiple imputation vs. inverse-probability weighting.
- Alternative distributional assumptions: error distribution or link function.
- Alternative estimand boundaries: subpopulation restrictions.
- Bootstrap and resampling: nonparametric bootstrap CIs vs. parametric CIs; permutation p-values vs. asymptotic p-values.

## Route-Specific Contract Fields

| Field | Description | Required |
|-------|-------------|----------|
| Estimand (five-attribute) | Population, variable or endpoint, intercurrent event strategy, population-level summary, treatment or exposure specification | Yes |
| Estimator | Specific statistical procedure targeting the estimand | Yes |
| Target population | Exact population to which results generalize | Yes |
| Significance level | Alpha level for hypothesis tests | When tests are used |
| Multiplicity correction | Method and scope: which tests are in the family, FWER vs. FDR, specific procedure | When multiple estimands or subgroups exist |
| Test family | Parametric, non-parametric, chi-square, or exact test family plus rationale | When hypothesis tests are used |
| Variance procedure | How standard errors and intervals are computed: model-based, sandwich, bootstrap, design-based, Bayesian posterior | Yes |
| Dependence structure specification | How clustering, stratification, repeated measures, or panel structure is handled | Yes |
| Weighting recipe | Design weights, calibration method, post-stratification variables, weight trimming rules | When weights are used |
| Degrees-of-freedom method | How df are computed for small-sample inference | When small n, mixed models, or GEE with few clusters |
| Smoothing rule | Optional temporal, spatial, or sequential smoothing choice and why it is warranted | When dependence is structural and smoothing is locked |
| Confounder-control plan | Candidate confounders, control strategy, and rationale for inclusion or exclusion | When associational analyses are locked |
| Prior specification | Prior distributions and hyperparameters | When Bayesian methods are locked |
| Intercurrent event handling | How protocol deviations, dropout, or missingness interact with the estimand | When intercurrent events are relevant |

## Internal Execution Sequence

Cycle C (Primary Execution) follows this order:

1. State the locked estimand, estimator, variance procedure, weighting, and dependence structure.
2. Construct the analysis dataset: apply any pre-specified subsetting, weighting, or variable derivation. Confirm the analysis dataset matches the target population.
3. Fit the primary model or estimator on visible data. Record all parameters, coefficients, convergence diagnostics.
4. Compute point estimates and intervals using the locked variance procedure. Record standard errors, confidence or credible intervals, test statistics, p-values if applicable.
5. Apply multiplicity correction if multiple estimands or subgroups are pre-specified.
6. Record the null-model reference, the test family, and the interpretation scale used for the estimate.
7. Run model diagnostics: residual plots, influence measures, goodness-of-fit statistics. These are execution completeness checks, not result-quality gates.
8. Record computational diagnostics: convergence status, iteration count, runtime, numerical warnings, effective sample size, effective number of parameters.
9. Record seeds and full parameter state for exact reproduction.
