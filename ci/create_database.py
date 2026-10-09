"""Create the ephemeral database for a single CI run.

CREATE DATABASE cannot run inside a transaction block, so we use an
autocommit connection against the maintenance database (PGADMINDB).

The target database name comes from PGDATABASE and is validated to avoid
injection, since database names cannot be bound as query parameters.
"""

from __future__ import annotations

import sys

import psycopg
from psycopg import sql

from src.config import admin_config, app_config


def database_exists(cur: psycopg.Cursor, name: str) -> bool:
    cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (name,))
    return cur.fetchone() is not None


def create_database() -> None:
    admin = admin_config()
    target = app_config().dbname

    with psycopg.connect(admin.conninfo(), autocommit=True) as conn:
        with conn.cursor() as cur:
            if database_exists(cur, target):
                print(f"Database {target!r} already exists; reusing it.")
                return
            cur.execute(
                sql.SQL("CREATE DATABASE {}").format(sql.Identifier(target))
            )
            print(f"Created ephemeral database {target!r}.")


if __name__ == "__main__":
    try:
        create_database()
    except Exception as exc:  # noqa: BLE001 - surface a clean CI failure
        print(f"Failed to create ephemeral database: {exc}", file=sys.stderr)
        sys.exit(1)
