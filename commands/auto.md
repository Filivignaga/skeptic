---
description: "Skeptic Auto Mode - run the full 7-stage pipeline with stage-boundary approvals"
---

Read and follow `~/.claude/skills/skeptic/references/auto-mode.md`.
Also read and follow `~/.claude/skills/skeptic/references/core-principles.md`.

When `auto-mode.md` and a stage file disagree about runtime control flow, `auto-mode.md` wins. Stage files still define the stage-specific question, required evidence, acceptance criteria, route, PCS, and logging requirements.

Run the full pipeline in order:
1. `formulate`
2. `protocol`
3. `clean`
4. `examine`
5. `analyze`
6. `evaluate`
7. `communicate`

For each stage, read `~/.claude/skills/skeptic/references/{stage}/{stage}.md`.
After `formulate` resolves the active route, also load the corresponding route file for each later stage.

User input: $ARGUMENTS
