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

-- 全ての週間
CREATE OR REPLACE VIEW all_weeks_view AS
SELECT
    generate_series(
        DATE_TRUNC('week', CURRENT_DATE - INTERVAL '52 weeks'),
        DATE_TRUNC('week', CURRENT_DATE),
        '1 week'::interval
    )::DATE AS week_start_date
;

-- メンバーと全ての週間の組み合わせ
CREATE OR REPLACE VIEW member_weekly_view AS
SELECT
    m.id AS member_id,
    m.nickname,
    awv.week_start_date
FROM
    members m
CROSS JOIN
    all_weeks_view awv
;

-- メンバーと全ての週間の組み合わせにログを結合
CREATE OR REPLACE VIEW weekly_aggregate_view AS
SELECT
    mwv.member_id,
    mwv.nickname,
    mwv.week_start_date,
    
    -- 週間の集計
    COALESCE(SUM(l.counts) FILTER (WHERE l.wide = FALSE), 0) AS narrow_sum_counts,
    COALESCE(MAX(l.counts) FILTER (WHERE l.wide = FALSE), 0) AS narrow_max_counts,
    COALESCE(SUM(l.counts) FILTER (WHERE l.wide = TRUE), 0) AS wide_sum_counts,
    COALESCE(MAX(l.counts) FILTER (WHERE l.wide = TRUE), 0) AS wide_max_counts,

    -- 週間の集計の累積
    -- SUM OVER
    SUM(COALESCE(SUM(l.counts) FILTER (WHERE l.wide = FALSE), 0)) OVER (PARTITION BY mwv.member_id ORDER BY mwv.week_start_date) AS narrow_cumulative_sum_counts,
    MAX(COALESCE(MAX(l.counts) FILTER (WHERE l.wide = FALSE), 0)) OVER (PARTITION BY mwv.member_id ORDER BY mwv.week_start_date) AS narrow_cumulative_max_counts,
    SUM(COALESCE(SUM(l.counts) FILTER (WHERE l.wide = TRUE), 0)) OVER (PARTITION BY mwv.member_id ORDER BY mwv.week_start_date) AS wide_cumulative_sum_counts,
    MAX(COALESCE(MAX(l.counts) FILTER (WHERE l.wide = TRUE), 0)) OVER (PARTITION BY mwv.member_id ORDER BY mwv.week_start_date) AS wide_cumulative_max_counts
FROM
    member_weekly_view mwv
LEFT JOIN
    logs l ON mwv.member_id = l.member_id
    AND DATE_TRUNC('week', l.created_at) = mwv.week_start_date
GROUP BY
    mwv.member_id,
    mwv.nickname,
    mwv.week_start_date
ORDER BY
    mwv.member_id,
    mwv.week_start_date
;
