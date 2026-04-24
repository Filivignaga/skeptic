# Changelog

All notable changes to Skeptic will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-04-10

### Added
- Format-agnostic data ingest: `references/formulate/data-formats.md` defines rules for CSV, Parquet, JSON, Excel, and other formats so the pipeline handles them consistently
- Auto-mode stage-boundary validator aligned with canonical YAML, stage scripts, rendered reports, README blocks, and state checks
- Deliverable composition, encoding, and data quality acceptance criteria in the communicate stage
- Adversarial evaluation pass and cross-stage audit trail validation

### Changed
- `skeptic.yaml` is now tracked directly instead of shipping a `.example` file; simplifies setup and avoids config drift
- Hardened auto-mode state management: stage attempts update at every stage entry, cycle iterations track per-stage/per-cycle counts
- Stage-close reviews and finalization are now enforced (no skipping evaluation-to-communicate boundary)
- All internal references updated from DSLC to Skeptic
- Cycle YAMLs use the collapsed `required_evidence`, `acceptance_criteria`, and `writes` schema
- Stage-close reviews are stored as compact `pcs_review` summaries instead of full transcripts in canonical YAML
- Empty optional cycle fields are omitted

## [1.0.0] - 2026-04-09

### Added
- 7-stage data science lifecycle: formulate, protocol, clean, examine, analyze, evaluate, communicate
- `/skeptic:auto` mode: runs the full 7-stage pipeline autonomously with stage-boundary approvals
- 6 question-type routes: descriptive, exploratory, inferential, predictive, causal, mechanistic
- Route-specific instruction files (30 files across 6 routes)
- Claim boundary in canonical YAML with allowed/forbidden verb enforcement
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
