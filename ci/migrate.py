"""Apply SQL migrations to the ephemeral database, in filename order.

Runs every ``*.sql`` file in the ``migrations/`` directory sorted by name
(001_, 002_, ...), against the ephemeral database (PGDATABASE). Intended to run
after ci.create_database and before the tests.
"""

from __future__ import annotations

import sys
from pathlib import Path

import psycopg

from src.db import connect

MIGRATIONS_DIR = Path(__file__).resolve().parent.parent / "migrations"


def migration_files() -> list[Path]:
    return sorted(MIGRATIONS_DIR.glob("*.sql"))


def apply_migrations() -> None:
    files = migration_files()
    if not files:
        print(f"No migrations found in {MIGRATIONS_DIR}.")
        return

    with connect() as conn:
        for path in files:
            sql_text = path.read_text(encoding="utf-8")
            with conn.cursor() as cur:
                cur.execute(sql_text)
            conn.commit()
            print(f"Applied migration {path.name}.")


if __name__ == "__main__":
    try:
        apply_migrations()
    except Exception as exc:  # noqa: BLE001 - surface a clean CI failure
        print(f"Failed to apply migrations: {exc}", file=sys.stderr)
        sys.exit(1)
