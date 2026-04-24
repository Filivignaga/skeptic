---
name: skeptic-communicate
description: Skeptic communication of evaluated results. Use when the user asks to communicate evaluated results, package surviving claims, produce deliverables, audience framing, or final Skeptic reports. Also use when the user invokes /skeptic:communicate, skeptic:communicate, or skeptic-communicate.
---

# skeptic-communicate

Read and follow `references/communicate.md`.
Also read and follow `references/core-principles.md`.

Treat the user's request as the stage input.

Use `skeptic.yaml` for configuration when present. If it is absent, use the defaults in `references/core-principles.md`.

When a stage file says to load `references/{stage}/cycles/{cycle}.yaml`, load the local file at `references/cycles/{cycle}.yaml` for this skill.
When route-specific context is required, load the local file at `references/routes/{route}/communicate.md`.
