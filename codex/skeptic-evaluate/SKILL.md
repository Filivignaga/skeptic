---
name: skeptic-evaluate
description: Skeptic route-appropriate PCS evaluation. Use when the user asks to evaluate claims, run PCS review, audit predictability, computability, stability, claim survival, or validity threats. Also use when the user invokes /skeptic:evaluate, skeptic:evaluate, or skeptic-evaluate.
---

# skeptic-evaluate

Read and follow `references/evaluate.md`.
Also read and follow `references/core-principles.md`.

Treat the user's request as the stage input.

Use `skeptic.yaml` for configuration when present. If it is absent, use the defaults in `references/core-principles.md`.

When a stage file says to load `references/{stage}/cycles/{cycle}.yaml`, load the local file at `references/cycles/{cycle}.yaml` for this skill.
When route-specific context is required, load the local file at `references/routes/{route}/evaluate.md`.
