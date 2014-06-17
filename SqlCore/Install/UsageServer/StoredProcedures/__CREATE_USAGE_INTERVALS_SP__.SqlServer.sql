CREATE PROC CreateUsageIntervals
(
  @dt_now   DATETIME,  -- the MetraTech system's date
  @pretend  INT,       -- if true doesn't create new intervals but returns what would have been created
  @n_count  INT OUTPUT -- the count of intervals created (or that would have been created)
)
AS

  BEGIN TRAN



  --
  -- PRECONDITIONS:
  --   Intervals and mappings will be created and backfilled as long as there
  --   is an entry for the account in t_acc_usage_cycle. Missing mappings will
  --   be detected and added.
  --   
  --   To update a billing cycle: t_acc_usage_cycle must be updated. Also the
  --   new interval the account is updating to must be created and the initial
  --   special update mapping must be made in t_acc_usage_interval - dt_effective
  --   must be set to the end date of the previous (old) interval. 
  --

  -- ensures that there is only one instance of this sproc executing right now
  DECLARE @result INT
  EXEC @result = sp_getapplock @Resource = 'CreateUsageIntervals', @LockMode = 'Exclusive'
  IF @result < 0
  BEGIN
      ROLLBACK
      RETURN
  END

  -- represents the end date that an interval must
  -- fall into to be considered 
  DECLARE @dt_end DATETIME
  DECLARE @dt_start DATETIME
  SELECT @dt_end = (@dt_now + n_adv_interval_creation), @dt_start = IsNull(dt_last_interval_creation, dbo.mtmaxdate()) FROM t_usage_server

if object_id('tempdb..#missing_intervals') is not null
drop table #missing_intervals

-- determines what usage intervals need to be added
-- ; on next line is not a typo, required for CTE on SQL server
  ;
  with my_cycles as
(
select
id_usage_cycle, min(CASE WHEN ac.dt_crt >= @dt_start THEN acc.vt_start WHEN acc.vt_start > @dt_start THEN acc.vt_start ELSE @dt_start END) vt_start, max(vt_end) vt_end
from t_acc_usage_cycle auc
inner join t_account_state acc on auc.id_acc = acc.id_acc
inner join t_account ac on ac.id_acc = auc.id_acc
and acc.status <> 'AR'
where 1=1
and (acc.vt_end > @dt_start or ac.dt_crt > @dt_start)
group by id_usage_cycle
)
select
pci.id_interval,
used.id_usage_cycle,
pci.dt_start,
pci.dt_end,
ui.tx_interval_status
into #missing_intervals
from my_cycles used
inner join t_pc_interval pci on pci.id_cycle = used.id_usage_cycle
and used.vt_start <= pci.dt_end
and used.vt_end >= pci.dt_start
left outer join t_usage_interval ui on ui.id_interval = pci.id_interval
where 1=1
and pci.dt_start <= @dt_end
;

  -- records how many intervals would be added
  SELECT @n_count = COUNT(1) FROM #missing_intervals where tx_interval_status is null

  -- associate accounts with intervals based on their cycle mapping
  -- this will detect missing mappings and add them
select
auc.id_acc,
ui.id_interval,
'O' tx_status,
NULL dt_effective
into #missing_mappings
from #missing_intervals ui
inner join t_acc_usage_cycle auc on ui.id_usage_cycle = auc.id_usage_cycle
inner join t_account_state acc on acc.id_acc = auc.id_acc
and acc.vt_start <= ui.dt_end
and acc.vt_end >= ui.dt_start
and acc.status <> 'AR'
left outer join t_acc_usage_interval aui on aui.id_acc = auc.id_acc and aui.id_usage_interval = ui.id_interval
where 1=1
and IsNull(ui.tx_interval_status, 'O') <> 'B'
and aui.id_acc is null
;

  -- only adds the new intervals and mappings if pretend is false
  IF ISNULL(@pretend, 0) = 0
  BEGIN
    
    -- adds the new intervals
    INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)
    SELECT id_interval, id_usage_cycle, dt_start, dt_end, tx_interval_status
    FROM #missing_intervals
	where tx_interval_status is null

    -- adds the new mappings
    INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
    SELECT id_acc, id_usage_interval, tx_status, dt_effective
    FROM #missing_mappings

    -- updates the last interval creation time, useful for debugging
    UPDATE t_usage_server SET dt_last_interval_creation = @dt_now
  END

  -- returns the added intervals
  SELECT * FROM #missing_intervals where tx_interval_status is null
  COMMIT
  