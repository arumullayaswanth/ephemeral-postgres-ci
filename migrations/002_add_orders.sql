-- Example: orders table. Uncomment to enable during testing.

-- CREATE TABLE IF NOT EXISTS orders (
--     id         SERIAL PRIMARY KEY,
--     widget_id  INTEGER NOT NULL REFERENCES widget(id),
--     quantity   INTEGER NOT NULL CHECK (quantity > 0),
--     created_at TIMESTAMPTZ NOT NULL DEFAULT now()
-- );

-- INSERT INTO orders (widget_id, quantity)
-- SELECT w.id, 2
-- FROM widget w
-- WHERE w.name = 'gadget'
--   AND NOT EXISTS (SELECT 1 FROM orders);
