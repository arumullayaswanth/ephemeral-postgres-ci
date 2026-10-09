"""Thin application-level data access helpers used by the integration tests."""

from __future__ import annotations

from contextlib import contextmanager
from typing import Iterator

import psycopg

from .config import DbConfig, app_config


@contextmanager
def connect(config: DbConfig | None = None) -> Iterator[psycopg.Connection]:
    """Open a connection to the ephemeral application database."""
    cfg = config or app_config()
    conn = psycopg.connect(cfg.conninfo())
    try:
        yield conn
    finally:
        conn.close()


def health_check(config: DbConfig | None = None) -> bool:
    """Return True if the database answers a trivial query."""
    with connect(config) as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            return cur.fetchone() == (1,)
