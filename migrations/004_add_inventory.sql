-- Example: inventory table + data. Uncomment to enable during testing.

-- CREATE TABLE IF NOT EXISTS inventory (
--     id         SERIAL PRIMARY KEY,
--     widget_id  INTEGER NOT NULL REFERENCES widget(id),
--     warehouse  TEXT NOT NULL,
--     stock      INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0)
-- );

-- INSERT INTO inventory (widget_id, warehouse, stock)
-- SELECT w.id, v.warehouse, v.stock
-- FROM widget w
-- JOIN (VALUES
--     ('gadget',    'east', 100),
--     ('gizmo',     'west', 50),
--     ('doohickey', 'east', 25)
-- ) AS v(name, warehouse, stock) ON v.name = w.name
-- WHERE NOT EXISTS (SELECT 1 FROM inventory);
