-- mart_user: one row per player who installed during the export (has a first_open event).
-- install day = day 0. Retention = any event on exactly day N.
-- mature_d7 = install happened at least 7 days before the data ends, so day 7 is observable.
-- Replace YOUR_PROJECT. Dataset `floodit` must be in location US.

CREATE OR REPLACE TABLE `YOUR_PROJECT.floodit.mart_user` AS
WITH events AS (
  SELECT
    user_pseudo_id,
    event_name,
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
    LOWER(traffic_source.source)            AS source,
    LOWER(traffic_source.medium)            AS medium,
    geo.country                             AS country,
    device.operating_system                 AS os
  FROM `firebase-public-project.analytics_153293282.events_*`
),

installs AS (
  SELECT
    user_pseudo_id,
    MIN(event_date)     AS install_date,
    ANY_VALUE(source)   AS source,
    ANY_VALUE(medium)   AS medium,
    ANY_VALUE(country)  AS country,
    ANY_VALUE(os)       AS os
  FROM events
  WHERE event_name = 'first_open'
  GROUP BY user_pseudo_id
),

data_end AS (
  SELECT MAX(event_date) AS last_date
  FROM events
),

player_days AS (
  SELECT
    i.*,
    e.event_name,
    DATE_DIFF(e.event_date, i.install_date, DAY) AS day_n
  FROM installs AS i
  JOIN events AS e USING (user_pseudo_id)
)

SELECT
  p.user_pseudo_id,
  ANY_VALUE(p.install_date)                                         AS install_date,
  ANY_VALUE(p.source)                                               AS source,
  ANY_VALUE(p.medium)                                               AS medium,
  ANY_VALUE(p.country)                                              AS country,
  ANY_VALUE(p.os)                                                   AS os,
  MAX(IF(p.day_n = 1, 1, 0))                                        AS ret_d1,
  MAX(IF(p.day_n = 7, 1, 0))                                        AS ret_d7,
  COUNTIF(p.day_n = 0 AND p.event_name = 'level_complete_quickplay') AS levels_completed_d0,
  COUNTIF(p.day_n = 0 AND p.event_name = 'session_start')           AS sessions_d0,
  MAX(IF(p.day_n = 0 AND p.event_name = 'post_score', 1, 0))        AS posted_score_d0,
  ANY_VALUE(p.install_date)
    <= DATE_SUB(ANY_VALUE(d.last_date), INTERVAL 7 DAY)             AS mature_d7
FROM player_days AS p
CROSS JOIN data_end AS d
GROUP BY p.user_pseudo_id;
