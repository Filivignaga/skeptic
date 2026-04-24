---
name: evaluate-exploratory
description: Stage-specific route file for the Skeptic evaluate stage for exploratory questions. Narrows the universal evaluate stage-core.
---

# Evaluate Route File: Exploratory

## What This Stage Protects
- Hypothesis-generating status of all surviving claims. Every claim that passes evaluation is a candidate pattern worth communicating, not a confirmed finding.
- Separation between pattern stability and pattern truth. A stable pattern is not necessarily real; an unstable pattern is not necessarily noise. Stability is one input to the survival verdict, not the verdict itself.
- Multi-view adjudication: stability verdicts must account for convergence and divergence across algorithms, parameters, encodings, and visual representations, not collapse to a single favored view.
- Perturbation breadth in stability adjudication: judgment-call axes (distance metric, encoding, scaling, dimensionality target) carry equal weight to data-perturbation axes (bootstrap, subgroup, resampling).
- The claim boundary as-narrowed from analyze. Exploratory claims may narrow further during evaluation. They may not widen.

## What This Stage Prohibits
- Treating stable exploratory patterns as confirmed evidence. Stability under perturbation increases confidence that a pattern is worth reporting; it does not confirm the pattern is real or generalizable.
- Using predictive, inferential, causal, or mechanistic language in evaluation verdicts. Exploratory claims remain hypothesis-generating regardless of how many checks they survive.
- Promoting a single clustering, embedding, anomaly set, or contrastive summary to "the answer" based on evaluation performance. If multiple views survive, they all survive. Selection of a winner is a confirmation move.
- Converting triangulation across methods into inferential evidence. Convergence across views strengthens the candidate pattern; it does not prove it.
- Re-executing analysis or fitting new models during evaluation. If new computation is needed, backtrack to analyze.
- Adding post-hoc evaluation checks after seeing results from Cycles B, C, or D. The evaluation plan is derived from upstream contracts in Cycle A and locked.
- Applying inferential tests (p-values, confidence intervals, significance tests) to exploratory outputs during evaluation. These belong to a different route.
- Cherry-picking perturbation axes or challengers that support a preferred pattern while dismissing those that do not.

## What This Stage Defers
- Whether candidate patterns merit confirmation through a separate confirmatory study or holdout design. That decision belongs to communicate or to a future project.
- Audience framing, narrative structure, or recommendations based on surviving patterns.
- Which visualization or representation best communicates surviving patterns. That is communicate's job.
- Whether the exploratory findings should seed a new inferential, predictive, or causal question. Evaluate renders verdicts; it does not design follow-up studies.

## What Triggers Backtracking In This Stage
- No candidate pattern survives stability adjudication: every pattern changes materially under reasonable perturbation across the analysis contract.
- The predictability reality check reveals that patterns are artifacts of a specific sample, parameter setting, or encoding rather than reproducible structure.
- Validity assessment reveals that surfaced patterns align with cleaning artifacts, batch structure, merge artifacts, or data-collection artifacts rather than genuine phenomena.
- Construct validity has drifted: the operationalized structure no longer captures the concept the approved question targeted.
- The claim boundary must widen for any pattern to be communicable. Widening is never allowed within evaluate.
- Deviations documented in the analyze deviation register compromised the search program to the point where outputs cannot be adjudicated.

## Stability Checks
- Adjudicate every perturbation axis from the analyze contract: alternative distance metrics, alternative cluster counts, alternative dimensionality targets, alternative algorithm families, alternative encodings and scaling, alternative random seeds, protocol-authorized noise perturbations, bootstrap and resampling stability, alternative anomaly thresholds, subgroup perturbation.
- For each axis, classify divergence as: convergent (qualitative conclusion and pattern identity preserved), parametric divergence (same pattern, different magnitude or boundary), or structural divergence (different pattern, different conclusion).
- Adjudicate every challenger from the analyze contract. Classify challenger disagreement as parametric (same direction, different detail) or structural (different structure entirely).
- Weight judgment-call perturbation axes (distance metric, encoding, scaling, dimensionality target) alongside data-perturbation axes (bootstrap, resampling, subgroup). Do not dismiss judgment-call sensitivity as secondary.
- For internal validity indices (WSS, Silhouette, Davies-Bouldin, Calinski-Harabasz, gap statistic, Rand index, adjusted Rand index): assess whether index values are consistent across perturbation axes. Inconsistent index behavior across views is a stability concern, not a tiebreaker for selecting the best view.
- For bootstrap, resampling, and seed stability: assess Jaccard index, Rand index, or adjusted Rand index distributions across iterations or seeds. High variance in assignment stability indicates cluster-level instability.
- For protocol-authorized noise perturbations: assess whether the candidate structure survives small injected disturbance or collapses into a different pattern.
- Per-claim stability verdict:
  - **stable**: pattern identity and qualitative conclusion preserved across all perturbation axes and challengers
  - **conditionally stable**: pattern preserved under most perturbations but sensitive to specific axes; caveats name the axes
  - **unstable**: pattern changes materially under reasonable perturbation; claim must be downgraded or killed

## Predictability Checks
- The protocol-specified reality check for exploratory routes is perturbation-based pattern persistence. Execute what protocol defined.
- If protocol specified bootstrap stability or resampling consistency as the reality check: verify that pattern identity persists across resampled datasets. This overlaps with Cycle B stability but uses the protocol-specified resampling scheme rather than the analyze perturbation plan.
- If protocol specified temporal or external corroboration: verify that the pattern appears in a temporally or structurally distinct subset authorized by protocol. Do not unseal data that protocol did not authorize for this stage.
- If protocol specified a different reality check: execute exactly what protocol specified.
- Assess whether the pattern reemerges in the reality-check scenario or collapses.
- Per-claim predictability verdict:
  - **adequate**: pattern reemerges under the protocol-specified reality check
  - **marginal**: pattern partially reemerges; some aspects hold, others weaken or disappear
  - **inadequate**: pattern does not reemerge; it is specific to the primary execution context

## Formal Validity Tools
- Alternative representation stability: re-examine primary patterns under structurally different representations (different DR method, different distance metric family, different encoding scheme). If the pattern only appears under one representation, document the dependency.
- Triangulation across methods: assess whether independent method families (clustering vs. DR vs. anomaly detection, if multiple were in the analyze contract) surface the same candidate structure. Convergence strengthens the pattern; divergence does not kill it but requires a caveat.
- Internal validity index cross-check: compare WSS/elbow behavior and CVI rankings across perturbation axes. If the "best" k or configuration shifts across axes, or if the elbow signal disappears under reasonable perturbation, the optimal structure is not robust.
- Artifact-alignment check: verify that surfaced patterns do not align with known data artifacts (batch boundaries, collection-date breaks, encoding artifacts, merge keys, missingness patterns). Cross-reference against the cleaning audit trail in 03_cleaning.md.
- Data-snooping assessment: review whether the search program in the analyze contract contained any path that inadvertently used the same data for search and validation. If the perturbation plan reused training data without resampling, flag the circularity.

## Method Addendum

### PCA and Dimensionality Reduction
- Check whether the reduced representation remains interpretable across the authorized perturbations in the analyze contract.
- If variance-explained, scree, or loading structure shifts materially under reasonable scaling or encoding changes, record that as dimensionality-reduction sensitivity.
- If the pattern only appears after refitting a new basis for each perturbation, treat that as a dependency on refit-specific orientation rather than a robust structure.

### Clustering
- Compare cluster count stability with WSS/elbow behavior, not just with silhouette-style CVIs.
- If Rand index or adjusted Rand index varies sharply across seeds, resamples, or metric choices, treat the partition as unstable even if one run looks good.
- If K moves materially across reasonable perturbations, the claimed structure is conditional at best and may need narrowing or downgrading.

## Adversarial Review Guidance
- Bias inversion for exploratory routes: assume the primary pattern is an artifact. Reason backward to identify what systematic feature of the data pipeline (encoding choice, scaling method, distance metric, dimensionality reduction, imputation strategy, or data-collection process) could produce the observed pattern even if no genuine structure exists. Assess plausibility of each candidate explanation.
- Construct validity check: does the operationalized structure (clusters, anomaly scores, embeddings, contrastive summaries) still capture the concept the approved question targeted? Did the measurement chain from formulate through analyze hold together, or did method choices reshape what "structure" means in ways that diverge from the original question?
- Overreading check: for each surviving pattern, state the minimal factual claim the evidence supports. Then state the maximum interpretation someone might draw. The gap between the two is the overreading risk. Caveats must close that gap by bounding the claim to what the evidence licenses.
- Cherry-picking audit: verify that the evaluation considered all perturbation axes and challengers from the analyze contract, not just those that confirmed the primary pattern. If any axis or challenger was excluded from adjudication, document why and carry the gap as a caveat.
- Expert falsification: present the primary pattern alongside one plausible alternative pattern that could emerge under a different but defensible analytical path. Ask whether domain knowledge favors one over the other. If no domain expert is available, document the gap and carry it as a limitation.
