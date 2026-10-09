# migrations

SQL applied in filename order to the database: by `ci/migrate.py` for each
ephemeral CI database, and by the EC2 first-boot seed.

| File                     | Creates / changes                              |
| ------------------------ | ---------------------------------------------- |
| `001_init.sql`           | `widget` table + 10 rows                       |
| `002_add_customers.sql`  | `customer` table + 3 rows                      |
| `003_add_orders.sql`     | `orders` table (FKs to customer + widget)      |
| `004_add_inventory.sql`  | `inventory` table (stock per widget/warehouse) |
| `005_add_categories.sql` | `category` table + `widget.category_id` column |
| `006_add_reviews.sql`    | `review` table (customer ratings of widgets)   |

## Add a new use case

1. Add a new numbered file, e.g. `007_add_suppliers.sql`.
2. Reference existing tables with foreign keys as needed.
3. Make inserts idempotent (`WHERE NOT EXISTS ...`).
4. Add a matching test in `tests/test_integration.py`.
5. Commit, push, open a PR -> CI runs it on a fresh ephemeral DB.

Order matters: a table must be created before anything that references it.
