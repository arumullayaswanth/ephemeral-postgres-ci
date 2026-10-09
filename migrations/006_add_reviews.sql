-- Use case: customer reviews of widgets (1-5 rating).

CREATE TABLE IF NOT EXISTS review (
    id          SERIAL PRIMARY KEY,
    widget_id   INTEGER NOT NULL REFERENCES widget(id),
    customer_id INTEGER NOT NULL REFERENCES customer(id),
    rating      INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment     TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (widget_id, customer_id)
);

INSERT INTO review (widget_id, customer_id, rating, comment)
SELECT w.id, c.id, v.rating, v.comment
FROM (VALUES
    ('gadget',     'alice@example.com', 5, 'Works great'),
    ('gizmo',      'bob@example.com',   4, 'Pretty good'),
    ('widget-pro', 'carol@example.com', 3, 'It is okay')
) AS v(widget_name, email, rating, comment)
JOIN widget   w ON w.name  = v.widget_name
JOIN customer c ON c.email = v.email
WHERE NOT EXISTS (SELECT 1 FROM review);
