---
name: analyze-causal
description: Stage-specific route file for the Skeptic analyze stage for causal questions. Narrows the universal analyze stage-core.
---

# Analyze Route File: Causal

## What This Stage Protects
- Estimand integrity: the locked estimand (ATE, ATT, ATU, CATE, LATE, or another well-defined causal quantity) matches the approved question, target population, and treatment definition.
- Identification strategy coherence: the locked strategy (selection-on-observables, IV, DiD, RD, front-door, synthetic control) remains internally consistent throughout execution. Adjustment set, exclusion restrictions, parallel trends assumption, or running variable specification cannot drift.
- Treatment-outcome temporal ordering: all adjustment, weighting, and matching respect pre-treatment and post-treatment separation.
- Overlap and positivity within the analysis population: the locked overlap rule is applied as specified. Changing the rule after seeing results changes the population of inference.
- Causal claim boundary: the analysis cannot produce claims beyond what the identification strategy licenses. Selection-on-observables claims "conditional on measured covariates," not "no confounding."
- Falsification suite fidelity: pre-specified falsification tests execute as locked and are reported regardless of outcome.

## What This Stage Prohibits
- Post-treatment adjustment: conditioning on variables caused by or occurring after treatment when estimating total effects.
- Collider conditioning: adjusting for a collider that opens blocked backdoor paths.
- Post-hoc identification strategy switching after seeing primary results.
- Fishing for heterogeneous treatment effects: data-driven subgroup searches to find where effects are largest. Heterogeneity analysis must be pre-specified.
- Adjusting the overlap rule after seeing results: changing the PS trimming threshold or switching from ATE to ATT to rescue a failing analysis.
- Self-revision based on result quality.
- Sensitivity analysis parameter tuning to make results look robust.
- Conditioning on instruments in outcome models for IV designs.
- Proceeding under SUTVA when interference between units exists and the contract does not account for it.

## What This Stage Defers
- Whether the effect estimate is meaningful or important.
- Whether sensitivity analysis results constitute instability.
- Whether challenger divergence invalidates the primary result.
- Whether positivity violations are fatal to the claim.
- Whether the falsification suite passed.
- Whether the identification strategy was adequate.
- Final claim-scope determination.

## What Triggers Backtracking In This Stage
- No defensible identification strategy can be locked within upstream constraints.
- All pre-approved fallback estimators also fail assumption verification.
- Positivity collapses: no overlap rule rescues a viable analysis population.
- Treatment-timing alignment fails on actual data.
- Confounder balance cannot be achieved and no fallback addresses it.
- Cleaned data has structural problems: missing treatment variation, degenerate propensity scores at 0 or 1 for entire subpopulations.
- Identification test fails: IV first-stage F below threshold, DiD pre-trends rejected, RD manipulation test fails.
- All challengers produce materially different results AND all falsification tests fail. This combination suggests the identification strategy is broken.
- Contract required protocol-forbidden data or violated visibility rules.

## Cycle B: Assumption Checks

- Positivity and overlap: every covariate stratum has non-zero probability of each treatment level. Propensity score distribution bounded away from 0 and 1 within the locked threshold.
- Confounder balance: adjustment set achieves adequate balance between treatment groups. Standardized mean differences, variance ratios, or KS statistics after weighting or matching.
- Treatment-timing alignment: treatment assignment precedes outcome measurement on actual data. No reverse causation.
- Identification viability: strategy-specific diagnostics. IV: first-stage F-statistic. DiD: pre-trends test or honest bounds. RD: McCrary density test and continuity of predetermined covariates. Selection-on-observables: propensity model specification tests.
- No-interference and SUTVA check: treatment of one unit does not affect outcomes of others, or interference is bounded within the design.
- Consistency and treatment-version check: treatment as measured corresponds to a well-defined intervention with no conflated versions.

## Randomized Design Additions
- If the design is randomized, check baseline balance by arm on covariates and missingness before interpreting any effect estimate.
- Check attrition and dropout by arm. Differential loss to follow-up is a design problem, not a nuisance to ignore.
- Check adherence, contamination, crossover, and treatment-version ambiguity. If assignment and received treatment differ materially, the estimand may need to be ITT.
- Prefer an intent-to-treat estimand when nonadherence or crossover is present and the contract supports it. Do not quietly analyze a different intervention than the one that was randomized.
- Average-effect warning: even a clean randomized design identifies an average effect over the locked population, not a deterministic individual response.

## Perturbation Axes

- Alternative adjustment sets: full DAG-implied set vs. minimal sufficient set vs. data-driven set.
- Alternative identification strategies: if data permit, a challenger might use a different identification family.
- Sensitivity to unmeasured confounding: E-value computation, Rosenbaum bounds, bias-adjusted estimates.
- Alternative estimators: IPW vs. g-computation vs. doubly robust (AIPW or TMLE).
- Overlap rule perturbation: different PS trimming thresholds; ATO vs. ATM weights vs. standard ATE weights.
- Functional form perturbation: linear vs. flexible nuisance models; different covariate transformations.
- Subgroup stability: effect estimates within pre-specified subgroups, if heterogeneity analysis is in the contract.

## Route-Specific Contract Fields

| Field | Description | Required |
|-------|-------------|----------|
| Estimand | ATE, ATT, ATU, CATE, LATE, or other well-defined causal quantity with target population | Yes |
| Identification strategy | Selection-on-observables, IV, DiD, RD, front-door, synthetic control, or other defensible strategy with key identifying assumptions named | Yes |
| Adjustment set | Exact list of covariates with DAG-based or domain-based justification; variables excluded despite being available must be flagged | Yes |
| Nuisance model specification | Treatment model (propensity score) and outcome model: variables, functional form, estimation method | Yes for DR and TMLE; treatment model for IPW; outcome model for g-computation |
| Overlap rule | PS trimming threshold, weight truncation rule, or alternative estimand; what happens to units outside the overlap region | Yes |
| Falsification plan | Negative control outcomes, placebo treatments, pre-trend tests, or other falsification checks with criteria for what a failure looks like | Yes |
| Sensitivity analysis method | E-value, Rosenbaum bounds, bias formula, or other quantitative sensitivity to unmeasured confounding | Yes |
| Heterogeneity specification | Whether and how treatment effect heterogeneity is examined: subgroups, method, multiplicity handling. "None" is valid | Yes |
| Interference handling | Whether SUTVA is assumed or interference is modeled | Yes |
| Event window | For time-based designs: pre-period, post-period, exposure window, outcome window | When DiD, event study, or survival designs |
| Cross-fitting specification | Number of folds, sample-splitting rule for nuisance estimation vs. effect estimation | When DML or cross-fitted AIPW or TMLE |

## Internal Execution Sequence

Cycle C (Primary Execution) follows this order:

1. Reproduce the analysis population: apply the locked overlap rule. Document excluded units and compare characteristics of included vs. excluded.
2. Fit nuisance models: treatment model (propensity score) and outcome model as specified. For cross-fitted designs, implement the sample-splitting scheme.
3. Compute balance diagnostics: after weighting or matching, report standardized mean differences and other balance measures. If balance degraded since Cycle B, flag as a deviation.
4. Estimate the causal effect: apply the locked estimator to produce the point estimate and confidence interval for the locked estimand.
5. Compute identification diagnostics: IV first-stage results; DiD event-study coefficients; RD bandwidth sensitivity and effective observations; selection-on-observables propensity score diagnostics.
6. Record computational diagnostics: convergence, optimization iterations, numerical warnings, effective sample size after weighting, extreme weight diagnostics, runtime.
7. Execute falsification suite: all pre-specified tests. Report results without interpretation.
8. Record all outputs: point estimate, CI, standard error, effective N, all diagnostics, all falsification results, random seeds, software versions.

## Protected surface

Route overlays may narrow this stage's surface. They may not rewrite or remove fields from the protected surface declared in `references/core-principles.md` §4.8 (decision register, reconciliation table / chain, claim-critical helper set). A route-specific requirement that shrinks the decision register, breaks the reconciliation arithmetic, or removes a helper is rejected regardless of route-specific rationale.
