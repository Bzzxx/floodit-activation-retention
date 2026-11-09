-- Analysis on mart_user. Only players with an observable day 7 (mature_d7).

-- Day-1 and day-7 return by OS and country (groups with 100+ installs)
SELECT
  os,
  country,
  COUNT(*)              AS installs,
  ROUND(AVG(ret_d1), 3) AS ret_d1,
  ROUND(AVG(ret_d7), 3) AS ret_d7
FROM `YOUR_PROJECT.floodit.mart_user`
WHERE mature_d7
GROUP BY os, country
HAVING COUNT(*) >= 100
ORDER BY installs DESC;

-- Day-7 return by levels completed on install day
SELECT
  CASE
    WHEN levels_completed_d0 = 0  THEN '0'
    WHEN levels_completed_d0 <= 2 THEN '1-2'
    WHEN levels_completed_d0 <= 5 THEN '3-5'
    WHEN levels_completed_d0 <= 10 THEN '6-10'
    ELSE '11+'
  END                   AS levels_d0,
  COUNT(*)              AS players,
  ROUND(AVG(ret_d7), 3) AS ret_d7
FROM `YOUR_PROJECT.floodit.mart_user`
WHERE mature_d7
GROUP BY levels_d0
ORDER BY MIN(levels_completed_d0);

-- Candidate day-0 events: how common, and day-7 return with vs without
SELECT
  'levels_completed_d0 >= 3'                                  AS day0_event,
  ROUND(AVG(IF(levels_completed_d0 >= 3, 1, 0)), 3)           AS share_of_players,
  ROUND(AVG(IF(levels_completed_d0 >= 3, ret_d7, NULL)), 3)   AS ret_d7_with,
  ROUND(AVG(IF(levels_completed_d0 < 3, ret_d7, NULL)), 3)    AS ret_d7_without
FROM `YOUR_PROJECT.floodit.mart_user`
WHERE mature_d7

UNION ALL

SELECT
  'sessions_d0 >= 2',
  ROUND(AVG(IF(sessions_d0 >= 2, 1, 0)), 3),
  ROUND(AVG(IF(sessions_d0 >= 2, ret_d7, NULL)), 3),
  ROUND(AVG(IF(sessions_d0 < 2, ret_d7, NULL)), 3)
FROM `YOUR_PROJECT.floodit.mart_user`
WHERE mature_d7

UNION ALL

SELECT
  'posted_score_d0',
  ROUND(AVG(posted_score_d0), 3),
  ROUND(AVG(IF(posted_score_d0 = 1, ret_d7, NULL)), 3),
  ROUND(AVG(IF(posted_score_d0 = 0, ret_d7, NULL)), 3)
FROM `YOUR_PROJECT.floodit.mart_user`
WHERE mature_d7;
