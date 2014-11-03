--Get Interval Data
	SELECT
      CASE extract(day from ui.dt_end)
         WHEN 5 THEN 'M5'
         WHEN 12 THEN 'M12'
         WHEN 19 THEN 'M19'
         WHEN 26 THEN 'M26'
         ELSE 'EOM'
      END AS "type",
      (select COUNT(*) from t_billgroup_materialization where id_usage_interval = %%ID_USAGE_INTERVAL%%) as BillGroups,
      ui.id_interval AS IntervalID,
      ui.dt_start AS "start",
      ui.dt_end AS "end",
      tx_interval_status AS Interval_Status, 
      TRUNC(ui.dt_end - GETUTCDATE()) + 1 AS Days_Until_Run
      from t_usage_interval ui
      where ui.id_interval = %%ID_USAGE_INTERVAL%%