
CREATE PROCEDURE OpenUsageInterval
(
  @dt_now DATETIME,     -- MetraTech system date
  @id_interval INT,     -- specific usage interval to reopen, the interval must be soft-closed
  @ignoreDeps INT,      -- whether to ignore the reverse dependencies for re-opening the interval
  @pretend INT,         -- if pretend is true, the interval is not actually reopened
  @status INT OUTPUT    -- return code: 0 is successful
)
AS

BEGIN
  BEGIN TRAN

  SELECT @status = -999

  -- checks that the interval is soft closed
  DECLARE @count INT
  SELECT @count = COUNT(*)
  FROM t_usage_interval
  WHERE 
    id_interval = @id_interval AND
    tx_interval_status = 'C'
 
  IF @count = 0
  BEGIN
    SELECT @count = COUNT(*)
    FROM t_usage_interval
    WHERE id_interval = @id_interval

    IF @count = 0
      -- interval not found
      SELECT @status = -1
    ELSE
      -- interval not soft closed
      SELECT @status = -2
  
    ROLLBACK
    RETURN
  END

  --
  -- retrieves the instance ID of the start root event for the given interval
  --
  DECLARE @id_instance INT
  SELECT @id_instance = inst.id_instance
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  WHERE
    -- event must be active
    evt.dt_activated <= @dt_now and
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
    -- instance must match the given interval
    inst.id_arg_interval = @id_interval AND
    evt.tx_name = '_StartRoot' AND
    evt.tx_type = 'Root'

  IF @id_instance IS NULL
  BEGIN
    -- start root instance was not found!
    SELECT @status = -3
    ROLLBACK
    RETURN
  END
  
  
  --
  -- checks start root's reversal dependencies
  --
  IF @ignoreDeps = 0
  BEGIN
    SELECT @count = COUNT(*)
    FROM GetEventReversalDeps(@dt_now, @id_instance) deps
    WHERE deps.tx_status <> 'NotYetRun'

    IF @count > 0
    BEGIN
      -- not all instances in the interval have been reversed successfuly
      SELECT @status = -4
      ROLLBACK
      RETURN
    END   
  END

  -- just pretending, so don't do the update
  IF @pretend != 0
  BEGIN
    SELECT @status = 0 -- success
    COMMIT
    RETURN
  END  

  UPDATE t_usage_interval SET tx_interval_status = 'O'
  WHERE 
    id_interval = @id_interval AND
    tx_interval_status = 'C'

  IF @@ROWCOUNT = 1
  BEGIN
    SELECT @status = 0 -- success
    COMMIT
  END
  ELSE
  BEGIN
    -- couldn't update the interval
    SELECT @status = -5
    ROLLBACK
  END
END
  