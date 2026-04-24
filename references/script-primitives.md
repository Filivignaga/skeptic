# Script Primitives

Every stage script exposes a fixed set of project-side helpers. Cycle functions call these helpers; they do not reimplement I/O, dtype interpretation, or constraint verification. Bugs are fixed once in the helper. Any helper at module scope that is not in this registry is a defect.

## Registered helpers

### `sha256_of`

**Signature:** `sha256_of(path: Path) -> str`

**Contract:** Returns the hex SHA-256 digest of the file at `path`, reading in 1 MiB chunks. Output is always a 64-character hex string.

**Failure modes:** `FileNotFoundError` when the path does not exist.

---

### `detect_encoding`

**Signature:** `detect_encoding(path: Path) -> str`

**Contract:** Probes for text encoding in this order: UTF-8 strict; UTF-16 when a BOM is present; cp1252/Latin-1 as last resort. Returns the encoding name to pass to downstream readers.

**Failure modes:** `UnicodeDecodeError` when all three probe attempts fail.

---

### `read_csv`

**Signature:** `read_csv(path: Path, **kwargs) -> pd.DataFrame`

**Contract:** Encoding-aware CSV reader. Calls `detect_encoding` when no `encoding` kwarg is supplied, then delegates to `pandas.read_csv`. This is a thin wrapper; it does not cache. Use `load_raw` when memoization across cycles is required.

**Failure modes:** Propagates all pandas and encoding errors without suppression.

---

### `load_raw`

**Signature:** `load_raw(path: Path, schema: Mapping[str, DTypeMeaning], encoding: str | None = None) -> pd.DataFrame`

**Contract:** Memoized per path within one process invocation. First call reads via `read_csv` and applies dtypes from `schema` using `check_dtype_meaning` semantics. Subsequent calls within the same process return the cached DataFrame unmodified. Every cycle that runs in the same process sees identical dtypes for the same file; this eliminates per-cycle dtype drift.

**Failure modes:** `FileNotFoundError` when the path does not exist; `KeyError` when a column named in `schema` is absent from the file; `UnicodeDecodeError` when encoding detection fails.

---

### `check_dtype_meaning`

**Signature:** `check_dtype_meaning(series: pd.Series, expected_meaning: DTypeMeaning) -> bool`

**Contract:** Semantic dtype family check. Does not compare literal dtype strings. Recognized families and what they accept:

- `numeric`: numpy integer/float types, pandas `Int8`–`Int64`, `Float32`, `Float64`
- `string`: `object`, pandas `StringDtype`, pyarrow `pa.string()` / `pa.large_string()` (pyarrow branch skipped when pyarrow is unavailable)
- `categorical`: `pandas.CategoricalDtype` only
- `date`: `numpy.datetime64` variants, pyarrow `pa.timestamp()` (pyarrow branch skipped when unavailable)
- `boolean`: pandas `BooleanDtype` or numpy `bool_`
- `identifier`: string or integer family (union of `string` and `numeric` integer checks)

Returns `True` when the series dtype belongs to the named family, `False` otherwise.

**Failure modes:** `ValueError` on an unrecognized `expected_meaning` string.

---

### `verify_constraint`

**Signature:** `verify_constraint(ser: pd.Series, constraint: Mapping[str, Any]) -> dict[str, Any]`

**Contract:** Evaluates one constraint entry against a series and returns the common envelope dict defined in `constraint-spec.md`. Null separation is enforced before every check: the denominator (`element_count`) is always the count of non-null values in `ser`; null rows are excluded from membership and range comparisons. For set-membership checks: `bad = ser[ser.notna() & ~ser.isin(allowed)]`. For range checks: analogous filter on non-null rows only.

Edge cases:
- Empty `allowed` set: all non-null values fail.
- Entirely-null series: `element_count = 0`, `failure_count = 0`, `status = PASS`.

**Failure modes:** `KeyError` when required constraint keys (`check`, `params`) are absent; propagates type errors from pandas comparison operations.

---

### `load_state`

**Signature:** `load_state(yaml_path: Path) -> dict[str, Any]`

**Contract:** Read-only load of a canonical stage YAML. Returns an empty dict when the file is absent (Cycle A bootstrap case). Never writes to the file.

**Failure modes:** Propagates `yaml.YAMLError` on malformed YAML; propagates `PermissionError` on access denial.

---

## Per-cycle call map

| Helper | Cycles |
|---|---|
| `sha256_of` | formulate A, clean A, analyze A |
| `load_raw` | clean A through S (every cycle that reads raw); examine A through E; analyze C through F |
| `check_dtype_meaning` | clean A (A02), clean R (R03) |
| `verify_constraint` | clean R (R03) |
| `load_state` | every cycle after A in every stage |

## Rule

No generic helpers at module scope beyond those declared in `references/script-primitives.md` and the Script shape above. Primitive-registry helpers are the explicit exception to the cycle-local rule because they must be called identically across cycles. Any other helper introduced for a cycle lives inside that cycle's function and is removed once the cycle passes.
