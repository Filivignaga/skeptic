---
name: skeptic-analyze
description: Skeptic route-specific analysis execution. Use when the user asks to lock and execute a route-specific Skeptic analysis contract, run approved analysis code, or produce analysis outputs under protocol constraints. Also use when the user invokes /skeptic:analyze, skeptic:analyze, or skeptic-analyze.
---

# skeptic-analyze

Read and follow `references/analyze.md`.
Also read and follow `references/core-principles.md`.

Treat the user's request as the stage input.

Use `skeptic.yaml` for configuration when present. If it is absent, use the defaults in `references/core-principles.md`.

When a stage file says to load `references/{stage}/cycles/{cycle}.yaml`, load the local file at `references/cycles/{cycle}.yaml` for this skill.
When route-specific context is required, load the local file at `references/routes/{route}/analyze.md`.
