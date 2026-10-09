-- Use case: orders placed by customers for widgets.

CREATE TABLE IF NOT EXISTS orders (
    id          SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(id),
    widget_id   INTEGER NOT NULL REFERENCES widget(id),
    quantity    INTEGER NOT NULL CHECK (quantity > 0),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO orders (customer_id, widget_id, quantity)
SELECT c.id, w.id, v.qty
FROM (VALUES
    ('alice@example.com', 'gadget',     2),
    ('bob@example.com',   'gizmo',      1),
    ('carol@example.com', 'widget-pro', 5)
) AS v(email, widget_name, qty)
JOIN customer c ON c.email = v.email
JOIN widget   w ON w.name  = v.widget_name
WHERE NOT EXISTS (SELECT 1 FROM orders);
