-- Example: customers table + data. Uncomment to enable during testing.

-- CREATE TABLE IF NOT EXISTS customer (
--     id    SERIAL PRIMARY KEY,
--     name  TEXT NOT NULL,
--     email TEXT NOT NULL UNIQUE
-- );

-- INSERT INTO customer (name, email)
-- SELECT v.name, v.email
-- FROM (VALUES
--     ('Alice', 'alice@example.com'),
--     ('Bob',   'bob@example.com'),
--     ('Carol', 'carol@example.com')
-- ) AS v(name, email)
-- WHERE NOT EXISTS (SELECT 1 FROM customer);
