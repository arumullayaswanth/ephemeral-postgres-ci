# src

Shared database connection code used by the CI scripts and tests.

| File          | Purpose                                                        |
| ------------- | -------------------------------------------------------------- |
| `config.py`   | Reads `PG*` env vars; builds admin and app connection settings |
| `db.py`       | Opens a connection to the database (used by tests)             |
| `__init__.py` | Marks `src` as a Python package                                |
