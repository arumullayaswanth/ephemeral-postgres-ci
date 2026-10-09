# tests

Integration tests run against the ephemeral database by `pytest`.

| File                   | Purpose                                                   |
| ---------------------- | --------------------------------------------------------- |
| `test_integration.py`  | The actual tests (query/assert against the database)      |
| `conftest.py`          | pytest fixtures: DB connection + per-test rollback        |
| `__init__.py`          | Marks `tests` as a Python package                         |
