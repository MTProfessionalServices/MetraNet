
CREATE PROCEDURE CancelSubmittedEvent
(
  @dt_now DATETIME,
  @id_instance INT,
  @id_acc INT,
  @tx_detail nvarchar(2048),
  @status INT OUTPUT
)
AS

BEGIN
  DECLARE @current_status VARCHAR(14)
  DECLARE @previous_status VARCHAR(14)

  SELECT @status = -99

  BEGIN TRAN
  -- gets the instances current status
  SELECT 
    @current_status = inst.tx_status
  FROM t_recevent_inst inst
  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  WHERE 
    -- event is active
    evt.dt_activated <= @dt_now AND
    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND
    inst.id_instance = @id_instance
  
  IF @@ROWCOUNT = 0
  BEGIN
    SELECT @status = -1  -- instance was not found
    ROLLBACK
    RETURN
  END

  IF @current_status = 'ReadyToRun'
  BEGIN
    -- the only way to get to ReadyToRun is from NotYetRun
    SELECT @previous_status = 'NotYetRun'
  END
  ELSE IF @current_status = 'ReadyToReverse'
  BEGIN
    -- the only way to get to ReadyToReverse is from Succeeded or Failed
    -- determines which of these two statuses by looking at the last run's status
    SELECT TOP 1 @previous_status = run.tx_status
    FROM t_recevent_run run
    WHERE run.id_instance = @id_instance
    ORDER BY run.dt_end desc
  END
  ELSE
  BEGIN
    SELECT @status = -2  -- instance cannot be cancelled because it is not in a legal state
    ROLLBACK
    RETURN
  END
  -- reverts the instance's state to what it was previously
  UPDATE t_recevent_inst
  SET tx_status = @previous_status, b_ignore_deps = 'N', dt_effective = NULL
  WHERE id_instance = @id_instance

  -- records the action
    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)
  VALUES(@id_instance, @id_acc, 'Cancel', NULL, NULL, @tx_detail, @dt_now) 

  SELECT @status = 0  -- success

  COMMIT
END
