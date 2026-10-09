-- First schema + data.
-- Applied to the ephemeral database before tests run.

-- === Table ===
CREATE TABLE IF NOT EXISTS widget (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL DEFAULT 0
);

-- === Initial data ===
INSERT INTO widget (name, price)
SELECT v.name, v.price
FROM (VALUES
    ('gadget', 9.99),
    ('gizmo', 19.50),
    ('doohickey', 4.25)
    ,('sprocket', 7.75)
    ,('cog', 3.10)
    ,('widget-pro', 29.99)
    ,('bolt', 0.50)
    ,('nut', 0.25)
    ,('flange', 12.00)
    ,('grommet', 1.99)
) AS v(name, price)
WHERE NOT EXISTS (SELECT 1 FROM widget);

-- === More records as standalone inserts (uncomment to add) ===
INSERT INTO widget (name, price) VALUES ('sprocket', 7.75);
INSERT INTO widget (name, price) VALUES ('cog', 3.10);
INSERT INTO widget (name, price) VALUES ('widget-pro', 29.99);
INSERT INTO widget (name, price) VALUES ('bolt', 0.50);
INSERT INTO widget (name, price) VALUES ('nut', 0.25);
INSERT INTO widget (name, price) VALUES ('flange', 12.00);
INSERT INTO widget (name, price) VALUES ('grommet', 1.99);
