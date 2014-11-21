--Get Interval Data
	SELECT
      --CASE extract(day from ui.dt_end)
       --  WHEN 5 THEN 'M5'
       --  WHEN 12 THEN 'M12'
       --  WHEN 19 THEN 'M19'
       --  WHEN 26 THEN 'M26'
       --  ELSE 'EOM'
     -- END AS "type",
      (SELECT COUNT(*) FROM t_billgroup_materialization WHERE id_usage_interval = %%ID_USAGE_INTERVAL%%) AS BillGroups,
      ui.id_interval AS IntervalID,
      ui.dt_start AS "start",
      ui.dt_end AS "end",
      tx_interval_status AS Interval_Status, 
      TRUNC(ui.dt_end - (TRUNC(SYSDATE+1) - 1/60/60/24)) AS Days_Until_Run      
  FROM t_usage_interval ui
  WHERE ui.id_interval = %%ID_USAGE_INTERVAL%%