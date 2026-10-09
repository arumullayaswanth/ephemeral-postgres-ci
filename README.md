# Ephemeral PostgreSQL Databases for CI

Create a throwaway PostgreSQL database on an **existing** AWS RDS instance for
each CI run, run integration tests against it, then drop it. This avoids
provisioning a whole RDS instance per pull request.

## How it works

```
Create database  →  Run tests  →  Drop database
 (ci/create_...)     (pytest)      (ci/drop_..., always)
```

* `ci/create_database.py` connects to the maintenance DB (`postgres`) and runs
  `CREATE DATABASE` for a per-run name (`ci_run_<run_id>_<attempt>`).
* `pytest` runs the integration tests against that ephemeral database.
* `ci/drop_database.py` terminates stray connections and drops the database.
  It runs in an `always()` step so a failed test never leaks a database.

## Project layout

| Path                      | Purpose                                         |
| ------------------------- | ----------------------------------------------- |
| `src/config.py`           | Admin vs. app connection config from env vars   |
| `src/db.py`               | Application-level DB helpers used by tests       |
| `ci/create_database.py`   | Create the per-run ephemeral database            |
| `ci/drop_database.py`     | Drop the ephemeral database (cleanup)            |
| `tests/`                  | Integration tests + pytest fixtures              |
| `.github/workflows/ci.yml`| Build + test workflow                            |

## Prerequisites

* An AWS account with an existing RDS PostgreSQL instance.
* A **self-hosted** GitHub Actions runner (or EC2 instance) in the same VPC
  with network access to the RDS security group. GitHub-hosted runners cannot
  reach a private RDS endpoint.
* A maintenance user with `CREATE DATABASE` privileges.
* Python 3.11+ and Git locally.

## Run it locally

```bash
python -m venv .venv
. .venv/Scripts/activate      # Windows
# source .venv/bin/activate   # macOS/Linux
pip install -r requirements.txt

copy .env.example .env        # then edit values
# load the env vars into your shell, then:
python -m ci.create_database
pytest -v
python -m ci.drop_database
```

## Configure GitHub Actions

Add these repository secrets: `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`.
Set the workflow `runs-on` to your self-hosted runner's label.

## Roadmap

This is the starter. Planned additions, in order:

1. **Database migrations** — create tables and validate schema before merge.
2. **AWS OIDC + Secrets Manager** — remove long-lived DB credentials from GitHub.
3. **Reliability** — cleanup safeguards, timeouts, failure reporting.
4. **Parallel CI jobs** — isolate databases per run, prevent cross-job interference.
