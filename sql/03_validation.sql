-- Validation of mart_user against the raw export.

-- Coverage: mart rows = raw installs; gap to all users = installed before the export started
SELECT
  (SELECT COUNT(*) FROM `YOUR_PROJECT.floodit.mart_user`)   AS mart_users,
  (SELECT COUNT(DISTINCT user_pseudo_id)
   FROM `firebase-public-project.analytics_153293282.events_*`
   WHERE event_name = 'first_open')                         AS raw_installs,
  (SELECT COUNT(DISTINCT user_pseudo_id)
   FROM `firebase-public-project.analytics_153293282.events_*`) AS all_users;

-- Reinstalls: players with more than one first_open
SELECT COUNTIF(n > 1) AS players_with_reinstall
FROM (
  SELECT user_pseudo_id, COUNT(*) AS n
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_name = 'first_open'
  GROUP BY user_pseudo_id
);

-- Source mix among installed players
SELECT source, medium, COUNT(*) AS installs
FROM `YOUR_PROJECT.floodit.mart_user`
GROUP BY source, medium
ORDER BY installs DESC;
