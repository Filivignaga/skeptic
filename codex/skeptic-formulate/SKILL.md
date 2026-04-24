---
name: skeptic-formulate
description: Skeptic problem formulation and data context. Use when the user asks to formulate a data question, define unit of analysis, target quantity, question type, initial claim boundary, or start a Skeptic project. Also use when the user invokes /skeptic:formulate, skeptic:formulate, or skeptic-formulate.
---

# skeptic-formulate

Read and follow `references/formulate.md`.
Also read and follow `references/core-principles.md`.

Treat the user's request as the stage input.

Use `skeptic.yaml` for configuration when present. If it is absent, use the defaults in `references/core-principles.md`.

When a stage file says to load `references/{stage}/cycles/{cycle}.yaml`, load the local file at `references/cycles/{cycle}.yaml` for this skill.
When route-specific context is required, load the local file at `references/routes/{route}/formulate.md`.
