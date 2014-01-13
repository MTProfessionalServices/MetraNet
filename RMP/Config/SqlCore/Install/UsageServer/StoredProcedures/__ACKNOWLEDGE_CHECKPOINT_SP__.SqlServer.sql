
/* ===========================================================
Modified from the previous version to use billing groups information.
=========================================================== */
CREATE PROCEDURE AcknowledgeCheckpoint
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
    if object_id('tempdb..#tmp_deps') is not null drop table #tmp_deps
    CREATE TABLE #tmp_deps
    (
      id_orig_event INT NOT NULL,
      tx_orig_billgroup_support VARCHAR(15),         -- useful for debugging
      id_orig_instance INT NOT NULL,
      id_orig_billgroup INT,                               -- useful for debugging
      tx_orig_name VARCHAR(255) NOT NULL, -- useful for debugging
      tx_name nvarchar(255) NOT NULL,           -- useful for debugging
      id_event INT NOT NULL,
      tx_billgroup_support VARCHAR(15),         -- useful for debugging
      id_instance INT,
      id_billgroup INT,                                       -- useful for debugging
      id_arg_interval INT,
      dt_arg_start DATETIME,
      dt_arg_end DATETIME,
      tx_status VARCHAR(14),
      b_critical_dependency VARCHAR(1)
    )

    -- GetEventExecutionDeps populates #tmp_deps table
    -- Parameter table have bad performance when >100 records returned, so using temp table for that.
    EXEC GetEventExecutionDeps @dt_now, @id_instance
  
    DECLARE @unsatisfiedDeps INT
    SELECT @unsatisfiedDeps = COUNT(*) 
    FROM #tmp_deps
    WHERE tx_status <> 'Succeeded'

    IF (@unsatisfiedDeps > 0)
    BEGIN
      SELECT @status = -4  -- deps aren't satisfied
      RETURN
    END
  END

  -- updates the checkpoint instance's state to 'Succeeded'
  UPDATE t_recevent_inst
  SET tx_status = 'Succeeded', b_ignore_deps = @b_ignore_deps, dt_effective = NULL
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  -- INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval
  INNER JOIN vw_all_billing_groups_status bgs ON bgs.id_billgroup = inst.id_arg_billgroup
  WHERE 
    -- event is active
    evt.dt_activated <= @dt_now AND
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
    inst.id_instance = @id_instance AND
    -- checkpoint must presently be in the NotYetRun state
    inst.tx_status IN ('NotYetRun') AND
    -- interval, if any, must be in the closed state
    -- ui.tx_interval_status = 'C'
    bgs.status = 'C'

  -- if the update was made, return successfully
  IF (@@ROWCOUNT = 1)
  BEGIN

    -- records the action
    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)
    VALUES(@id_instance, @id_acc, 'Acknowledge', @b_ignore_deps, NULL, @tx_detail, @dt_now) 
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
    inst.tx_status = 'NotYetRun' AND
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
   