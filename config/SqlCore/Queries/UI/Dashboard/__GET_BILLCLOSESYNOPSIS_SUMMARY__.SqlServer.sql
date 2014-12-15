--Get Interval Data
DECLARE @id_interval int
DECLARE @BillGroupCount int

SET @id_interval = %%ID_USAGE_INTERVAL%% --set interval here
SET @BillGroupCount = (SELECT COUNT(*) FROM t_billgroup_materialization WHERE id_usage_interval = @id_interval)

SELECT
 -- CASE DAY(ui.dt_end)
   --      WHEN '5' THEN 'M5'
     --    WHEN '12' THEN 'M12'
     --    WHEN '19' THEN 'M19'
     --    WHEN '26' THEN 'M26'
     --    ELSE 'EOM'
     -- END AS [Type],
      @BillGroupCount AS [BillGroups],
      ui.id_interval AS [IntervalID],
      ui.dt_start AS [Start],
      ui.dt_end AS [End],
      tx_interval_status [Interval_Status], 
      DATEDIFF(day, GETDATE(), ui.dt_end) AS [Days_Until_Run]             
FROM t_usage_interval ui
WHERE ui.id_interval = @id_interval;
