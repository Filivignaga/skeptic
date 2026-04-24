# Stage Script Contract

Every project-side stage script is generated for the current project and data sources. Do not copy a shared Python scaffold. The skill specifies the contract; the model writes the smallest script that satisfies it.

## Required Surface

- Accept `--cycle {cycle}` and run only that cycle.
- Print exactly one JSON object to stdout. Print nothing else.
- Write a debug copy of stdout only when a cycle fails, is rerun for diagnosis, or the user asks for retained raw evidence.
- Read canonical YAML and upstream artifacts as needed, but never write canonical YAML.
- Produce every required evidence key named by the active cycle spec.
- Summarize heavy data. Do not emit full DataFrames, long arrays, or full per-row outputs.
- Exit non-zero or emit an explicit error object when the requested cycle is unknown or a required input is missing.

## Dataset-Specific Code

The script should use loaders and profiling logic that fit the actual source:

- delimited text: detect encoding, pass the encoding explicitly, and record delimiter assumptions
- Excel: record sheet names and selected sheet/range
- Parquet/Feather/columnar formats: use the native reader and record schema metadata
- JSON/JSONL/XML/API snapshots: normalize only as much as the current evidence key requires
- SQL/database snapshots: use explicit read-only queries and record query text or portable metadata without secrets

Avoid a one-size-fits-all loader when a direct project-specific reader is clearer.

## Reusable Helpers

Stable helper functions or sibling helper modules are allowed when they reduce duplication and improve reproducibility. Helpers must be deterministic, documented briefly, and must not write canonical YAML or access restricted artifacts.

## Evidence Quality

Cycle evidence should be compact but analytical. For dataset overview cycles, prefer dtype-aware profiling over generic `describe()` output:

- numeric: min, max, 1/5/50/95/99 percentiles, zero counts, negative counts, tail flags when relevant
- categorical: cardinality, top levels, rare levels, concentration
- datetime: min, max, timezone, gaps or duplicate timestamps when relevant
- text: length distribution and empty/whitespace rate
- identifiers: uniqueness, duplicates, missingness
- missingness: overall and stratified by time, group, or key fields when those structures exist

The script is an evidence tool, not the decision maker. The model interprets the JSON evidence and writes the canonical YAML.
