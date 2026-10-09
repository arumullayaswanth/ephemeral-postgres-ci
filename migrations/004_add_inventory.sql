-- Use case: inventory stock per widget per warehouse.

CREATE TABLE IF NOT EXISTS inventory (
    id        SERIAL PRIMARY KEY,
    widget_id INTEGER NOT NULL REFERENCES widget(id),
    warehouse TEXT NOT NULL,
    stock     INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    UNIQUE (widget_id, warehouse)
);

INSERT INTO inventory (widget_id, warehouse, stock)
SELECT w.id, v.warehouse, v.stock
FROM (VALUES
    ('gadget',     'east', 100),
    ('gizmo',      'west', 50),
    ('doohickey',  'east', 25),
    ('widget-pro', 'west', 10)
) AS v(name, warehouse, stock)
JOIN widget w ON w.name = v.name
WHERE NOT EXISTS (SELECT 1 FROM inventory);
