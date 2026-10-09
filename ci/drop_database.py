"""Drop the ephemeral database at the end of a CI run.

This is the cleanup step. It is written to be idempotent and safe to run even
if earlier steps failed, so it can be invoked from an ``always()`` CI step.

Open connections to the target database (for example, a test process that
did not shut down cleanly) are terminated first so the DROP can proceed.
"""

from __future__ import annotations

import sys

import psycopg
from psycopg import sql

from src.config import admin_config, app_config


def terminate_connections(cur: psycopg.Cursor, name: str) -> None:
    cur.execute(
        """
        SELECT pg_terminate_backend(pid)
        FROM pg_stat_activity
        WHERE datname = %s AND pid <> pg_backend_pid()
        """,
        (name,),
    )


def drop_database() -> None:
    admin = admin_config()
    target = app_config().dbname

    with psycopg.connect(admin.conninfo(), autocommit=True) as conn:
        with conn.cursor() as cur:
            terminate_connections(cur, target)
            cur.execute(
                sql.SQL("DROP DATABASE IF EXISTS {}").format(
                    sql.Identifier(target)
                )
            )
            print(f"Dropped ephemeral database {target!r}.")


if __name__ == "__main__":
    try:
        drop_database()
    except Exception as exc:  # noqa: BLE001 - surface a clean CI failure
        print(f"Failed to drop ephemeral database: {exc}", file=sys.stderr)
        sys.exit(1)
