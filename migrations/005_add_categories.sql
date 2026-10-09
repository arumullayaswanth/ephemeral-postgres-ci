-- Use case: product categories, with a nullable category on widgets.

CREATE TABLE IF NOT EXISTS category (
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

INSERT INTO category (name)
SELECT v.name
FROM (VALUES ('hardware'), ('tools'), ('fasteners')) AS v(name)
WHERE NOT EXISTS (SELECT 1 FROM category);

-- Link widgets to categories (added as a nullable column).
ALTER TABLE widget ADD COLUMN IF NOT EXISTS category_id INTEGER REFERENCES category(id);

UPDATE widget w
SET category_id = c.id
FROM category c
WHERE c.name = 'fasteners'
  AND w.name IN ('bolt', 'nut', 'flange', 'grommet')
  AND w.category_id IS NULL;
