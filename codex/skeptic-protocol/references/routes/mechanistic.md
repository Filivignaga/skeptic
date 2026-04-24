---
name: protocol-mechanistic
description: Stage-specific route file for the Skeptic protocol stage for mechanistic questions. Narrows the universal protocol stage-core.
---

# Protocol Route File: Mechanistic

## What This Stage Protects
- The claim boundary around mechanism rather than fit.
- Explicit structural assumptions, regime boundaries, identifiability risks, and falsification pressure.
- Clear separation between mechanistic claims and predictive or causal drift.

## What This Stage Prohibits
- Treating good fit alone as mechanism evidence.
- Letting later stages invent hidden states, proxy mechanisms, or structural claims that were not licensed upstream.
- Letting the workflow drift into predictive or causal language without reopening upstream.

## What This Stage Defers
- The exact structural model specification, calibration procedure, concrete validation implementation, and exact perturbation set.
- Any simulator, equation, or calibration choice that belongs to `analyze`.

## What Triggers Backtracking In This Stage
- Equally plausible rival mechanisms remain live after protocol commitments.
- Calibration is unstable under reasonable perturbations.
- Key states or parameters lack defensible anchors.
- The mechanism only succeeds through ad hoc tuning.
- The intended claim needs to extend beyond the calibrated regime.
