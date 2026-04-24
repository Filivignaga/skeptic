---
name: skeptic-examine
description: Skeptic post-clean data examination under protocol rules. Use when the user asks to examine cleaned data, inspect distributions, relationships, anomalies, route pressure, or what the data can support. Also use when the user invokes /skeptic:examine, skeptic:examine, or skeptic-examine.
---

# skeptic-examine

Read and follow `references/examine.md`.
Also read and follow `references/core-principles.md`.

Treat the user's request as the stage input.

Use `skeptic.yaml` for configuration when present. If it is absent, use the defaults in `references/core-principles.md`.

When a stage file says to load `references/{stage}/cycles/{cycle}.yaml`, load the local file at `references/cycles/{cycle}.yaml` for this skill.
When route-specific context is required, load the local file at `references/routes/{route}/examine.md`.
