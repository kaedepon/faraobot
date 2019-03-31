DROP VIEW IF EXISTS faraocard
;
CREATE VIEW IF NOT EXISTS faraocard(
  user_id,
  user_distinct,
  user_name,
  user_hunt_count,
  total_hunt_count,
  hunt_date
) AS
SELECT
  user_id,
  user_distinct,
  user_name,
  user_hunt_count,
  total_hunt_count,
  hunt_date
FROM
  (
    SELECT
      *
    FROM
      faraocard_past
    UNION ALL
    SELECT
      user_id,
      user_distinct,
      user_name,
      user_hunt_count,
      hunt_seq,
      hunt_date
    FROM
      faraohunt
    WHERE
      drop08 > 0
  )
ORDER BY
  date(
    hunt_date
  )
;
