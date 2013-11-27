
/* ===========================================================
Get an interval that has not been materialized and that is
not hard closed.
============================================================== */
SELECT TOP 1 id_interval   
FROM t_usage_interval ui 
INNER JOIN vw_paying_accounts pa
  ON pa.IntervalId = ui.id_interval
WHERE NOT EXISTS (SELECT 1  
                  FROM t_billgroup_materialization bm  
                  WHERE bm.tx_type = 'Full' AND  
                  bm.id_usage_interval = ui.id_interval) AND
      NOT EXISTS (SELECT 1  
                  FROM t_billgroup_materialization bm  
                  WHERE bm.tx_status = 'InProgress' AND  
                  bm.id_usage_interval = ui.id_interval)
AND  
ui.id_interval IN (%%INTERVAL_LIST%%) AND
ui.tx_interval_status <> 'H'
ORDER BY ui.id_interval
 