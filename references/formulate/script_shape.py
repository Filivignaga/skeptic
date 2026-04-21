"""Skeleton for `{NN}_{stage}.py` project-side scripts.

Copy this file into the project's scripts directory as the stage's script
(for example `01_formulation.py`) in Cycle A, then add one `run_cycle_*`
function per cycle. The rules enforced by this skeleton are:

- Exactly one JSON object printed to stdout by `main()`. Nothing else.
- No writes to the canonical stage YAML. Only the model writes it.
- Cycle-specific logic lives inside the cycle function. No generic
  helpers at module scope beyond what this skeleton already provides.
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
from typing import Any, Callable, Dict

import yaml  # noqa: F401  # available via the project's requirements


# ---------------------------------------------------------------------------
# Fixed-surface helpers. Do not rename, do not add siblings at module scope.
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


def read_csv(path: Path, **kwargs: Any):
    """Read a CSV with detected encoding. Returns a pandas DataFrame."""
    import pandas as pd

    encoding = kwargs.pop("encoding", None) or detect_encoding(path)
    return pd.read_csv(path, encoding=encoding, **kwargs)


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
    # Example scaffold; real cycles must populate every non-null evidence_key
    # named in the cycle YAML's checklist.
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
    print(json.dumps(evidence, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
