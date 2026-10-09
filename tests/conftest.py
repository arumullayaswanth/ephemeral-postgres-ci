"""Pytest fixtures that connect the integration tests to the ephemeral DB.

The ephemeral database itself is created and dropped by the CI workflow
(ci/create_database.py and ci/drop_database.py). These fixtures only manage
schema and per-test isolation inside that database.
"""

from __future__ import annotations

from typing import Iterator

import psycopg
import pytest

from src.db import connect


@pytest.fixture(scope="session")
def db_connection() -> Iterator[psycopg.Connection]:
    """A session-scoped connection to the ephemeral database."""
    with connect() as conn:
        yield conn


@pytest.fixture(autouse=True)
def rollback_per_test(db_connection: psycopg.Connection) -> Iterator[None]:
    """Wrap each test in a savepoint so tests don't leak state into each other."""
    with db_connection.transaction(force_rollback=True):
        yield
