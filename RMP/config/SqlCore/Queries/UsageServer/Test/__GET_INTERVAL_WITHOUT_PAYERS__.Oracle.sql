
/* ===========================================================
Get an interval that has no payers and this is not hard closed
============================================================== */
select * from (
  SELECT id_interval   
  FROM t_usage_interval ui  
  WHERE NOT EXISTS (
        SELECT 1
        FROM vw_paying_accounts pa
        WHERE pa.IntervalID = ui.id_interval)
  AND  
  ui.id_interval IN (%%INTERVAL_LIST%%) AND
  ui.tx_interval_status <> 'H') tmp
where rownum <= 1      
 