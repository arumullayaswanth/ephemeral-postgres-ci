"""Integration tests that run against the migrated ephemeral database."""

from __future__ import annotations

from decimal import Decimal

import psycopg


def test_connection_is_live(db_connection: psycopg.Connection) -> None:
    with db_connection.cursor() as cur:
        cur.execute("SELECT 1")
        assert cur.fetchone() == (1,)


def test_widget_table_exists(db_connection: psycopg.Connection) -> None:
    """The widget table is created by migrations/001_init.sql."""
    with db_connection.cursor() as cur:
        cur.execute("SELECT to_regclass('public.widget')")
        assert cur.fetchone()[0] == "widget"


def test_widget_seed_data(db_connection: psycopg.Connection) -> None:
    """The seed data from 001_init.sql is present."""
    with db_connection.cursor() as cur:
        cur.execute("SELECT count(*) FROM widget")
        assert cur.fetchone()[0] >= 3

        cur.execute("SELECT price FROM widget WHERE name = %s", ("gadget",))
        # NUMERIC columns come back as Decimal, not float.
        assert cur.fetchone()[0] == Decimal("9.99")
