
CREATE PROCEDURE SoftCloseUsageIntervals
(
  @dt_now DATETIME,     -- MetraTech system date
  @id_interval INT,     -- specific usage interval to close or null for automatic detection based on grace periods
  @pretend INT,         -- if pretend is true no intervals are closed but instead are just returned
  @n_count INT OUTPUT   -- the number of usage intervals closed (or that would have been closed)
)
AS

  BEGIN TRAN

  DECLARE @closing_intervals TABLE
  (
    id_interval INT NOT NULL,
    id_usage_cycle INT NOT NULL,
    id_cycle_type INT NOT NULL,
    dt_start DATETIME NOT NULL,
    dt_end DATETIME NOT NULL,
    tx_interval_status VARCHAR(1) NOT NULL
  )

  -- determines which intervals to close
  IF (@id_interval IS NULL)
  BEGIN
    -- looks at all the intervals in the system
    INSERT INTO @closing_intervals
    SELECT ui.id_interval, ui.id_usage_cycle, uct.id_cycle_type, ui.dt_start, ui.dt_end, 'C'
    FROM t_usage_interval ui
    INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle
    INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type
    WHERE
      CASE WHEN uct.n_grace_period IS NOT NULL THEN
        -- take into account the cycle type's grace period
        ui.dt_end + uct.n_grace_period 
      ELSE
        -- the grace period has been disabled, so don't close this interval
        @dt_now
      END < @dt_now AND
      ui.tx_interval_status = 'O'

    SET @n_count = @@ROWCOUNT
  END
  ELSE
  BEGIN
    -- only close the given interval (regardless of grace period/end date)
    INSERT INTO @closing_intervals
    SELECT ui.id_interval, ui.id_usage_cycle, uct.id_cycle_type, ui.dt_start, ui.dt_end, ui.tx_interval_status
    FROM t_usage_interval ui
    INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle
    INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type
    WHERE ui.tx_interval_status = 'O'
          AND ui.id_interval = @id_interval

    SET @n_count = @@ROWCOUNT
  END

  -- only closes the intervals if pretend is false
  IF @pretend = 0
  BEGIN
    UPDATE t_usage_interval
    SET tx_interval_status = 'C'
    FROM t_usage_interval ui
    INNER JOIN @closing_intervals cui ON cui.id_interval = ui.id_interval

    -- adds instance entries for each interval that closed
    INSERT INTO t_recevent_inst(id_event,id_arg_interval,dt_arg_start,dt_arg_end,b_ignore_deps,dt_effective,tx_status)
    SELECT 
      evt.id_event id_event,
      cui.id_interval id_arg_interval,
      NULL dt_arg_start,
      NULL dt_arg_end,
      'N' b_ignore_deps,
      NULL dt_effective,
      -- the start root event is created as Succeeded
      -- the end root event is created as ReadyToRun (for auto hard close)
      -- all others are created as  NotYetRun
      CASE WHEN evt.tx_name = '_StartRoot' AND evt.tx_type = 'Root' THEN 'Succeeded' 
           WHEN evt.tx_name = '_EndRoot'   AND evt.tx_type = 'Root' THEN 'ReadyToRun' ELSE
           'NotYetRun' 
      END tx_status
    FROM @closing_intervals cui
    INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = cui.id_usage_cycle
    INNER JOIN t_recevent_eop sch ON 
               -- the schedule is not constrained in any way
               ((sch.id_cycle_type IS NULL AND sch.id_cycle IS NULL) OR
               -- the schedule's cycle type is constrained
               (sch.id_cycle_type = uc.id_cycle_type) OR
               -- the schedule's cycle is constrained
               (sch.id_cycle = uc.id_usage_cycle))
    INNER JOIN t_recevent evt ON evt.id_event = sch.id_event
    WHERE 
      -- event must be active
      evt.dt_activated <= @dt_now and
      (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
      -- event must be of type: root, end-of-period or checkpoint
      (evt.tx_type in ('Root', 'EndOfPeriod', 'Checkpoint')) AND
      evt.id_event NOT IN 
      (
        -- only adds instances if they are missing
        -- this guards against extra instances after closing -> reopening -> closing
        SELECT evt.id_event
        FROM @closing_intervals cui 
        INNER JOIN t_recevent_inst inst ON inst.id_arg_interval = cui.id_interval
        INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
        WHERE  
          -- event must be active
          evt.dt_activated <= @dt_now and
          (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated)
      )
  END

  SELECT * FROM @closing_intervals
  COMMIT
  