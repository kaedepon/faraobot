DROP VIEW IF EXISTS userinfo
;
CREATE VIEW IF NOT EXISTS userinfo(
  user_id,
  user_distinct,
  user_name
) AS
SELECT
  A.user_id,
  A.user_distinct,
  A.user_name
FROM
  (
    SELECT
      user_id,
      user_distinct,
      user_name,
      hunt_date action_date
    FROM
      faraohunt
    UNION ALL
    SELECT
      user_id,
      user_distinct,
      user_name,
      date(0) action_date
    FROM
      faraouser_past
    UNION ALL
    SELECT
      user_id,
      user_distinct,
      user_name,
      refine_date action_date
    FROM
      tabletrefine
    UNION ALL
    SELECT
      user_id,
      user_distinct,
      user_name,
      refine_date action_date
    FROM
      tabletcomplete_past
  ) A
  INNER JOIN
    (
      SELECT
        user_id,
        MAX(action_date) action_date
      FROM
        (
          SELECT
            user_id,
            hunt_date action_date
          FROM
            faraohunt
          UNION ALL
          SELECT
            user_id,
            date(0) action_date
          FROM
            faraouser_past
          UNION ALL
          SELECT
            user_id,
            refine_date action_date
          FROM
            tabletrefine
          UNION ALL
          SELECT
            user_id,
            refine_date action_date
          FROM
            tabletcomplete_past
        )
      GROUP BY
        user_id
    ) B
  ON  A.user_id = B.user_id
  AND A.action_date = B.action_date
;
