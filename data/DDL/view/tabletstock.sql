DROP VIEW IF EXISTS tabletstock
;
CREATE VIEW IF NOT EXISTS tabletstock(
  refine_date,
  user_id,
  user_distinct,
  user_name,
  refine_limit,
  refine_stock,
  daily_user_refine_count,
  user_refine_count
) AS
SELECT
  A.refine_date,
  B.user_id,
  C.user_distinct,
  C.user_name,
  A.refine_limit,
  (
    A.refine_limit - B.daily_user_refine_count
  ),
  B.daily_user_refine_count,
  B.user_refine_count
FROM
  tabletlimit A
  INNER JOIN
    (
      SELECT
        strftime('%Y/%m/%d', refine_date) refine_date,
        user_id,
        COUNT(*) daily_user_refine_count,
        MAX(user_refine_count) user_refine_count
      FROM
        tabletrefine
      GROUP BY
        strftime('%Y/%m/%d', refine_date),
        user_id
    ) B
  ON  A.refine_date = B.refine_date
  INNER JOIN
    userinfo C
  ON  B.user_id = C.user_id
;
