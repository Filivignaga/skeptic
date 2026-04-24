"""Skeleton for `{NN}_{stage}.py` project-side scripts.

Copy this file into the project's scripts directory as the stage's script
(for example `01_formulation.py`) in Cycle A, then add one `run_cycle_*`
function per cycle. The rules enforced by this skeleton are:

- Exactly one JSON object printed to stdout by `main()`. Nothing else.
- `main()` also writes the same JSON to `stdout/cycle_{cycle}.json`
  (sibling of the script). Overwritten on re-run; audit artifact only.
- No writes to the canonical stage YAML. Only the model writes it.
- Cycle-specific logic lives inside the cycle function when it is one-off.
  Stable deterministic helpers are allowed when they reduce duplication and
  improve reproducibility.
- Per-file provenance (sha256, encoding) is emitted only the first time
  a file is recorded (typically Cycle A iter 1). Downstream cycles
  reference files by filename.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any, Callable, Dict, Iterable, Optional, Tuple

import yaml  # noqa: F401  # available via the project's requirements


# ---------------------------------------------------------------------------
# Fixed-surface helpers. Do not rename these helpers. Add new helpers only when
# they are deterministic, reusable, and do not write canonical YAML.
# ---------------------------------------------------------------------------


def sha256_of(path: Path) -> str:
    """Return the hex SHA-256 of the file at `path`."""
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def detect_encoding(path: Path) -> str:
    """Return the detected text encoding for a CSV/TSV-like file.

    Rules (mirroring core-principles.md "Source Data Encoding"):
    1. Try UTF-8 strict.
    2. Fall back to UTF-16 when a BOM is present.
    3. Otherwise try Windows-1252 / Latin-1.
    The returned string is the encoding name to pass to downstream readers.
    """
    raw = path.read_bytes()
    if raw.startswith(b"\xff\xfe") or raw.startswith(b"\xfe\xff"):
        return "utf-16"
    if raw.startswith(b"\xef\xbb\xbf"):
        return "utf-8-sig"
    try:
        raw.decode("utf-8")
        return "utf-8"
    except UnicodeDecodeError:
        # Last-resort fallback; Windows-1252 is a superset of Latin-1.
        raw.decode("cp1252")
        return "cp1252"


def infer_source_format(path: Path, declared_format: Optional[str] = None) -> str:
    """Return a normalized source format label."""
    if declared_format:
        return declared_format.lower().strip(".")
    suffix = path.suffix.lower().strip(".")
    if suffix in {"csv", "tsv", "txt", "psv"}:
        return suffix
    if suffix in {"xlsx", "xls"}:
        return "excel"
    if suffix in {"parquet", "pq"}:
        return "parquet"
    if suffix in {"feather"}:
        return "feather"
    if suffix in {"json"}:
        return "json"
    if suffix in {"jsonl", "ndjson"}:
        return "jsonl"
    if suffix in {"sqlite", "sqlite3", "db"}:
        return "sqlite"
    return suffix or "unknown"


def load_source(
    path: Path,
    declared_format: Optional[str] = None,
    **kwargs: Any,
) -> Tuple[Any, Dict[str, Any]]:
    """Load a tabular source and return `(dataframe, metadata)`.

    Supported local formats: CSV/TSV/PSV/TXT, Excel, Parquet, Feather,
    JSON/JSONL, and SQLite. SQL sources require `query=` in kwargs.
    The metadata is intended for Cycle A provenance and load warnings.
    """
    import pandas as pd

    fmt = infer_source_format(path, declared_format)
    warnings = []
    reader = ""
    reader_options = dict(kwargs)

    if fmt in {"csv", "tsv", "txt", "psv"}:
        sep_by_format = {"csv": ",", "tsv": "\t", "txt": None, "psv": "|"}
        encoding = kwargs.pop("encoding", None) or detect_encoding(path)
        sep = kwargs.pop("sep", sep_by_format.get(fmt))
        reader = "pandas.read_csv"
        if sep is None:
            kwargs.setdefault("sep", None)
            kwargs.setdefault("engine", "python")
            warnings.append("delimiter inferred by pandas python engine")
        else:
            kwargs["sep"] = sep
        df = pd.read_csv(path, encoding=encoding, **kwargs)
        reader_options = {**kwargs, "encoding": encoding}
    elif fmt == "excel":
        reader = "pandas.read_excel"
        df = pd.read_excel(path, **kwargs)
    elif fmt == "parquet":
        reader = "pandas.read_parquet"
        df = pd.read_parquet(path, **kwargs)
    elif fmt == "feather":
        reader = "pandas.read_feather"
        df = pd.read_feather(path, **kwargs)
    elif fmt == "json":
        reader = "pandas.read_json"
        df = pd.read_json(path, **kwargs)
    elif fmt == "jsonl":
        reader = "pandas.read_json(lines=True)"
        df = pd.read_json(path, lines=True, **kwargs)
    elif fmt == "sqlite":
        import sqlite3

        query = kwargs.pop("query", None)
        if not query:
            raise ValueError("SQLite sources require query=<SQL select>")
        reader = "pandas.read_sql_query"
        with sqlite3.connect(path) as conn:
            df = pd.read_sql_query(query, conn, **kwargs)
        reader_options = {**kwargs, "query": query}
    else:
        raise ValueError(f"unsupported source format: {fmt}")

    metadata = {
        "path": str(path),
        "format": fmt,
        "reader": reader,
        "reader_options": reader_options,
        "schema_source": "inferred_from_file",
        "load_warnings": warnings,
    }
    return df, metadata


def read_csv(path: Path, **kwargs: Any):
    """Backward-compatible CSV adapter. Prefer `load_source`."""
    df, _metadata = load_source(path, declared_format="csv", **kwargs)
    return df


def _series_profile(series: Any) -> Dict[str, Any]:
    """Return a compact dtype-aware profile for one pandas Series."""
    import pandas as pd

    result: Dict[str, Any] = {
        "dtype": str(series.dtype),
        "n": int(series.shape[0]),
        "n_missing": int(series.isna().sum()),
        "pct_missing": float(series.isna().mean()) if series.shape[0] else 0.0,
    }
    non_null = series.dropna()

    if pd.api.types.is_numeric_dtype(series):
        quantiles = non_null.quantile([0.01, 0.05, 0.5, 0.95, 0.99]).to_dict()
        result.update(
            {
                "kind": "numeric",
                "min": None if non_null.empty else float(non_null.min()),
                "max": None if non_null.empty else float(non_null.max()),
                "quantiles": {str(k): float(v) for k, v in quantiles.items()},
                "zeros": int((non_null == 0).sum()),
                "negatives": int((non_null < 0).sum()),
            }
        )
    elif pd.api.types.is_datetime64_any_dtype(series):
        duplicated = int(non_null.duplicated().sum())
        result.update(
            {
                "kind": "datetime",
                "min": None if non_null.empty else str(non_null.min()),
                "max": None if non_null.empty else str(non_null.max()),
                "timezone": str(getattr(series.dt, "tz", None)),
                "duplicate_timestamps": duplicated,
            }
        )
    else:
        as_text = non_null.astype(str)
        value_counts = as_text.value_counts(dropna=True)
        unique_count = int(value_counts.shape[0])
        top = value_counts.head(20).to_dict()
        concentration = (
            float(value_counts.iloc[0] / max(1, len(as_text))) if unique_count else 0.0
        )
        text_lengths = as_text.str.len()
        result.update(
            {
                "kind": "categorical_or_text",
                "unique_count": unique_count,
                "top_values": {str(k): int(v) for k, v in top.items()},
                "top_value_share": concentration,
                "rare_levels_le_2": int((value_counts <= 2).sum()),
                "empty_or_whitespace": int(as_text.str.strip().eq("").sum()),
                "text_length": {
                    "min": None if text_lengths.empty else int(text_lengths.min()),
                    "median": None if text_lengths.empty else float(text_lengths.median()),
                    "max": None if text_lengths.empty else int(text_lengths.max()),
                },
            }
        )
    return result


def profile_by_dtype(df: Any, key_candidates: Optional[Iterable[str]] = None) -> Dict[str, Any]:
    """Return a dataset-agnostic profile grouped by observed dtype behavior."""
    profile = {column: _series_profile(df[column]) for column in df.columns}
    keys = {}
    for column in key_candidates or []:
        if column in df.columns:
            keys[column] = {
                "unique": int(df[column].nunique(dropna=True)),
                "duplicates": int(df[column].duplicated(keep=False).sum()),
                "pct_missing": float(df[column].isna().mean()),
            }
    return {
        "n_rows": int(df.shape[0]),
        "n_cols": int(df.shape[1]),
        "columns": profile,
        "key_integrity": keys,
    }


def load_state(yaml_path: Path) -> Dict[str, Any]:
    """Load the canonical stage YAML as a dict. Read-only."""
    import yaml

    with yaml_path.open("r", encoding="utf-8") as fh:
        return yaml.safe_load(fh) or {}


# ---------------------------------------------------------------------------
# Cycle functions. Add one per cycle. Keep cycle-specific logic inside.
# ---------------------------------------------------------------------------


def run_cycle_a(state: Dict[str, Any]) -> Dict[str, Any]:
    """Cycle A body. Replace the placeholder return with real evidence."""
    # Example scaffold; real cycles must populate every required evidence key
    # named in the cycle YAML.
    return {
        "cycle": "A",
        "iteration": state.get("status", {}).get("iteration", 1),
        # evidence_key: value pairs go here
    }


# Add `run_cycle_b`, `run_cycle_c`, ... at the start of every subsequent cycle.


# ---------------------------------------------------------------------------
# CLI entry point. Do not modify the surface; only add cycles to the dispatch.
# ---------------------------------------------------------------------------


CYCLES: Dict[str, Callable[[Dict[str, Any]], Dict[str, Any]]] = {
    "A": run_cycle_a,
    # "B": run_cycle_b,
    # ...
}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cycle", required=True)
    parser.add_argument(
        "--state",
        default=None,
        help="Path to the canonical stage YAML. Defaults to the sibling "
        "{NN}_{stage}.yaml under the configured docs directory.",
    )
    args = parser.parse_args()

    cycle_fn = CYCLES.get(args.cycle.upper())
    if cycle_fn is None:
        print(
            json.dumps({"error": f"unknown cycle: {args.cycle}"}),
            file=sys.stdout,
        )
        return 2

    state_path = Path(args.state) if args.state else Path(__file__).with_suffix(".yaml")
    state = load_state(state_path) if state_path.exists() else {}

    evidence = cycle_fn(state)
    output = json.dumps(evidence, ensure_ascii=False, sort_keys=True)

    # Mirror stdout to an on-disk audit file (overwritten each run).
    stdout_dir = Path(__file__).parent / "stdout"
    stdout_dir.mkdir(parents=True, exist_ok=True)
    (stdout_dir / f"cycle_{args.cycle.upper()}.json").write_text(
        output, encoding="utf-8"
    )

    print(output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
