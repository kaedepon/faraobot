DROP VIEW IF EXISTS tabletlimit
;
CREATE VIEW IF NOT EXISTS tabletlimit(
  refine_date,
  refine_limit
) AS
SELECT
  refine_date,
  SUM(
    refine_limit
  )
FROM
  (
    SELECT
      strftime('%Y/%m/%d', refine_date) refine_date,
      refine_limit
    FROM
      tabletlimit_bonus
    UNION ALL
    SELECT
      strftime('%Y/%m/%d', hunt_date),
      drop04 refine_limit
    FROM
      faraohunt
  )
GROUP BY
  refine_date
;
