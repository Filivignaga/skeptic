---
name: analyze-exploratory
description: Stage-specific route file for the Skeptic analyze stage for exploratory questions. Narrows the universal analyze stage-core.
---

# Analyze Route File: Exploratory

## What This Stage Protects
- Hypothesis-generating status of all outputs. Every output is a candidate pattern, not a confirmed structure.
- Multi-view fidelity: execution across multiple views, metrics, parameters, and algorithms preserves the spread of results rather than collapsing to one favored view.
- Perturbation breadth over depth: the contract explores stability across axes rather than optimizing a single configuration.
- Separation of execution outputs from quality judgments. Producing cluster labels, anomaly scores, embeddings, and contrastive summaries is execution. Deciding whether those patterns are real, stable, or actionable is `evaluate`'s job.

## What This Stage Prohibits
- Treating searched structure as confirmed evidence. No p-values, confidence intervals, inferential tests, or causal language on exploratory outputs.
- Optimizing for a single best clustering, embedding, or anomaly threshold. Selecting a winner among parameter settings is a confirmation move disguised as exploration.
- Post-hoc addition of search paths after seeing primary results.
- Predictive, inferential, causal, or mechanistic language to stabilize exploratory patterns.
- Collapsing sensitivity and challenger results into a single summary. Each perturbation axis and challenger must be reported separately.
- Self-revision based on result quality.

## What This Stage Defers
- Whether discovered patterns are stable enough to report.
- Whether internal validity indices indicate real structure.
- Whether pattern convergence across views constitutes triangulation.
- Whether the claim boundary should be narrowed or the route should backtrack.
- Which candidate patterns are worth communicating.

## What Triggers Backtracking In This Stage
- No viable exploratory specification exists within upstream constraints.
- All pre-approved fallbacks fail assumption checks in Cycle B.
- Cleaned data has structural problems (batch artifacts, merge artifacts, coding artifacts) that would dominate any exploratory search.
- The contract requires data or visibility not authorized by protocol.
- The search program cannot execute due to computational limits or data volume.
- The question cannot produce meaningful output without inferential, predictive, or causal claims.

## Cycle B: Assumption Checks

Verify before execution:

- Distance metric appropriateness: the chosen metric is valid for the data types and dimensionality present.
- Dimensionality vs. sample size ratio: whether the data is in a high-dimensional, low-sample-size regime where DR and clustering are prone to overfitting artifacts.
- Sparsity assessment: data density in the feature space; extreme sparsity causes distance concentration.
- Feature scale and type compatibility: features require standardization before distance computation; mixed-type data requires explicit handling.
- Multicollinearity and redundancy: high correlation among features inflates effective dimensionality without adding information.
- Method-geometry alignment: the chosen method's structural assumptions (linear vs. nonlinear, local vs. global preservation) match the data geometry.

## Perturbation Axes

- Alternative distance metrics: swap the primary metric for structurally different alternatives.
- Alternative numbers of clusters: vary k across a range around the primary.
- Alternative dimensionality targets: vary the number of retained components or dimensions.
- Alternative algorithm families: run structurally different methods (e.g., k-means vs. DBSCAN vs. hierarchical; PCA vs. UMAP vs. t-SNE).
- Alternative encodings and scaling: vary how categorical variables are encoded and how features are scaled.
- Alternative random seeds: rerun stochastic methods with different seeds to test initialization and numerical sensitivity.
- Small, protocol-authorized noise perturbations: inject low-magnitude jitter or measurement noise only when the protocol allows it, then re-run the same locked specification.
- Bootstrap and resampling stability: resample the data and re-run the primary specification.
- Alternative anomaly thresholds and contamination rates: vary the contamination parameter or score threshold.
- Subgroup perturbation: re-run on upstream-licensed subgroups to check whether structure holds within subpopulations.

## Representation Addendum

### Dimensionality Reduction
- For PCA-style dimensionality reduction, center and scale features when units are not already comparable.
- Inspect variance explained, scree plots, loadings, and reconstruction error before treating a reduced representation as useful.
- Keep the loading matrix fixed when comparing perturbations; if the apparent structure only appears after refitting a new basis, document that dependency explicitly.

### Clustering
- State the distance metric, scaling, and encoding choices before clustering. Metric choice is part of the specification, not a cosmetic detail.
- Use WSS or elbow-style diagnostics when they are meaningful for the chosen clustering family, and compare them with Silhouette, Davies-Bouldin, Calinski-Harabasz, and gap statistic where applicable.
- Use plain Rand index or adjusted Rand index when comparing cluster partitions across stochastic re-runs, perturbations, or alternative specifications.
- Treat the candidate number of clusters as a locked part of the contract: declare a plausible range up front, check whether any K is central and stable, and if the answer is not clear, report the range rather than pretending there is a unique best value.
- If cluster counts, assignments, or quality indices change materially under seed, noise, or metric perturbations, record that as sensitivity in the contract rather than collapsing it into a single winner.

## Route-Specific Contract Fields

| Field | Description | Required |
|-------|-------------|----------|
| Search method family | Primary unsupervised method: clustering, dimensionality reduction, anomaly detection, subgroup discovery, contrastive summary, or combination | Yes |
| Distance or similarity metric | Primary metric and justification for the data types present | Yes |
| Dimensionality target | Number of retained dimensions for DR, or statement that no DR is applied | When DR is in the method family |
| Cluster range | Range of k values or density parameters to explore | When clustering is in the method family |
| Anomaly detection method and threshold | Scoring method, contamination rate or threshold, and how the threshold was set | When anomaly detection is in the method family |
| Encoding and scaling specification | How categorical, binary, and continuous features are encoded and scaled | Yes |
| Internal validity metrics | Which CVIs will be computed (WSS, Silhouette, Davies-Bouldin, Calinski-Harabasz, gap statistic, Rand index, adjusted Rand index) | Yes |
| Seed perturbation plan | Number of stochastic re-runs, seed families or seed values, and which outputs will be compared | When the method is stochastic |
| Noise perturbation plan | Type, magnitude, and injection point of small, protocol-authorized noise or jitter perturbations | When protocol authorizes noise perturbation |
| Bootstrap and resampling plan | Number of iterations, resampling scheme, stability metric (Jaccard index, Rand index, adjusted Rand index) | Yes |

Note: the universal "accuracy metric" field becomes "internal validity metrics" for exploratory routes. The universal "estimand or target quantity" becomes "target structure" (the type of structure being searched for).

## Internal Execution Sequence

Cycle C (Primary Execution) follows this order:

1. State the locked contract: method family, metric, encoding, scaling, dimensionality target, cluster range or anomaly threshold.
2. Apply encoding and scaling per the contract specification.
3. If the contract includes dimensionality reduction: execute with the locked method and target. Record variance explained, reconstruction error, or other DR diagnostics.
4. If the contract includes clustering: execute the primary specification on the (optionally reduced) data. Record cluster assignments, internal validity metrics, and cluster-level summaries.
5. If the contract includes anomaly detection: execute the primary specification. Record anomaly scores, threshold application, flagged observations, and score distributions.
6. If the contract includes subgroup discovery or contrastive summaries: execute on upstream-licensed subgroup definitions.
7. If the contract includes seed or noise perturbations: re-run the locked specification under the approved seeds or noise settings and record the same diagnostics as the primary run.
8. Record all computational diagnostics: runtime, convergence, random seeds, numerical warnings.

Cycle D (Sensitivity and Challenger Execution) additionally:

- For each perturbation and challenger: record the same internal validity metrics, cluster assignments, anomaly scores, or embeddings as primary.
- For seed perturbations: compare the resulting assignments, embeddings, or scores against the primary run and note whether differences are numerical only or materially structural.
- For protocol-authorized noise perturbations: compare the same outputs and record whether the candidate structure survives small injected disturbance.
- Report comparison metrics (adjusted Rand index between primary and perturbed cluster assignments, Procrustes distance between primary and perturbed embeddings) without interpreting whether divergence constitutes instability.
- For bootstrap stability: report the distribution of stability metrics across iterations.
