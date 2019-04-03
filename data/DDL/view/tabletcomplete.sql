DROP VIEW IF EXISTS tabletcomplete
;
CREATE VIEW IF NOT EXISTS tabletcomplete(
  user_id,
  user_distinct,
  user_name,
  user_refine_count,
  total_refine_count,
  refine_date
) AS
SELECT
  *
FROM
  (
    SELECT
      *
    FROM
      tabletcomplete_past
    UNION ALL
    SELECT
      user_id,
      user_distinct,
      user_name,
      user_refine_count,
      refine_seq,
      refine_date
    FROM
      tabletrefine
    WHERE
      refine_result = 10
  )
ORDER BY
  date(
    refine_date
  )
;
