
CREATE PROC CreateUsageIntervalsForAccount
(
  @dt_now   DATETIME,  -- the MetraTech system's date
  @id_acc   INT,       -- account ID to create intervals/mappings for 
  @dt_start DATETIME,  -- account start date
  @dt_end   DATETIME,  -- account end date
  @pretend  INT,       -- if true doesn't create new intervals but returns what would have been created
  @n_count  INT OUTPUT -- the count of intervals created (or that would have been created)
)
AS
BEGIN
  BEGIN TRAN

  -- NOTE: this procedure is closely realted to CreateUsageIntervals
  -- except that it only does work for one account (@id_acc). This sproc
  -- is used to decrease total duration of an account creation. Other
  -- accounts affected by new intervals being created are addressed later
  -- in the day when a required usm -create triggers a full CreateUsageIntervals
  -- execution.

  --
  -- PRECONDITIONS:
  --   Intervals and mappings will be created and backfilled as long as there
  --   is an entry for the account in t_acc_usage_cycle. Missing mappings will
  --   be detected and added.

  -- ensures that there is only one instance of this sproc or the CreateUsageIntervals sproc
  -- being executing right now
  DECLARE @result INT
  EXEC @result = sp_getapplock @Resource = 'CreateUsageIntervals', @LockMode = 'Exclusive'
  IF @result < 0
  BEGIN
      ROLLBACK
      RETURN
  END

  -- represents the end date that an interval must
  -- fall into to be considered 
  DECLARE @dt_probe DATETIME
  SELECT @dt_probe = (@dt_now + n_adv_interval_creation) FROM t_usage_server

  -- if the account hasn't started nor is about to start or
  -- the account has already ended (is this possible?)
  -- then don't do anything
  IF (@dt_start >= @dt_probe AND @dt_end < @dt_now)
  BEGIN
    SET @n_count = @@ROWCOUNT
    COMMIT
    RETURN
  END

  -- adjusts the account end date to be no later than the probe date
  -- no intervals are created in the future after the probe date
  DECLARE @dt_adj_end DATETIME
  SELECT @dt_adj_end = CASE WHEN @dt_end > @dt_probe THEN @dt_probe ELSE @dt_end END

  DECLARE @new_mappings TABLE
  (
    id_acc INT NOT NULL,
    id_usage_interval INT NOT NULL,
    tx_status VARCHAR(1)  
  )

  -- associate the account with intervals based on its cycle mapping
  -- this will detect missing mappings and add them
  INSERT INTO @new_mappings
  SELECT 
    auc.id_acc,
    ref.id_interval,
    ISNULL(ui.tx_interval_status, 'O')  -- TODO: this column is no longer used and should eventually be removed
  FROM t_acc_usage_cycle auc
  INNER JOIN t_pc_interval ref ON
    ref.id_cycle = auc.id_usage_cycle AND
    -- reference interval must at least partially overlap the [minstart, maxend] period
    (ref.dt_end >= @dt_start AND ref.dt_start <= @dt_adj_end)
  LEFT OUTER JOIN t_acc_usage_interval aui ON
    aui.id_usage_interval = ref.id_interval AND
    aui.id_acc = auc.id_acc  
  LEFT OUTER JOIN t_usage_interval ui
    ON ui.id_interval = ref.id_interval 
  WHERE
    auc.id_acc = @id_acc AND
    -- Only add mappings for non-blocked intervals
    (ui.tx_interval_status IS NULL OR ui.tx_interval_status != 'B') AND
    -- only add mappings that don't exist already
    aui.id_usage_interval IS NULL        


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
  INNER JOIN @new_mappings mappings ON mappings.id_usage_interval = ref.id_interval
  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ref.id_cycle
  INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type
  WHERE 
    -- don't add any intervals already in t_usage_interval
    ref.id_interval NOT IN (SELECT id_interval FROM t_usage_interval)

  -- records how many intervals would be added
  SET @n_count = @@ROWCOUNT

  -- only adds the new intervals and mappings if we aren't pretending
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

  END

  -- returns the added intervals
  SELECT * FROM @new_intervals
  COMMIT
END
  