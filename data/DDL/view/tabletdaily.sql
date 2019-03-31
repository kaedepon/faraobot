DROP VIEW IF EXISTS tabletdaily
;
CREATE VIEW IF NOT EXISTS tabletdaily(
  refine_date,
  daily_refine_count,
  total_refine_count,
  refine01,
  refine02,
  refine03,
  refine04,
  refine05,
  refine06,
  refine07,
  refine08,
  refine09,
  refine10
) AS
SELECT
  strftime(
    '%Y/%m/%d',
    refine_date
  ),
  COUNT(*),
  MAX(
    refine_seq
  ),
  SUM(
    CASE
      WHEN refine_result = 1 THEN 1
      ELSE 0
    END
  ) refine01,
  SUM(
    CASE
      WHEN refine_result = 2 THEN 1
      ELSE 0
    END
  ) refine02,
  SUM(
    CASE
      WHEN refine_result = 3 THEN 1
      ELSE 0
    END
  ) refine03,
  SUM(
    CASE
      WHEN refine_result = 4 THEN 1
      ELSE 0
    END
  ) refine04,
  SUM(
    CASE
      WHEN refine_result = 5 THEN 1
      ELSE 0
    END
  ) refine05,
  SUM(
    CASE
      WHEN refine_result = 6 THEN 1
      ELSE 0
    END
  ) refine06,
  SUM(
    CASE
      WHEN refine_result = 7 THEN 1
      ELSE 0
    END
  ) refine07,
  SUM(
    CASE
      WHEN refine_result = 8 THEN 1
      ELSE 0
    END
  ) refine08,
  SUM(
    CASE
      WHEN refine_result = 9 THEN 1
      ELSE 0
    END
  ) refine09,
  SUM(
    CASE
      WHEN refine_result = 10 THEN 1
      ELSE 0
    END
  ) refine10
FROM
  tabletrefine
GROUP BY
  strftime(
    '%Y/%m/%d',
    refine_date
  )
;
