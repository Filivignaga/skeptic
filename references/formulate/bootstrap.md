# Cycle A Bootstrap

One-time project setup performed at the start of Formulate Cycle A. These
steps run exactly once per project. On a backtrack they are not rerun; the
existing filesystem state stays authoritative.

1. Create `{projects_root}/{project-name}/{data_dir_name}/`.
2. Create `{projects_root}/{project-name}/{docs_dir_name}/`.
3. Create `{projects_root}/{project-name}/{scripts_dir_name}/`.
4. Copy each raw data source into `{data_dir_name}/` without modification. The copies under `{data_dir_name}/` are the canonical source throughout the lifecycle; never edit them.
5. Copy any provided documentation (codebook, README, data dictionary, collection notes) into `{data_dir_name}/`.
6. Create `{readme_name}` with the project name, the bootstrap date, and the data source names.
7. Initialize `{docs_dir_name}/01_formulation.yaml` with `stage`, `schema_version`, `project` (including `project.started_at` as an ISO 8601 timestamp), and `status.current_cycle: A`.
8. Create `{scripts_dir_name}/01_formulation.py` by copying `references/formulate/script_shape.py` into place. Do not rename or remove the fixed-surface helpers (`sha256_of`, `detect_encoding`, `read_csv`, `load_state`, `main`, `CYCLES`). Add the first cycle function (`run_cycle_a`) below the existing scaffold.

After these steps complete, proceed with Cycle A Step 1 execution exactly as
specified in `formulate.md`.
