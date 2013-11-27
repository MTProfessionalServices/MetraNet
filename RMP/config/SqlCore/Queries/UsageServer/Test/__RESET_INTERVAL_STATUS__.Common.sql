
/* ===========================================================
Reset intervals to Open.
============================================================== */
/* update the interval status for test intervals to 'O' */
UPDATE t_usage_interval
  SET tx_interval_status = 'O'
where id_interval in (
  select ui.id_interval
  FROM t_usage_interval ui
  INNER JOIN t_usage_cycle uc  
    ON uc.id_usage_cycle = ui.id_usage_cycle  
  INNER JOIN t_usage_cycle_type uct  
    ON uct.id_cycle_type = uc.id_cycle_type
  where (%%USAGE_PREDICATE%%)
  )
