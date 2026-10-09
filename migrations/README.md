# migrations

SQL applied (in filename order) to the database: by `ci/migrate.py` for each
ephemeral CI database, and by the EC2 first-boot seed.

| File                   | Status            | Contents                       |
| ---------------------- | ----------------- | ------------------------------ |
| `001_init.sql`         | active            | `widget` table + seed rows     |
| `002_add_orders.sql`   | commented example | `orders` table + a row         |
| `003_add_customers.sql`| commented example | `customer` table + rows        |
| `004_add_inventory.sql`| commented example | `inventory` table + rows       |

The example files are fully commented out. Uncomment the parts you want to test,
then run the CI workflow. Add new schema/data as a new numbered file
(e.g. `005_...sql`).
