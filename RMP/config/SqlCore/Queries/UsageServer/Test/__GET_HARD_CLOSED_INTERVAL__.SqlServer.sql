
/* ===========================================================
Get an interval with paying accounts that is hard closed
============================================================== */
SELECT TOP 1 id_interval   
FROM t_usage_interval ui  
INNER JOIN vw_paying_accounts pa
   ON pa.IntervalID = ui.id_interval
WHERE ui.id_interval IN (%%INTERVAL_LIST%%) AND
            ui.tx_interval_status = 'H'
 