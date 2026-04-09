---
name: analyze-mechanistic
description: Stage-specific route file for the DSLC analyze stage for mechanistic questions. Narrows the universal analyze stage-core.
---

# Analyze Route File: Mechanistic

## What This Stage Protects
- Structural identifiability before calibration: identifiability is verified before any parameter estimation. If structural identifiability fails, calibration is invalid regardless of data quality.
- Separation of process model from observation model: the contract names both the latent-state dynamics and the measurement layer explicitly.
- Parameter interpretability under the mechanism claim: parameters represent rates, affinities, compartment volumes, or other domain quantities. Non-identifiability implies underinformativeness of data, not overparameterization.
- Calibration targets aligned with the mechanism: targets reflect the mechanistic claim, not convenience or data availability alone.
- Falsifiability of the structural form: the contract includes conditions under which the proposed structure would be rejected. Good fit alone is insufficient.
- Regime boundaries and boundary-condition coverage: the contract specifies over which regime the mechanism claim holds and what boundary conditions are needed.

## What This Stage Prohibits
- Treating goodness-of-fit as mechanism evidence. A model can fit data well while being fundamentally flawed with non-unique or meaningless parameters.
- Calibrating structurally non-identifiable parameters. Attempting to overcome structural non-identifiability with more data or tighter priors is invalid.
- Post-hoc structural revision after seeing calibration results. Adding compartments, states, or feedback loops after observing poor fit converts analysis into exploratory model building.
- Narrative plausibility as calibration evidence. A biologically plausible story about parameter values is not evidence that they are identifiable or well-estimated.
- Overfitting through flexible structure. Adding structural complexity must be justified by identifiability and data support, not by fit improvement.
- Ignoring structural sensitivity. Slight modifications in functional forms can cause catastrophic changes in dynamics even when large parameter variations produce only small changes.
- Claiming mechanism beyond the calibrated regime.
- Self-revision based on result quality.

## What This Stage Defers
- Whether calibration fit is adequate for the claim.
- Whether sensitivity divergence constitutes instability.
- Whether structural alternatives invalidate the primary mechanism.
- Whether the mechanism claim should be narrowed or abandoned.
- Whether posterior predictive checks reveal model misspecification.
- Whether identifiability limitations materially affect the claim.
- Cross-validation or out-of-sample predictive performance assessment.

## What Triggers Backtracking In This Stage
- Structural non-identifiability discovered during Cycle B with no viable reparameterization or reduced model.
- All pre-approved fallback structures also fail identifiability or estimability checks.
- Calibration convergence failure persisting across solvers and initial conditions.
- Boundary conditions or initial conditions required by the structural model are unavailable in the data.
- Calibrated regime does not cover the regime required by the approved question.
- State variables have no observable or defensibly inferred proxies in the data.
- Structural form requires data resolution (temporal, spatial, granularity) that the cleaned data cannot provide.

## Cycle B: Assumption Checks

- Structural identifiability: run a structural identifiability test (differential algebra, profile likelihood, or generating-series approach) on the specified model structure before any data fitting.
- Practical identifiability: after structural identifiability passes, check practical identifiability using profile likelihood or Fisher Information Matrix on the actual cleaned data.
- Parameter estimability: determine which parameters can be reliably estimated and which must be fixed or reduced.
- Initial-condition availability: required initial conditions are available in the data or can be defensibly estimated.
- Boundary-condition coverage: data covers the boundary conditions the structural model requires.
- Regime coverage consistency: calibration data spans the regime over which the mechanism claim operates.
- Structural model consistency with observed data patterns: the qualitative dynamics the model can produce (oscillations, steady states, bifurcations, monotonic decay) are consistent with the data.
- Numerical stiffness and solver compatibility: the ODE or PDE system is solvable with available numerical methods at the data's resolution.

## Perturbation Axes

Parametric perturbations:
- Alternative parameterizations within plausible ranges.
- Local sensitivity analysis (derivative-based, around calibrated values).
- Global sensitivity analysis (Monte Carlo or PRCC across the full parameter space).
- Alternative initial conditions.
- Alternative boundary conditions where applicable.

Structural perturbations:
- Alternative structural forms: different ODE or compartment structures encoding competing mechanism hypotheses.
- Alternative functional forms for rate laws and interaction terms (structural sensitivity analysis).
- Topological perturbations: adding or removing connections, feedback loops, compartments.
- Alternative observation models: different mappings from latent states to observables.

Calibration perturbations:
- Alternative calibration targets: different subsets of observables used for fitting.
- Alternative calibration methods: maximum likelihood vs. Bayesian vs. ABC.
- Alternative prior specifications for Bayesian approaches.
- Alternative loss functions or objective functions.

Data perturbations:
- Subsampling or jackknife of calibration data.
- Perturbation of data resolution (coarsened temporal grid).

Minimum requirement: one structural alternative, parametric sensitivity (local or global), one calibration-target perturbation, and initial-condition sensitivity.

## Route-Specific Contract Fields

| Field | Description | Required |
|-------|-------------|----------|
| Structural model specification | Governing equations (ODEs, PDEs, agent rules) with explicit mathematical form | Yes |
| State variables | Named list of all dynamic state variables; which are observed vs. latent | Yes |
| Parameters | Named list with units, role in the mechanism, and source of initial values | Yes |
| Observation model | How state variables map to observables; measurement error structure | Yes |
| Calibration method | Estimation approach (MLE, Bayesian MCMC, ABC) with solver and algorithm specifics | Yes |
| Calibration targets | Which observables are used for fitting, with weighting or loss function | Yes |
| Identifiability method | Which structural and practical identifiability tests will be run, with pass and fail criteria | Yes |
| Initial conditions | Source and values for all initial states; which are measured vs. assumed vs. estimated | Yes |
| Boundary conditions | Required boundary conditions and their data sources | When applicable |
| Regime specification | Regime over which the mechanism claim holds; regime boundaries | Yes |
| Structural alternatives | Pre-specified alternative structural forms for challenger execution | Yes |
| Solver specification | Numerical solver, tolerances, step control | Yes |

## Internal Execution Sequence

Cycle C (Primary Execution) follows this order:

1. Restate the locked structural specification: equations, state variables, parameters, observation model, initial conditions, boundary conditions, solver, calibration method, calibration targets.
2. Implement the structural model in code. Verify the implementation reproduces expected behavior for known test cases or analytical solutions where available.
3. Run structural identifiability test if not already passed in Cycle B or if contract amendments occurred.
4. Set initial parameter values from literature, prior cycles, or domain expertise. Document source for each.
5. Execute calibration: fit parameters to calibration targets. Record convergence diagnostics, optimization trajectory, final parameter values with uncertainty.
6. Run practical identifiability check: profile likelihood or posterior diagnostics on calibrated parameters. Flag poorly identified parameters.
7. Generate model outputs: simulate the calibrated model across the calibration regime. Record all primary outputs.
8. Compute calibration diagnostics: residuals, posterior predictive checks if Bayesian, simulation-based calibration checks, goodness-of-fit metrics. Record without interpreting adequacy.
9. Record computational diagnostics: convergence status, runtime, solver warnings, numerical stability, seed values.
