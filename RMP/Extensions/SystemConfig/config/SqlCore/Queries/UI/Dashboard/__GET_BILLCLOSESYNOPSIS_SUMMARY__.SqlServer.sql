--Get Interval Data
DECLARE @id_interval int
DECLARE @BillGroupCount int

set @id_interval = %%ID_USAGE_INTERVAL%% --set interval here
set @BillGroupCount = (select COUNT(*) from t_billgroup_materialization where id_usage_interval = @id_interval)
select CASE DAY(ui.dt_end)
         WHEN '5' THEN 'M5'
         WHEN '12' THEN 'M12'
         WHEN '19' THEN 'M19'
         WHEN '26' THEN 'M26'
         ELSE 'EOM'
      END as [Type],
      @BillGroupCount as [BillGroups],
      ui.id_interval as [IntervalID],
      CONVERT(VARCHAR(10), ui.dt_start, 101) as [Start],
      CONVERT(VARCHAR(10), ui.dt_end, 101) as [End],
      tx_interval_status [Interval_Status], DATEDIFF(day, GETUTCDATE(),
      ui.dt_end)+1 as [Days_Until_Run]
      from t_usage_interval ui
      where ui.id_interval = @id_interval;
