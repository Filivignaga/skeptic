---
name: evaluate-descriptive
description: Stage-specific route file for the DSLC evaluate stage for descriptive questions. Narrows the universal evaluate stage-core.
---

# Evaluate Route File: Descriptive

## What This Stage Protects
- Denominator integrity under evaluation: the denominator audited in `analyze` remains the denominator used in all evaluation checks. No silent denominator switching during adjudication.
- Reporting-frame fidelity: the who, where, and when locked in the contract remain fixed during evaluation. Evaluation does not test the result on a different frame.
- Description-explanation boundary: no evaluation verdict, caveat, or limitation uses driver, effect, predictive, causal, or mechanistic language. Stability concerns are described as sensitivity to analytic choices, not as evidence for or against a causal mechanism.
- Aggregation honesty: evaluation verifies that aggregate summaries do not conceal subgroup structure that reverses or materially changes the headline description.
- Claim boundary as-narrowed from analyze: evaluation may narrow further but never widen.
- Measurement scope: evaluation adjudicates counts, rates, distributions, cross-tabs, standardized summaries, and descriptive graphics. It does not adjudicate model parameters, effect sizes, prediction accuracy, or causal estimates.

## What This Stage Prohibits
- Causal, explanatory, predictive, or mechanistic language in any verdict, caveat, limitation, or handoff text.
- Re-interpreting sensitivity divergence as evidence for or against a causal mechanism.
- Treating aggregation instability (Simpson's Paradox or similar) as a causal finding. It is a descriptive finding about the data structure.
- Significance testing, p-values, or inferential language in evaluation verdicts. Confidence intervals appear only as precision measures.
- Widening the claim boundary to make a claim survive.
- Re-executing analysis or fitting new models. Evaluation adjudicates locked outputs from `analyze`.
- Inventing post-hoc subgroups, aggregation windows, or denominator definitions not in the analysis contract.
- Ecological inference from aggregate results unless the contract explicitly targets group-level quantities.
- Framing evaluation verdicts for an audience. That is `communicate`.

## What This Stage Defers
- Audience framing, narrative structure, visualization choices for communication, and recommendation generation.
- Action items or policy implications.
- Any decision about how to present surviving claims to a specific audience.
- All packaging decisions that belong to `communicate`.

## What Triggers Backtracking In This Stage
- All claims fail stability because headline summaries change materially under every perturbation axis in the analysis contract. Return to `analyze` to revise the perturbation plan or contract, or to `protocol` if validation logic was mis-specified.
- Coverage check fails materially: refreshed extract or external corroboration contradicts the primary description beyond what acknowledged gaps explain. Return to `analyze` if execution was sound but the description does not match the reality check, or to `protocol` if the reality check itself was mis-specified.
- Denominator integrity collapses under alternative definitions: every reasonable alternative denominator changes the qualitative conclusion. Return to `analyze` to re-audit denominators, or to `protocol` if the denominator specification was fundamentally wrong.
- Simpson's Paradox reverses the headline description and no defensible aggregation level resolves the contradiction. Return to `analyze` to re-examine subgroup structure, or to `protocol` to reassess whether a single headline summary is achievable.
- Construct validity drift: the operationalized measure no longer captures the intended concept after the full pipeline. Return to `formulate` plus `protocol`.
- No claims survive evaluation. Return to `protocol` to reassess what claims are achievable, or to `formulate` if the question is unanswerable with this data.
- Claim boundary must widen to produce any meaningful communication. Return to `formulate` plus `protocol`.

## Stability Checks
Stability for descriptive questions means: the headline description does not change qualitatively under reasonable alternative analytic choices that the analysis contract pre-specified.

Perturbation axes that matter most for descriptive routes, in priority order:

1. **Alternative denominators.** Switch the population base (total population vs. population at risk vs. person-time; census vs. registry count). If the qualitative conclusion reverses or materially shifts, the claim is denominator-dependent and requires a caveat or downgrade.
2. **Alternative subgroup definitions.** Shift category boundaries (different age groupings, different geographic units, different case definitions). If subgroup results contradict the aggregate after re-categorization, the description is aggregation-dependent.
3. **Alternative aggregation windows.** Change temporal or spatial aggregation (monthly vs. quarterly vs. annual; county vs. region). If the headline changes, the description is window-dependent.
4. **Alternative standardization reference populations.** Use a different standard population. If the standardized summary changes qualitatively, the description is reference-dependent.
5. **Alternative missing-data handling.** Compare complete-case, simple imputation, and worst-case bounds. If conclusions diverge across these, missingness is a material threat.
6. **Alternative binning.** Different bin widths or cut-points for continuous variables. If distribution shape or summary changes materially, binning is a material choice.
7. **Judgment-call perturbations.** Alternative outcome definitions, inclusion/exclusion boundary shifts, or other analytic decisions documented in the analysis contract. Weight these alongside data perturbations, not below them.

Instability means the qualitative headline description changes -- not that point estimates shift by a small amount. Small numeric shifts with preserved qualitative conclusions are acceptable variation, not instability. Document the magnitude of every shift; adjudicate the qualitative conclusion change.

## Predictability Checks
Predictability for descriptive questions is NOT held-out prediction performance. It is a coverage and reproducibility reality check that verifies the description reflects what is actually present in the data or reporting frame.

The protocol-specified reality check for descriptive routes typically uses one or more of:

1. **Coverage check.** Compare the reporting frame claimed in the contract against the actual data coverage achieved. If coverage gaps exceed the protocol-specified coverage threshold, the description is incomplete. Document which subpopulations, time periods, or geographic units are missing and their magnitude.
2. **Denominator integrity check.** Verify that numerator-denominator alignment holds under alternative denominator sources. If alignment breaks, the rates or proportions are unreliable.
3. **Refreshed-extract comparison.** When a refreshed extract is available (later data pull, updated registry), compare primary results against the refreshed data. If the description changes materially, the original description was time-sensitive and the claim needs temporal scoping.
4. **External corroboration.** When an independent source covers the same reporting frame, compare headline summaries. Material disagreement without a protocol-approved explanation indicates a measurement or coverage problem.
5. **Aggregation stability check.** Verify that the headline summary holds across defensible aggregation levels. If it reverses at a finer or coarser level, the single-level summary is misleading.

Adequate: the description reemerges on the reality-check data or procedure, with no material shift. Marginal: partial replication -- some components hold, others shift. Inadequate: the description fails to reemerge or coverage is below threshold.

## Formal Validity Tools
These are the route-specific formal tools for Cycle D Phase 1. For descriptive routes:

1. **Aggregation stability analysis.** Compute headline summaries at multiple defensible aggregation levels (total, by major subgroup, by finer subgroup). Document whether the qualitative conclusion holds, reverses, or changes materially across levels. This is the primary formal tool for descriptive routes.
2. **Denominator integrity under alternative definitions.** Recompute key rates and proportions using each alternative denominator from the analysis contract. Document direction and magnitude of change. Flag any alternative where the qualitative conclusion reverses.
3. **Simpson's Paradox check.** For every cross-tabulation in the primary results, verify that the aggregate direction holds within each subgroup. Document any reversal. A reversal is not a causal finding -- it is a structural feature of the data that the description must acknowledge.
4. **Standardization sensitivity.** If standardized summaries were produced, recompute using each alternative reference population from the analysis contract. Document whether the standardized comparison changes qualitatively.
5. **Completeness audit.** Verify that the final coverage matches or exceeds the coverage threshold from the protocol. Document the gap if it does not.

Execute each applicable tool on actual data in the notebook. For each tool, document: what was tested, what the output was, and what it implies for claim survival.

## Adversarial Review Guidance
This is the route-specific guidance for Cycle D Phase 2.

**Bias inversion for descriptive questions:** Assume the headline description is wrong. Reason backward to identify what systematic error would produce the observed description from data that actually looks different. Plausible candidate errors for descriptive routes include:

- Selection bias: the data captures a non-representative subset of the reporting frame, and the description reflects the subset, not the frame.
- Denominator error: the denominator undercounts or overcounts a subpopulation, inflating or deflating rates for that group.
- Hidden filtering: upstream cleaning or pre-aggregation removed records in a pattern that changes the description (e.g., disproportionately removing outlier subgroups).
- Measurement mismatch: the variable does not measure what the contract assumed, so the counts or distributions describe the wrong thing.
- Survivorship bias: only records that survived a process are present, and the description is about the survivors, not the full population.
- Temporal mismatch: numerator events and denominator population counts refer to different time windows, distorting rates.
- Aggregation artifact: the headline summary is an artifact of the aggregation level chosen and would reverse at a different level.

For each candidate error, assess plausibility given the data, design, and upstream audit trail. Document whether each is ruled out, plausible but unlikely, or plausible and concerning.

**Expert falsification for descriptive questions:** Present the headline description alongside a plausible alternative description that could have emerged under a different but defensible set of analytic choices (different denominator, different aggregation level, different subgroup boundaries). Ask whether the real description makes more domain sense. If no domain expert is available, document the gap explicitly. The alternative description must come from actual sensitivity or challenger outputs in the analysis notebook, not from hypothetical scenarios.
