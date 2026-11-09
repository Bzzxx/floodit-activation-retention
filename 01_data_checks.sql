-- Data checks on the raw GA4 export, run before building anything.

-- Which events exist and which carry revenue
SELECT
  event_name,
  COUNT(*)                          AS events,
  COUNT(DISTINCT user_pseudo_id)    AS users,
  ROUND(SUM(event_value_in_usd), 2) AS usd
FROM `firebase-public-project.analytics_153293282.events_*`
GROUP BY event_name
ORDER BY users DESC;

-- Acquisition sources (first touch)
SELECT
  traffic_source.source             AS source,
  traffic_source.medium             AS medium,
  COUNT(DISTINCT user_pseudo_id)    AS users
FROM `firebase-public-project.analytics_153293282.events_*`
GROUP BY source, medium
ORDER BY users DESC;
