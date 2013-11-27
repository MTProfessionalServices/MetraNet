
/* ===========================================================
Update the status of the given intervals to 'O' 
============================================================== */
UPDATE t_usage_interval
  SET tx_interval_status = 'O'
WHERE id_interval IN (%%INTERVALS%%) 
