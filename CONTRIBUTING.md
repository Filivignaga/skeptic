# Contributing to Skeptic

PRs reviewed within 72 hours.

## Before You Start

Read `references/core-principles.md` for architecture decisions and the design contract. Changes that violate it will be rejected.

## What We Accept

- Bug fixes in stage-core or route files
- New route-specific instruction files (with justification for the question type)
- Improvements to constraint validation logic
- Documentation fixes
- Test cases or worked examples

## What We Don't Accept

- Changes that weaken sequential stage enforcement
- Removing or softening acceptance criteria
- Adding "skip stage" or "fast path" shortcuts to the core workflow
- Generic prompt improvements that don't reference specific failure modes

## Writing Standards

- **README**: product language, payoff before theory
- **references/**: formal methodology language, executable by Claude Code
- **Route files**: four sections only (What This Stage Protects, What This Stage Prohibits, What This Stage Defers, What Triggers Backtracking)

## Pull Request Process

1. Fork the repository
2. Create a branch from `master`
3. Make your changes
4. Verify every referenced file exists and is internally consistent
5. Test the skill in Claude Code with a real dataset
6. Open a PR with a description of what changed and why

## Consistency Checks

Before submitting, verify:
- All 30 route files exist (`references/routes/{descriptive,exploratory,inferential,predictive,causal,mechanistic}/{protocol,clean,examine,analyze,evaluate}.md`)
- All 7 stage files exist under `references/{stage}/{stage}.md`
- No absolute paths or personal details in any file
- `SKILL.md` subcommand table matches actual stage files
- `VERSION` is bumped and `CHANGELOG.md` is updated
