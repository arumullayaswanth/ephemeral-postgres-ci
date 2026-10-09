"""Database connection configuration, sourced from environment variables.

Two logical connections exist:

* The *admin* connection targets a maintenance database (PGADMINDB, usually
  ``postgres``) and is only used to CREATE/DROP the ephemeral database.
* The *app* connection targets the ephemeral database itself (PGDATABASE) and
  is what migrations and tests run against.
"""

from __future__ import annotations

import os
from dataclasses import dataclass


def _require(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(
            f"Missing required environment variable: {name}. "
            "Copy .env.example to .env or set it in the CI environment."
        )
    return value


@dataclass(frozen=True)
class DbConfig:
    host: str
    port: int
    user: str
    password: str
    dbname: str

    def conninfo(self) -> str:
        """Return a libpq connection string for this configuration."""
        return (
            f"host={self.host} port={self.port} "
            f"user={self.user} password={self.password} dbname={self.dbname}"
        )


def _base() -> dict:
    return {
        "host": _require("PGHOST"),
        "port": int(os.environ.get("PGPORT", "5432")),
        "user": _require("PGUSER"),
        "password": _require("PGPASSWORD"),
    }


def admin_config() -> DbConfig:
    """Connection used only for CREATE/DROP DATABASE statements."""
    return DbConfig(dbname=os.environ.get("PGADMINDB", "postgres"), **_base())


def app_config() -> DbConfig:
    """Connection to the ephemeral database used by migrations and tests."""
    return DbConfig(dbname=_require("PGDATABASE"), **_base())
