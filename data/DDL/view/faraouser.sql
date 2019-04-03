DROP VIEW IF EXISTS faraouser
;
CREATE VIEW IF NOT EXISTS faraouser(
  user_id,
  user_distinct,
  user_name,
  level_name,
  experience,
  user_hunt_count,
  drop01,
  drop02,
  drop03,
  drop04,
  drop05,
  drop06,
  drop07,
  drop08,
  drop09,
  drop10,
  drop11,
  drop12,
  drop13,
  drop14,
  drop15,
  drop16,
  drop17,
  drop18,
  drop19,
  drop20
) AS
SELECT
  A.user_id,
  I.user_distinct,
  I.user_name,
  A.level_name,
  exp,
  user_hunt_count,
  drop01,
  drop02,
  drop03,
  drop04,
  drop05,
  drop06,
  drop07,
  drop08,
  drop09,
  drop10,
  drop11,
  drop12,
  drop13,
  drop14,
  drop15,
  drop16,
  drop17,
  drop18,
  drop19,
  drop20
FROM
  (
    SELECT
      *,
      MIN(exp_seq) AS exp_seq
    FROM
      (
        SELECT
          user_id,
          MAX(user_hunt_count) * 116805 AS exp,
          SUM(user_hunt_count) user_hunt_count,
          SUM(drop01) drop01,
          SUM(drop02) drop02,
          SUM(drop03) drop03,
          SUM(drop04) drop04,
          SUM(drop05) drop05,
          SUM(drop06) drop06,
          SUM(drop07) drop07,
          SUM(drop08) drop08,
          SUM(drop09) drop09,
          SUM(drop10) drop10,
          SUM(drop11) drop11,
          SUM(drop12) drop12,
          SUM(drop13) drop13,
          SUM(drop14) drop14,
          SUM(drop15) drop15,
          SUM(drop16) drop16,
          SUM(drop17) drop17,
          SUM(drop18) drop18,
          SUM(drop19) drop19,
          SUM(drop20) drop20
        FROM
          (
            SELECT
              user_id,
              user_hunt_count,
              drop01,
              drop02,
              drop03,
              drop04,
              drop05,
              drop06,
              drop07,
              drop08,
              drop09,
              drop10,
              drop11,
              drop12,
              drop13,
              drop14,
              drop15,
              drop16,
              drop17,
              drop18,
              drop19,
              drop20
            FROM
              faraouser_past
            UNION ALL
            SELECT
              user_id,
              COUNT(*) user_hunt_count,
              SUM(drop01) drop01,
              SUM(drop02) drop02,
              SUM(drop03) drop03,
              SUM(drop04) drop04,
              SUM(drop05) drop05,
              SUM(drop06) drop06,
              SUM(drop07) drop07,
              SUM(drop08) drop08,
              SUM(drop09) drop09,
              SUM(drop10) drop10,
              SUM(drop11) drop11,
              SUM(drop12) drop12,
              SUM(drop13) drop13,
              SUM(drop14) drop14,
              SUM(drop15) drop15,
              SUM(drop16) drop16,
              SUM(drop17) drop17,
              SUM(drop18) drop18,
              SUM(drop19) drop19,
              SUM(drop20) drop20
            FROM
              faraohunt
            GROUP BY
              user_id
          )
        GROUP BY
          user_id
      )
      LEFT JOIN
        experience
      ON  THRESHOLD >= exp
    GROUP BY
      user_id
  ) A
  INNER JOIN
    experience B
  ON  A.exp_seq = B.exp_seq
  INNER JOIN
    userinfo I
  ON  A.user_id = I.user_id
;
