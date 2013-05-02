
/* ===========================================================
Modified from the previous version to use billing groups information.
=========================================================== */
CREATE PROCEDURE SubmitEventForReversal
(
  @dt_now DATETIME,
  @id_instance INT,
  @b_ignore_deps VARCHAR(1),
  @dt_effective DATETIME,
  @id_acc INT,
  @tx_detail nvarchar(2048),
  @status INT OUTPUT
)
AS

BEGIN

  BEGIN TRAN

  SELECT @status = -99

  -- if the instance is a checkpoint, synchronously unacknowledges it
  DECLARE @isCheckpoint INT
  SELECT @isCheckpoint = 1 
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  WHERE 
    inst.id_instance = @id_instance AND
    evt.tx_type = 'Checkpoint'
  IF (@isCheckpoint = 1)
  BEGIN
    EXEC UnacknowledgeCheckpoint @dt_now, @id_instance, @b_ignore_deps, @id_acc, @tx_detail, @status OUTPUT
    IF (@status = 0)
      COMMIT
    ELSE
      ROLLBACK
    RETURN 
  END

  -- updates the instance's state to 'ReadyToReverse'
  UPDATE t_recevent_inst
  SET tx_status = 'ReadyToReverse', b_ignore_deps = @b_ignore_deps, dt_effective = @dt_effective
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  LEFT OUTER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval
  LEFT OUTER JOIN vw_all_billing_groups_status bgs ON bgs.id_billgroup = inst.id_arg_billgroup
  WHERE 
    -- event is active
    evt.dt_activated <= @dt_now AND
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
    evt.tx_reverse_mode IN ('Auto', 'Custom', 'NotNeeded') AND
    inst.id_instance = @id_instance AND
    -- instance must have previously succeeded or failed
    inst.tx_status IN ('Succeeded', 'Failed', 'ReadyToReverse') AND
    -- billing group, if any, must be in the closed state
    -- interval, if any, must not be hard closed
    (inst.id_arg_interval IS NULL OR 
     inst.id_arg_billgroup IS NULL OR
     bgs.status = 'C' OR
     ui.tx_interval_status != 'H')

  -- if the update was made, return successfully
  IF (@@ROWCOUNT = 1)
  BEGIN

    -- records the action
    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)
    VALUES(@id_instance, @id_acc, 'SubmitForReversal', @b_ignore_deps, @dt_effective, @tx_detail, @dt_now) 

    COMMIT
    SELECT @status = 0
    RETURN
  END

  --
  -- otherwise, attempts to figure out what went wrong
  --
  DECLARE @count INT
  SELECT @count = COUNT(*) FROM t_recevent_inst WHERE id_instance = @id_instance

  IF (@count = 0)
  BEGIN
    -- instance doesn't exist at all
    ROLLBACK
    SELECT @status = -1 
    RETURN
  END

  SELECT @count = COUNT(*)
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  WHERE 
    -- event is active
    evt.dt_activated <= @dt_now AND
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
    inst.tx_status IN ('Succeeded', 'Failed') AND
    inst.id_instance = @id_instance

  IF (@count = 0)
  BEGIN
    -- instance is not in the proper state
    ROLLBACK
    SELECT @status = -2
    RETURN
  END

  SELECT @count = COUNT(*)
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  WHERE 
    -- event is active
    evt.dt_activated <= @dt_now AND
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
    evt.tx_reverse_mode IN ('Auto', 'Custom', 'NotNeeded') AND
    inst.id_instance = @id_instance

  IF (@count = 0)
  BEGIN
    -- event is not reversible 
    ROLLBACK
    SELECT @status = -3
    RETURN
  END

  SELECT @count = COUNT(*)  
  FROM t_recevent_inst inst
  LEFT OUTER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval
  LEFT OUTER JOIN vw_all_billing_groups_status bgs ON bgs.id_billgroup = inst.id_arg_billgroup
  WHERE 
    inst.id_instance = @id_instance AND
    -- (inst.id_arg_interval IS NULL OR ui.tx_interval_status = 'C')
    -- billing group, if any, must be in the closed state
    -- interval, if any, must not be hard closed
    (inst.id_arg_interval IS NULL OR 
     inst.id_arg_billgroup IS NULL OR
     bgs.status = 'C' OR
     ui.tx_interval_status != 'H')

  IF (@count = 0)
  BEGIN
    -- end-of-period instance's usage interval is not in the proper state
    ROLLBACK
    SELECT @status = -5 
    RETURN
  END

  -- couldn't submit for some other unknown reason 
  ROLLBACK
  SELECT @status = -99
END
  