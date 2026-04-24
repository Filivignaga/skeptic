---
name: analyze-descriptive
description: Stage-specific route file for the Skeptic analyze stage for descriptive questions. Narrows the universal analyze stage-core.
---

# Analyze Route File: Descriptive

## What This Stage Protects
- Denominator integrity: every count, rate, proportion, and cross-tab traces back to an audited denominator with consistent categories between numerator and denominator.
- Reporting-frame fidelity: the who, where, and when locked in the contract remain fixed throughout execution.
- Measurement scope: execution produces counts, rates, distributions, cross-tabs, standardized summaries, and descriptive graphics. Nothing else.
- Subgroup boundary fidelity: subgroup definitions execute exactly as locked in the contract.
- Aggregation honesty: aggregate summaries do not conceal subgroup structure that reverses or materially changes the headline description.
- Description-explanation boundary: no summary, label, or narrative uses driver, effect, predictive, causal, or mechanistic language.

## What This Stage Prohibits
- Causal, explanatory, predictive, or mechanistic language in any output or label.
- Confounder adjustment framed as confounding control. In a descriptive contract, adjustment means standardization to a reference population, not confounding control.
- Post-hoc subgroup invention. Subgroups must be pre-specified in the contract.
- Post-hoc analysis addition after seeing primary results.
- Interpreting sensitivity divergence as instability. Document divergence; `evaluate` adjudicates.
- Self-revision based on result quality. Execute, record, hand off.
- Ecological inference from aggregate results unless the contract explicitly targets group-level quantities.
- Significance testing or p-values. Confidence intervals for proportions or rates are admissible only when framed as precision measures, not inferential tools.

## What This Stage Defers
- Whether headline summaries are stable enough to carry claims.
- Whether denominator choice materially changes conclusions.
- Whether subgroup results contradict aggregate results (Simpson's Paradox adjudication).
- Whether standardization choice changes the story.
- Whether completeness is adequate for the reporting frame.
- Whether the claim boundary needs further narrowing.
- All result-quality judgments.

## What Triggers Backtracking In This Stage
- Denominator cannot be computed from visible artifacts.
- Reporting frame is narrower than the contract assumed.
- All pre-approved fallbacks also fail assumption checks in Cycle B.
- Hidden filtering or pre-aggregation discovered that makes "what is present" unclear.
- Subgroup taxonomy is impossible to execute on the actual data.
- Work starts requiring explanatory or causal logic to answer the question.
- A variable does not measure what the contract assumed.

## Cycle B: Assumption Checks

Verify before execution:

- Denominator integrity: denominator reconstructable from visible artifacts; numerator-denominator category alignment; alternative denominator sources available and aligned.
- Measurement scope validity: each variable measures what the contract assumes; value distributions consistent with claimed measurement.
- Reporting-frame coverage: actual data covers the reporting frame claimed in the contract; coverage gaps documented with magnitude.
- Subgroup boundary feasibility: each locked subgroup has sufficient observations; category definitions match the contract taxonomy.
- Standardization reference population availability: reference population exists and categories align with data categories.
- Missingness pattern: missingness rates for contract-critical fields are known; missing-data rule is executable.
- Temporal alignment: numerator events and denominator population counts refer to the same time window.

## Perturbation Axes

- Alternative denominators: switch population base (total population vs. population at risk vs. person-time; census vs. registry count).
- Alternative subgroup definitions: shift category boundaries (e.g., different age groupings).
- Alternative aggregation windows: change temporal aggregation (monthly vs. quarterly vs. annual).
- Alternative binning: different bin widths or cut-points for continuous variables.
- Alternative standardization reference populations: use a different standard population.
- Alternative missing-data handling: complete-case vs. simple imputation vs. worst-case bounds.
- Alternative outcome definitions: if the contract allows reasonable alternative case definitions, execute both.

## Route-Specific Contract Fields

| Field | Description | Required |
|-------|-------------|----------|
| Reporting frame | Exact who, where, when: target population, geographic scope, time window, inclusion and exclusion criteria | Yes |
| Denominator definition | Exact source, computation, and alignment rules; alternative denominators for perturbation | Yes |
| Subgroup taxonomy | Pre-specified subgroup definitions with category boundaries | Yes |
| Aggregation convention | Temporal and spatial aggregation units | Yes |
| Standardization specification | Reference population, method (direct or indirect), and what is being standardized over; "none" if not applicable | Yes |
| Binning specification | For continuous variables: bin widths, cut-points, and rationale | Route-dependent |
| Summary statistic set | Exact measures to produce: counts, rates, proportions, medians, percentiles, cross-tabs | Yes |
| Visualization grammar | Chart types, axis scales, reference lines, and display conventions | Yes |
| Coverage threshold | Minimum acceptable coverage for the reporting frame | Yes |

## Internal Execution Sequence

Cycle C (Primary Execution) follows this order:

1. Verify and compute denominators from visible artifacts. Confirm numerator-denominator alignment.
2. Compute raw counts: total and stratified by each subgroup dimension.
3. Compute rates and proportions using audited denominators.
4. Compute distributions for continuous variables using the locked binning specification.
5. Compute cross-tabulations. Document cell counts and marginals. Flag sparse cells.
6. Apply standardization if specified. Produce both crude and standardized results.
7. Produce summary graphics using the locked visualization grammar.
8. Document completeness and coverage: actual vs. claimed reporting frame.
