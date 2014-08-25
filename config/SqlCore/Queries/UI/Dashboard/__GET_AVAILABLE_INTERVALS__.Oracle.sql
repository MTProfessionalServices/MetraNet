SELECT ui.id_interval,
       TO_CHAR(dt_start, 'mm/dd/yyyy') dt_start,
       TO_CHAR(dt_end, 'mm/dd/yyyy') dt_end,
       ut.id_cycle_type as id_cycle_type
FROM   
  t_usage_interval ui
  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle
	INNER JOIN t_usage_cycle_type ut ON ut.id_cycle_type = uc.id_cycle_type
WHERE  ui.tx_interval_status in ('O', 'B')
ORDER BY
       ui.dt_end