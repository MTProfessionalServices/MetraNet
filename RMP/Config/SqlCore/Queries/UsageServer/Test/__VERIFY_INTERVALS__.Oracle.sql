
SELECT column_value as id_interval FROM table(dbo.CSVToInt('%%INTERVAL_IDS%%')) WHERE column_value NOT IN (SELECT id_interval FROM t_usage_interval)
/* ===========================================================
Return those intervals in %%INTERVAL_IDS%% which don't exist in t_usage_interval.
============================================================== */
       
 