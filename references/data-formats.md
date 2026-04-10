# Data Format Ingest Checklists

This file provides format-specific ingest guidance for Formulate Cycle A. When loading source data, identify the format of each source file and apply the relevant checklist below. Multiple formats may apply if the project has heterogeneous sources.

These checklists supplement, not replace, the Cycle A checklist in `formulate.md`. They address format-specific failure modes that the generic checklist does not cover.

## CSV / TSV / Delimited Text

| check | question |
|-------|----------|
| CSV01 | What is the detected character encoding? (Apply the Source Data Encoding rules from `core-principles.md`.) |
| CSV02 | What is the field delimiter? Verify by inspecting the first 5 rows. Do not assume comma — semicolons, tabs, and pipes are common. |
| CSV03 | Is a BOM (byte order mark) present? If yes, ensure the reader handles or strips it. |
| CSV04 | Does the file have a header row? Verify column names match expected schema or documentation. |
| CSV05 | Do any fields contain quoted values with embedded delimiters, newlines, or quotes? Verify the quoting convention (double-quote, escape character). |
| CSV06 | After loading, are any columns unexpectedly typed? Check for mixed-type columns where numbers are stored as strings, dates parsed as objects, or booleans coerced to integers. |
| CSV07 | Does the row count after loading match the expected line count minus the header? A mismatch signals embedded newlines, truncation, or encoding corruption. |

## Excel (.xlsx / .xls / .ods)

| check | question |
|-------|----------|
| XLS01 | Which sheet(s) contain the relevant data? List all sheets and their row counts. |
| XLS02 | Are there merged cells? If yes, document their locations and decide whether to unmerge or exclude. Merged cells cause silent misalignment in pandas. |
| XLS03 | Which row is the header? Check for multi-row headers, banner rows, or metadata rows above the data. |
| XLS04 | Are there named ranges or formulas that affect data values? If cells contain formulas, decide whether to read computed values or the formula text. |
| XLS05 | How are dates represented? Excel serial dates, formatted strings, and ISO dates all parse differently. Verify date columns render correctly after loading. |
| XLS06 | Are there hidden rows or columns? Check for filtered views that may exclude data. |

## Parquet / Feather / HDF5 / ORC

| check | question |
|-------|----------|
| BIN01 | What is the schema (column names, dtypes, nullable flags)? Read the schema metadata before loading the full dataset. |
| BIN02 | Is the file partitioned? If yes, list partition columns and verify all partitions are present. |
| BIN03 | What compression codec is used? Verify the reader supports it (snappy, gzip, lz4, zstd). |
| BIN04 | For HDF5: which group/key contains the target data? List all groups. |
| BIN05 | Does the row count match expectations from documentation or upstream metadata? |

## JSON / JSONL / NDJSON

| check | question |
|-------|----------|
| JSON01 | Is the file a single JSON object, a JSON array, or newline-delimited JSON (JSONL)? Use the correct reader. |
| JSON02 | What is the nesting depth? Flat records load directly; nested structures require explicit flattening decisions. Document which fields to flatten and how. |
| JSON03 | Is the schema consistent across all records? Check the first, middle, and last records for missing keys, extra keys, or type variation. |
| JSON04 | What is the encoding? (Apply Source Data Encoding rules.) JSON spec requires UTF-8, but non-compliant files exist. |
| JSON05 | Are there null representations beyond JSON `null`? (e.g., `"null"`, `"N/A"`, `""`, `"None"` as strings) |

## SQL Database / SQLite / Database Dump

| check | question |
|-------|----------|
| SQL01 | Which table(s) or view(s) contain the relevant data? List all tables with row counts. |
| SQL02 | What is the character set of the database or dump file? (UTF-8, Latin-1, etc.) |
| SQL03 | Are there views that depend on other views or functions? If reading from a dump, verify all dependencies are present. |
| SQL04 | For SQLite: is the file locked by another process? Verify read access before loading. |
| SQL05 | Are there index-only or computed columns that may not appear in a simple `SELECT *`? |

## API / Remote Source

| check | question |
|-------|----------|
| API01 | Is authentication required? Verify access without embedding secrets in tracked files. |
| API02 | Is the response paginated? Verify all pages were fetched and the total row count matches the expected count. |
| API03 | What is the response format (JSON, CSV, XML)? Apply the relevant format checklist above after downloading. |
| API04 | Is there rate limiting? Document the limit and ensure the fetch script respects it. |
| API05 | Is the API response stable? Check whether the same query returns the same data on repeated calls. If not, document the snapshot date. |

## XML / HTML Table

| check | question |
|-------|----------|
| XML01 | What is the document encoding? Check the XML declaration or meta charset tag. |
| XML02 | What is the target element path (XPath or CSS selector)? Verify it selects the intended data, not surrounding markup. |
| XML03 | Are there namespaces? If yes, configure the parser to handle them. |
| XML04 | For HTML tables: which table on the page contains the data? Verify by index or content. |
