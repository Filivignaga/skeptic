# Changelog

All notable changes to Skeptic will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-09

### Added
- 7-stage data science lifecycle: formulate, protocol, clean, examine, analyze, evaluate, communicate
- `/skeptic:auto` mode: runs the full 7-stage pipeline autonomously with stage-boundary approvals
- 6 question-type routes: descriptive, exploratory, inferential, predictive, causal, mechanistic
- Route-specific instruction files (30 files across 6 routes)
- Claim Boundary Registry with allowed/forbidden verb enforcement
- PCS (Predictability, Computability, Stability) evaluation framework
- Dual-subagent review pattern (research + evaluation) per cycle
- Constraint specification system (declared + derived layers)
- 8 data-usage modes in Protocol stage
- Auditable artifact chain across all stages
- `skeptic.yaml` project-level configuration
- Stage-core reference files (formulate through communicate)
- Core principles and architecture documentation
- Setup script for one-line install with slash command registration
- 8 slash commands via `~/.claude/commands/skeptic/`
