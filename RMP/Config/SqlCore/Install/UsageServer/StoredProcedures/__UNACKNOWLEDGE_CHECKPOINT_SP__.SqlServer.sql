
/* ===========================================================
Modified from the previous version to use billing groups information.
=========================================================== */
CREATE PROCEDURE UnacknowledgeCheckpoint
(
  @dt_now DATETIME,
  @id_instance INT,
  @b_ignore_deps VARCHAR(1),
  @id_acc INT,
  @tx_detail nvarchar(2048),
  @status INT OUTPUT
)
AS

BEGIN

  -- NOTE: for now, just use the calling procedure's transaction

  SELECT @status = -99

  -- enforces that the checkpoints dependencies are satisfied
  IF (@b_ignore_deps = 'N')
  BEGIN
    DECLARE @unsatisfiedDeps INT
    SELECT @unsatisfiedDeps = COUNT(*) 
    FROM GetEventReversalDeps (@dt_now, @id_instance)
    WHERE tx_status <> 'NotYetRun'

    IF (@unsatisfiedDeps > 0)
    BEGIN
      SELECT @status = -4  -- deps aren't satisfied
      RETURN
    END
  END

  -- updates the checkpoint instance's state to 'NotYetRun'
  UPDATE t_recevent_inst
  SET tx_status = 'NotYetRun', b_ignore_deps = @b_ignore_deps, dt_effective = NULL
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  -- INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval
  INNER JOIN vw_all_billing_groups_status bgs ON bgs.id_billgroup = inst.id_arg_billgroup
  WHERE 
    -- event is active
    evt.dt_activated <= @dt_now AND
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
    inst.id_instance = @id_instance AND
    -- checkpoint must presently be in the Succeeded or Failed state
    inst.tx_status IN ('Succeeded', 'Failed') AND
    -- interval, if any, must be in the closed state
    -- ui.tx_interval_status = 'C'
    bgs.status = 'C'

  -- if the update was made, return successfully
  IF (@@ROWCOUNT = 1)
  BEGIN

    -- records the action
    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)
    VALUES(@id_instance, @id_acc, 'Unacknowledge', @b_ignore_deps, NULL, @tx_detail, @dt_now) 

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
    -- the instance does not exist
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
    SELECT @status = -2
    RETURN
  END

  SELECT @count = COUNT(*)  
  FROM t_recevent_inst inst
  -- INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval
  INNER JOIN vw_all_billing_groups_status bgs ON bgs.id_billgroup = inst.id_arg_billgroup
  WHERE 
    inst.id_instance = @id_instance AND
    -- ui.tx_interval_status = 'C'
    bgs.status = 'C'

  IF (@count = 0)
  BEGIN
    -- end-of-period instance's usage interval is not in the proper state
    SELECT @status = -5 
    RETURN
  END

  -- couldn't submit for some other unknown reason 
  SELECT @status = -99 
END
   