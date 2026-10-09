-- Use case: customers.

CREATE TABLE IF NOT EXISTS customer (
    id         SERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    email      TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO customer (name, email)
SELECT v.name, v.email
FROM (VALUES
    ('Alice Johnson', 'alice@example.com'),
    ('Bob Smith',     'bob@example.com'),
    ('Carol White',   'carol@example.com')
) AS v(name, email)
WHERE NOT EXISTS (SELECT 1 FROM customer);
