---
name: skeptic-auto
description: Skeptic Auto Mode - run the full 7-stage Skeptic pipeline in Codex with stage-boundary approvals. Use when the user asks to run Skeptic automatically, run the full Skeptic lifecycle, invoke /skeptic:auto, skeptic:auto, or skeptic-auto.
---

# skeptic-auto

Read and follow `references/auto-mode.md`.
Also read and follow `references/core-principles.md`.

When `auto-mode.md` and a stage file disagree about runtime control flow, `auto-mode.md` wins. Stage files still define the stage-specific question, required evidence, acceptance criteria, route, PCS, and logging requirements.

Run the full pipeline in order:

1. `formulate`
2. `protocol`
3. `clean`
4. `examine`
5. `analyze`
6. `evaluate`
7. `communicate`

For each stage, read `references/{stage}/{stage}.md`.
After `formulate` resolves the active route, also load the corresponding route file at `references/routes/{route}/{stage}.md` for each later stage.

Treat the user's request as the auto-mode input.
