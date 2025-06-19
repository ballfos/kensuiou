-- Random なダミーデータを挿入
INSERT INTO logs (member_id, counts, wide, created_at) 
SELECT
    (SELECT id FROM members LIMIT 1 OFFSET MOD(i, (SELECT COUNT(*) FROM members))),
    CEIL(RANDOM() * 8),  -- counts: 1 to 8
    RANDOM() < 0.5,      -- wide: true or false
    NOW() - INTERVAL '1 week' * (RANDOM() * 52)
FROM
    generate_series(1, 100) AS i
ON CONFLICT (id) DO NOTHING;

