DROP VIEW IF EXISTS faraodaily
;
CREATE VIEW IF NOT EXISTS faraodaily(
  hunt_date,
  daily_hunt_count,
  total_hunt_count,
  daily_drop01,
  daily_drop02,
  daily_drop03,
  daily_drop04,
  daily_drop05,
  daily_drop06,
  daily_drop07,
  daily_drop08,
  daily_drop09,
  daily_drop10,
  daily_drop11,
  daily_drop12,
  daily_drop13,
  daily_drop14,
  daily_drop15,
  daily_drop16,
  daily_drop17,
  daily_drop18,
  daily_drop19,
  daily_drop20,
  total_drop01,
  total_drop02,
  total_drop03,
  total_drop04,
  total_drop05,
  total_drop06,
  total_drop07,
  total_drop08,
  total_drop09,
  total_drop10,
  total_drop11,
  total_drop12,
  total_drop13,
  total_drop14,
  total_drop15,
  total_drop16,
  total_drop17,
  total_drop18,
  total_drop19,
  total_drop20
) AS
SELECT
  A.hunt_date,
  MAX(
    A.daily_hunt_count
  ),
  MAX(
    A.total_hunt_count
  ),
  MAX(
    A.drop01
  ),
  MAX(
    A.drop02
  ),
  MAX(
    A.drop03
  ),
  MAX(
    A.drop04
  ),
  MAX(
    A.drop05
  ),
  MAX(
    A.drop06
  ),
  MAX(
    A.drop07
  ),
  MAX(
    A.drop08
  ),
  MAX(
    A.drop09
  ),
  MAX(
    A.drop10
  ),
  MAX(
    A.drop11
  ),
  MAX(
    A.drop12
  ),
  MAX(
    A.drop13
  ),
  MAX(
    A.drop14
  ),
  MAX(
    A.drop15
  ),
  MAX(
    A.drop16
  ),
  MAX(
    A.drop17
  ),
  MAX(
    A.drop18
  ),
  MAX(
    A.drop19
  ),
  MAX(
    A.drop20
  ),
  SUM(
    B.drop01
  ),
  SUM(
    B.drop02
  ),
  SUM(
    B.drop03
  ),
  SUM(
    B.drop04
  ),
  SUM(
    B.drop05
  ),
  SUM(
    B.drop06
  ),
  SUM(
    B.drop07
  ),
  SUM(
    B.drop08
  ),
  SUM(
    B.drop09
  ),
  SUM(
    B.drop10
  ),
  SUM(
    B.drop11
  ),
  SUM(
    B.drop12
  ),
  SUM(
    B.drop13
  ),
  SUM(
    B.drop14
  ),
  SUM(
    B.drop15
  ),
  SUM(
    B.drop16
  ),
  SUM(
    B.drop17
  ),
  SUM(
    B.drop18
  ),
  SUM(
    B.drop19
  ),
  SUM(
    B.drop20
  )
FROM
  (
    SELECT
      strftime('%Y/%m/%d', hunt_date) hunt_date,
      COUNT(*) daily_hunt_count,
      MAX(hunt_seq) total_hunt_count,
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
      strftime('%Y/%m/%d', hunt_date)
  ) A
  INNER JOIN
    (
      SELECT
        strftime('%Y/%m/%d', hunt_date) hunt_date,
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
        faraohunt
      UNION ALL
      SELECT
        strftime('%Y/%m/%d', hunt_date) hunt_date,
        daily_drop01,
        daily_drop02,
        daily_drop03,
        daily_drop04,
        daily_drop05,
        daily_drop06,
        daily_drop07,
        daily_drop08,
        daily_drop09,
        daily_drop10,
        daily_drop11,
        daily_drop12,
        daily_drop13,
        daily_drop14,
        daily_drop15,
        daily_drop16,
        daily_drop17,
        daily_drop18,
        daily_drop19,
        daily_drop20
      FROM
        faraodaily_past
    ) B
  ON  A.hunt_date >= B.hunt_date
GROUP BY
  A.hunt_date
;
