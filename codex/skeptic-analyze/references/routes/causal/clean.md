---
name: clean-causal
description: Stage-specific route file for the Skeptic clean stage for causal questions. Narrows the universal clean stage-core.
---

# Clean Route File: Causal

## What This Stage Protects
- Treatment, outcome, and timing semantics.
- Pre-treatment versus post-treatment separation, observed treatment variation, analyzable population, and visible support.
- Cluster or spillover structure when interference is plausible.

## What This Stage Prohibits
- Using realized outcomes, future information, or post-treatment variables to decide how pre-treatment covariates are cleaned, imputed, or retained.
- Dropping or repairing records to improve apparent treated-versus-control comparability, balance, or overlap.
- Redefining treatment, treatment onset, outcome windows, eligibility, censoring, or exposure episodes except for clear measurement-fidelity fixes anchored in source semantics.
- Aggregating, deduplicating, or collapsing records when that could merge pre-treatment and post-treatment states or erase treatment-history structure.
- Resolving ambiguous variable roles as confounder, mediator, collider, instrument, or effect modifier inside `clean` unless the role is already fixed upstream and the action is purely semantic.

## What This Stage Defers
- The exact estimand, confounder set, effect-modifier handling, overlap thresholds, trimming, weighting, matching, regression adjustment, and identification-specific structures.
- Any derived variable whose validity depends on the exact identification strategy.

## What Triggers Backtracking In This Stage
- Treatment timing, outcome timing, or eligibility windows cannot be ordered defensibly from visible data.
- A variable needed as pre-treatment is only observed after treatment starts.
- Cleaning materially changes treated or control composition, treatment prevalence, or exposure support.
- Repeated records reveal longitudinal treatment history, clustering, or interference stronger than `protocol` allowed.
- Critical candidate confounders become unusable after cleaning.
- Resolving a cleaning issue would require choosing among competing estimands or identification strategies.
