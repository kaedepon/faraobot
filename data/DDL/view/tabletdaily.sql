DROP VIEW IF EXISTS tabletdaily
;
CREATE VIEW IF NOT EXISTS tabletdaily(
  refine_date,
  daily_refine_count,
  total_refine_count,
  daily_refine01,
  daily_refine02,
  daily_refine03,
  daily_refine04,
  daily_refine05,
  daily_refine06,
  daily_refine07,
  daily_refine08,
  daily_refine09,
  daily_refine10,
  total_refine01,
  total_refine02,
  total_refine03,
  total_refine04,
  total_refine05,
  total_refine06,
  total_refine07,
  total_refine08,
  total_refine09,
  total_refine10
) AS
SELECT
  A.refine_date,
  MAX(
    A.daily_refine_count
  ),
  MAX(
    A.total_refine_count
  ),
  MAX(
    A.refine01
  ),
  MAX(
    A.refine02
  ),
  MAX(
    A.refine03
  ),
  MAX(
    A.refine04
  ),
  MAX(
    A.refine05
  ),
  MAX(
    A.refine06
  ),
  MAX(
    A.refine07
  ),
  MAX(
    A.refine08
  ),
  MAX(
    A.refine09
  ),
  MAX(
    A.refine10
  ),
  SUM(
    B.refine01
  ),
  SUM(
    B.refine02
  ),
  SUM(
    B.refine03
  ),
  SUM(
    B.refine04
  ),
  SUM(
    B.refine05
  ),
  SUM(
    B.refine06
  ),
  SUM(
    B.refine07
  ),
  SUM(
    B.refine08
  ),
  SUM(
    B.refine09
  ),
  SUM(
    B.refine10
  )
FROM
  (
    SELECT
      strftime('%Y/%m/%d', refine_date) refine_date,
      COUNT(*) daily_refine_count,
      MAX(refine_seq) total_refine_count,
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
      strftime('%Y/%m/%d', refine_date)
  ) A
  INNER JOIN
    (
      SELECT
        strftime('%Y/%m/%d', refine_date) refine_date,
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
        strftime('%Y/%m/%d', refine_date)
      UNION ALL
      SELECT
        strftime('%Y/%m/%d', refine_date),
        daily_refine01,
        daily_refine02,
        daily_refine03,
        daily_refine04,
        daily_refine05,
        daily_refine06,
        daily_refine07,
        daily_refine08,
        daily_refine09,
        daily_refine10
      FROM
        tabletdaily_past
    ) B
  ON  A.refine_date >= B.refine_date
GROUP BY
  A.refine_date
;
