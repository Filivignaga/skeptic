---
name: skeptic-clean
description: Skeptic auditable data cleaning under protocol rules. Use when the user asks to clean data under Skeptic protocol rules, create auditable cleaning scripts, or prepare data without modifying raw files. Also use when the user invokes /skeptic:clean, skeptic:clean, or skeptic-clean.
---

# skeptic-clean

Read and follow `references/clean.md`.
Also read and follow `references/core-principles.md`.

Treat the user's request as the stage input.

Use `skeptic.yaml` for configuration when present. If it is absent, use the defaults in `references/core-principles.md`.

When a stage file says to load `references/{stage}/cycles/{cycle}.yaml`, load the local file at `references/cycles/{cycle}.yaml` for this skill.
When route-specific context is required, load the local file at `references/routes/{route}/clean.md`.
