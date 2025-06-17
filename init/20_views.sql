CREATE OR REPLACE VIEW aggregate_view AS
SELECT
    m.id AS member_id,
    m.nickname,

    -- 当日の集計 (narrow)
    SUM(CASE WHEN l.wide = FALSE AND DATE_TRUNC('day', l.created_at) = DATE_TRUNC('day', CURRENT_DATE) THEN l.counts ELSE 0 END) AS today_narrow_sum_counts,
    MAX(CASE WHEN l.wide = FALSE AND DATE_TRUNC('day', l.created_at) = DATE_TRUNC('day', CURRENT_DATE) THEN l.counts ELSE 0 END) AS today_narrow_max_counts,
    -- 当日の集計 (wide)
    SUM(CASE WHEN l.wide = TRUE AND DATE_TRUNC('day', l.created_at) = DATE_TRUNC('day', CURRENT_DATE) THEN l.counts ELSE 0 END) AS today_wide_sum_counts,
    MAX(CASE WHEN l.wide = TRUE AND DATE_TRUNC('day', l.created_at) = DATE_TRUNC('day', CURRENT_DATE) THEN l.counts ELSE 0 END) AS today_wide_max_counts,

    -- 今週の集計 (narrow)
    SUM(CASE WHEN l.wide = FALSE AND DATE_TRUNC('week', l.created_at) = DATE_TRUNC('week', CURRENT_DATE) THEN l.counts ELSE 0 END) AS this_week_narrow_sum_counts,
    MAX(CASE WHEN l.wide = FALSE AND DATE_TRUNC('week', l.created_at) = DATE_TRUNC('week', CURRENT_DATE) THEN l.counts ELSE 0 END) AS this_week_narrow_max_counts,
    -- 今週の集計 (wide)
    SUM(CASE WHEN l.wide = TRUE AND DATE_TRUNC('week', l.created_at) = DATE_TRUNC('week', CURRENT_DATE) THEN l.counts ELSE 0 END) AS this_week_wide_sum_counts,
    MAX(CASE WHEN l.wide = TRUE AND DATE_TRUNC('week', l.created_at) = DATE_TRUNC('week', CURRENT_DATE) THEN l.counts ELSE 0 END) AS this_week_wide_max_counts,

    -- 全体の集計 (narrow)
    SUM(CASE WHEN l.wide = FALSE THEN l.counts ELSE 0 END) AS total_narrow_sum_counts,
    MAX(CASE WHEN l.wide = FALSE THEN l.counts ELSE 0 END) AS total_narrow_max_counts,
    -- 全体の集計 (wide)
    SUM(CASE WHEN l.wide = TRUE THEN l.counts ELSE 0 END) AS total_wide_sum_counts,
    MAX(CASE WHEN l.wide = TRUE THEN l.counts ELSE 0 END) AS total_wide_max_counts
    
FROM
    members m
LEFT JOIN
    logs l ON m.id = l.member_id
GROUP BY
    m.id,
    m.nickname;

-- 週間ごとの最大値の推移
CREATE OR REPLACE VIEW transition_max_view AS
SELECT
    m.id AS member_id,
    m.nickname,
    DATE_TRUNC('week', l.created_at)::DATE AS week_start_date,

    -- narrow
    MAX(CASE WHEN l.wide = FALSE THEN l.counts ELSE 0 END) AS max_narrow_counts,

    -- wide
    MAX(CASE WHEN l.wide = TRUE THEN l.counts ELSE 0 END) AS max_wide_counts


FROM
    logs l
JOIN
    members m ON m.id = l.member_id
GROUP BY
    m.id,
    m.nickname,
    week_start_date;
