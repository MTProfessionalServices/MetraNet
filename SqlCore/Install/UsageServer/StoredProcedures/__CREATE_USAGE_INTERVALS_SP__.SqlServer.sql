
CREATE PROC CreateUsageIntervals
(
  @dt_now   DATETIME,  -- the MetraTech system's date
  @pretend  INT,       -- if true doesn't create new intervals but returns what would have been created
  @n_count  INT OUTPUT -- the count of intervals created (or that would have been created)
)
AS

  BEGIN TRAN

/*  
  -- debug mode --
  declare @dt_now datetime 
  select @dt_now = CAST('2/9/2003' AS DATETIME) --GetUTCDate()
  declare @pretend int
  select @pretend = null
  declare @n_count int
*/  

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
  SELECT @dt_end = (@dt_now + n_adv_interval_creation) FROM t_usage_server

  DECLARE @new_mappings TABLE
  (
    id_acc INT NOT NULL,
    id_usage_interval INT NOT NULL,
    tx_status VARCHAR(1)  
  )

if object_id('tempdb..#minstart') is not null
drop table #minstart

    SELECT 
      accstate.id_acc,
      -- if the usage cycle was updated, consider the time of update as the start date
      -- this prevents backfilling mappings for the previous cycle
      MIN(ISNULL(maxaui.dt_effective, accstate.vt_start)) dt_start,
      MAX(CASE WHEN vt_end > @dt_end THEN @dt_end ELSE vt_end END) dt_end
 into #minstart
    FROM t_account_state accstate
    LEFT OUTER JOIN 
    (
      SELECT 
        id_acc,
        MAX(CASE WHEN dt_effective IS NULL THEN NULL ELSE dbo.AddSecond(dt_effective) END) dt_effective
      FROM t_acc_usage_interval
      GROUP BY id_acc
    ) maxaui ON maxaui.id_acc = accstate.id_acc
    WHERE 
      -- excludes archived accounts
      accstate.status <> 'AR' AND 
      -- the account has already started or is about to start
      accstate.vt_start < @dt_end AND
      -- the account has not yet ended
      accstate.vt_end >= @dt_now
    GROUP BY accstate.id_acc

create clustered index idx_minstart on #minstart(id_acc)

  -- associate accounts with intervals based on their cycle mapping
  -- this will detect missing mappings and add them
  INSERT INTO @new_mappings
  SELECT 
    auc.id_acc,
    ref.id_interval,
    ISNULL(ui.tx_interval_status, 'O')
  FROM t_acc_usage_cycle auc
  INNER JOIN 
	#minstart minstart ON minstart.id_acc = auc.id_acc
  INNER JOIN t_pc_interval ref ON
    ref.id_cycle = auc.id_usage_cycle AND
    -- reference interval must at least partially overlap the [minstart, maxend] period
    (ref.dt_end >= minstart.dt_start AND ref.dt_start <= minstart.dt_end)
  LEFT OUTER JOIN t_usage_interval ui
    ON ui.id_interval = ref.id_interval 
  WHERE
  not exists (select 1 from t_acc_usage_interval aui where
    aui.id_usage_interval = ref.id_interval AND
    aui.id_acc = auc.id_acc  
) 
and
    -- Only add mappings for non-blocked intervals
    (ui.tx_interval_status IS NULL OR ui.tx_interval_status != 'B')
--  SELECT count(*) FROM @new_mappings

if object_id('tempdb..#minstart') is not null
drop table #minstart


  DECLARE @new_intervals TABLE
  (
    id_interval INT NOT NULL,
    id_usage_cycle INT NOT NULL,
    dt_start DATETIME NOT NULL,
    dt_end DATETIME NOT NULL,
    tx_interval_status VARCHAR(1) NOT NULL,
    id_cycle_type INT NOT NULL
  )

  -- determines what usage intervals need to be added
  -- based on the new account-to-interval mappings  
  INSERT INTO @new_intervals
  SELECT 
    ref.id_interval,
    ref.id_cycle,
    ref.dt_start,
    ref.dt_end,
    'O',  -- Open
    uct.id_cycle_type
  FROM t_pc_interval ref
  INNER JOIN 
  (
    SELECT DISTINCT id_usage_interval FROM @new_mappings
  ) mappings ON mappings.id_usage_interval = ref.id_interval
  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ref.id_cycle
  INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type
  WHERE 
    -- don't add any intervals already in t_usage_interval
    ref.id_interval NOT IN (SELECT id_interval FROM t_usage_interval)

  -- records how many intervals would be added
  SET @n_count = @@ROWCOUNT

  -- only adds the new intervals and mappings if pretend is false
  IF ISNULL(@pretend, 0) = 0
  BEGIN
    
    -- adds the new intervals
    INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)
    SELECT id_interval, id_usage_cycle, dt_start, dt_end, tx_interval_status
    FROM @new_intervals

    -- adds the new mappings
    INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)
    SELECT id_acc, id_usage_interval, tx_status, NULL
    FROM @new_mappings    

    -- updates the last interval creation time, useful for debugging
    UPDATE t_usage_server SET dt_last_interval_creation = @dt_now
  END

  -- returns the added intervals
  SELECT * FROM @new_intervals
  COMMIT
  