---
name: skeptic-protocol
description: Skeptic project rules of the game. Use when the user asks to define data usage rules, validation logic, leakage rules, visibility constraints, prohibitions, or backtracking triggers before cleaning or analysis. Also use when the user invokes /skeptic:protocol, skeptic:protocol, or skeptic-protocol.
---

# skeptic-protocol

Read and follow `references/protocol.md`.
Also read and follow `references/core-principles.md`.

Treat the user's request as the stage input.

Use `skeptic.yaml` for configuration when present. If it is absent, use the defaults in `references/core-principles.md`.

When a stage file says to load `references/{stage}/cycles/{cycle}.yaml`, load the local file at `references/cycles/{cycle}.yaml` for this skill.
When route-specific context is required, load the local file at `references/routes/{route}/protocol.md`.
