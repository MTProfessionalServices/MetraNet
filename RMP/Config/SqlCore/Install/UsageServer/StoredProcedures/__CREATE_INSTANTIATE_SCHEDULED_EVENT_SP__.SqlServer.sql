
CREATE PROCEDURE InstantiateScheduledEvent 
  (
    @dt_now DATETIME,
    @id_event INT,
    @dt_end DATETIME,
    @id_instance INT OUTPUT,
    @status INT OUTPUT
  )
AS

BEGIN

  BEGIN TRAN

  SELECT @status      = -99
  SELECT @id_instance = -99

  --
  -- attempts to update an pre-existing NotYetRun instance of this event
  --
  SELECT @id_instance = inst.id_instance
  FROM t_recevent_inst inst
  INNER JOIN 
  (
    -- finds the last instance
    SELECT MAX(inst.dt_arg_end) dt_arg_end
    FROM t_recevent evt
    INNER JOIN t_recevent_inst inst ON inst.id_event = evt.id_event
    WHERE
      -- event is active
      evt.dt_activated <= @dt_now AND
      (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
      evt.id_event = @id_event AND
      -- event is of type scheduled
      evt.tx_type = 'Scheduled'
  ) maxinst ON maxinst.dt_arg_end = inst.dt_arg_end
  WHERE
    inst.id_event = @id_event AND
    -- run has not yet been run
    inst.tx_status = 'NotYetRun' AND
    -- existing end date of the latest instance must be 
    -- before the newly requested end date
    inst.dt_arg_end < @dt_end

  IF (@@ROWCOUNT = 1)
  BEGIN
    UPDATE t_recevent_inst SET dt_arg_end = @dt_end WHERE id_instance = @id_instance

    COMMIT
    SELECT @status = 0 -- success (update)
    RETURN
  END


  --
  -- otherwise, an existing instance did not exist so create a new one
  --
  INSERT INTO t_recevent_inst(id_event,id_arg_interval,dt_arg_start,dt_arg_end,b_ignore_deps,dt_effective,tx_status)
  SELECT
    evt.id_event,
    NULL,             -- id_arg_interval
    MAX(dbo.AddSecond(ISNULL(inst.dt_arg_end, dbo.SubtractSecond(evt.dt_activated)))),
    @dt_end,          -- dt_arg_end
    'N',              -- b_ignore_deps
    NULL,             -- dt_effective
    'NotYetRun'       -- tx_status
  FROM t_recevent evt
  LEFT OUTER JOIN t_recevent_inst inst ON inst.id_event = evt.id_event
  WHERE
    -- event is active
    evt.dt_activated <= @dt_now AND
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
    evt.id_event = @id_event AND
    -- event is of type scheduled
    evt.tx_type = 'Scheduled'
  GROUP BY
    evt.id_event
  HAVING 
    -- start date must come before the requested end date
    MAX(dbo.AddSecond(ISNULL(inst.dt_arg_end, evt.dt_activated))) < @dt_end

  -- success!
  IF (@@ROWCOUNT = 1)
  BEGIN
    SELECT @status = 0    -- success (insert)
    SELECT @id_instance = @@IDENTITY
    COMMIT
    RETURN
  END


  -- 
  -- no instance was updated or created - figure out exactly what went wrong
  --

  -- does the event exist?
  SELECT 
    evt.id_event
  FROM t_recevent evt
  WHERE
    evt.dt_activated <= @dt_now AND
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
    evt.id_event = @id_event

  IF (@@ROWCOUNT = 0)
  BEGIN
    SELECT @status = -1 -- event not found
    ROLLBACK
    RETURN
  END

  -- is the event of type scheduled?
  SELECT 
    evt.id_event
  FROM t_recevent evt
  WHERE
    evt.tx_type = 'Scheduled' AND
    evt.id_event = @id_event

  IF (@@ROWCOUNT = 0)
  BEGIN
    SELECT @status = -2 -- event is not active
    ROLLBACK
    RETURN
  END

  -- is the last instances end date greater than the proposed start date?
  SELECT
    evt.id_event,
    MAX(dbo.AddSecond(ISNULL(inst.dt_arg_end, dbo.SubtractSecond(evt.dt_activated))))
  FROM t_recevent evt
  LEFT OUTER JOIN t_recevent_inst inst ON inst.id_event = evt.id_event
  WHERE 
    evt.id_event = @id_event 
  GROUP BY
    evt.id_event
  HAVING 
    -- start date must come before the requested end date
    MAX(dbo.AddSecond(ISNULL(inst.dt_arg_end, evt.dt_activated))) < @dt_end

  IF (@@ROWCOUNT = 0)
  BEGIN
    SELECT @status = -3 -- last end date is greater than the proposed start date
    ROLLBACK
    RETURN
  END

  -- unknown failure
  ROLLBACK
  SELECT @status = -99  
END
  