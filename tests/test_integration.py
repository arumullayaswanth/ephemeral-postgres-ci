"""Integration tests that run against the migrated ephemeral database."""

from __future__ import annotations

from decimal import Decimal

import psycopg


def test_connection_is_live(db_connection: psycopg.Connection) -> None:
    with db_connection.cursor() as cur:
        cur.execute("SELECT 1")
        assert cur.fetchone() == (1,)


def test_widget_table_exists(db_connection: psycopg.Connection) -> None:
    """widget is created by migrations/001_init.sql."""
    with db_connection.cursor() as cur:
        cur.execute("SELECT to_regclass('public.widget')")
        assert cur.fetchone()[0] == "widget"


def test_widget_seed_data(db_connection: psycopg.Connection) -> None:
    with db_connection.cursor() as cur:
        cur.execute("SELECT count(*) FROM widget")
        assert cur.fetchone()[0] == 10

        cur.execute("SELECT price FROM widget WHERE name = %s", ("gadget",))
        assert cur.fetchone()[0] == Decimal("9.99")


def test_customers_seeded(db_connection: psycopg.Connection) -> None:
    with db_connection.cursor() as cur:
        cur.execute("SELECT count(*) FROM customer")
        assert cur.fetchone()[0] == 3

        cur.execute("SELECT name FROM customer WHERE email = %s", ("alice@example.com",))
        assert cur.fetchone()[0] == "Alice Johnson"


def test_orders_reference_customers_and_widgets(db_connection: psycopg.Connection) -> None:
    with db_connection.cursor() as cur:
        cur.execute(
            """
            SELECT c.name, w.name, o.quantity
            FROM orders o
            JOIN customer c ON c.id = o.customer_id
            JOIN widget   w ON w.id = o.widget_id
            WHERE c.email = %s
            """,
            ("carol@example.com",),
        )
        row = cur.fetchone()
        assert row == ("Carol White", "widget-pro", 5)


def test_inventory_stock(db_connection: psycopg.Connection) -> None:
    with db_connection.cursor() as cur:
        cur.execute(
            """
            SELECT i.stock
            FROM inventory i
            JOIN widget w ON w.id = i.widget_id
            WHERE w.name = %s AND i.warehouse = %s
            """,
            ("gadget", "east"),
        )
        assert cur.fetchone()[0] == 100


def test_categories_and_widget_link(db_connection: psycopg.Connection) -> None:
    with db_connection.cursor() as cur:
        cur.execute("SELECT count(*) FROM category")
        assert cur.fetchone()[0] == 3

        # 'bolt' should be linked to the 'fasteners' category.
        cur.execute(
            """
            SELECT cat.name
            FROM widget w
            JOIN category cat ON cat.id = w.category_id
            WHERE w.name = %s
            """,
            ("bolt",),
        )
        assert cur.fetchone()[0] == "fasteners"


def test_reviews_rating_bounds(db_connection: psycopg.Connection) -> None:
    with db_connection.cursor() as cur:
        cur.execute("SELECT count(*) FROM review")
        assert cur.fetchone()[0] == 3

        cur.execute("SELECT min(rating), max(rating) FROM review")
        low, high = cur.fetchone()
        assert low >= 1 and high <= 5
