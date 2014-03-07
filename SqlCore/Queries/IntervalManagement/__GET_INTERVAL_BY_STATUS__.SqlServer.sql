SELECT
    ui.id_interval IntervalID,
	uc.id_cycle_type CycleType,
    ui.dt_start StartDate,
    ui.dt_end EndDate,
    isnull(billingGroups.TotalGroupCount, 0) TotalGroupCount, 
    uc.id_usage_cycle CycleID,
    (CASE WHEN materialization.id_usage_interval IS NULL THEN 'N' ELSE 'Y' END) HasBeenMaterialized,
    ui.tx_interval_status Status
  FROM t_usage_interval ui
  /* get cycle type name */
  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle  
  /* get full materialization information */
  LEFT OUTER JOIN  
  (
     SELECT DISTINCT(id_usage_interval)
     FROM t_billgroup_materialization bm
     WHERE bm.tx_type = 'Full'
  ) materialization ON materialization.id_usage_interval = ui.id_interval
  /* get total billing groups */
  LEFT OUTER JOIN
  (
     SELECT id_usage_interval, COUNT (id_billgroup) TotalGroupCount
     FROM t_billgroup
     GROUP BY id_usage_interval
  )  billingGroups ON billingGroups.id_usage_interval = ui.id_interval
