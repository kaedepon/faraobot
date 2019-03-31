DROP VIEW IF EXISTS tabletuser
;
CREATE VIEW IF NOT EXISTS tabletuser(
  user_id,
  user_distinct,
  user_name,
  user_refine_count,
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
  A.user_id,
  B.user_distinct,
  B.user_name,
  user_refine_count,
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
FROM
  (
    SELECT
      user_id,
      SUM(user_refine_count) user_refine_count,
      SUM(refine01) refine01,
      SUM(refine02) refine02,
      SUM(refine03) refine03,
      SUM(refine04) refine04,
      SUM(refine05) refine05,
      SUM(refine06) refine06,
      SUM(refine07) refine07,
      SUM(refine08) refine08,
      SUM(refine09) refine09,
      SUM(refine10) refine10
    FROM
      (
        SELECT
          user_id,
          COUNT(*) user_refine_count,
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
          user_id
        UNION ALL
        SELECT
          user_id,
          COUNT(*) user_refine_count,
          0 refine01,
          0 refine02,
          0 refine03,
          0 refine04,
          0 refine05,
          0 refine06,
          0 refine07,
          0 refine08,
          0 refine09,
          COUNT(*) refine10
        FROM
          tabletcomplete_past
        GROUP BY
          user_id
      )
    GROUP BY
      user_id
  ) A
  INNER JOIN
    userinfo B
  ON  A.user_id = B.user_id
;
