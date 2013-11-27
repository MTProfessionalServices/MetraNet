
CREATE PROCEDURE MarkEventAsSucceeded
(
  @dt_now DATETIME,
  @id_instance INT,
  @id_acc INT,
  @tx_detail nvarchar(2048),
  @tx_machine VARCHAR(128),
  @status INT OUTPUT
)
AS

BEGIN
  BEGIN TRAN

  SELECT @status = -99

  UPDATE t_recevent_inst 
  SET tx_status = 'Succeeded'
  WHERE 
    id_instance = @id_instance AND
    tx_status = 'Failed'
  
  IF @@ROWCOUNT = 1  -- successfully updated
  BEGIN
    -- inserts a run to record the fact that the status was changed
    -- this is important for 'cancel' to work correctly in reverse situations
    DECLARE @id_run INT
    EXEC GetCurrentID 'receventrun', @id_run OUTPUT
    INSERT INTO t_recevent_run
    (
      id_run,
      id_instance,
      tx_type,
      id_reversed_run,
      tx_machine,
      dt_start,
      dt_end,
      tx_status,
      tx_detail
    )
    VALUES 
    (
      @id_run,
      @id_instance,
      'Execute',
      NULL,
      @tx_machine,
      @dt_now,
      @dt_now,
      'Succeeded',
      'Manually changed status to Succeeded'
    )

    -- audits the action
    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)
    VALUES(@id_instance, @id_acc, 'MarkAsSucceeded', NULL, NULL, @tx_detail, @dt_now) 

    SELECT @status = 0  -- success
    COMMIT
    RETURN
  END

  --
  -- update did not occur, so lets figure out why
  --

  -- does the instance exist?
  SELECT 1
  FROM t_recevent_inst 
  WHERE 
    id_instance = @id_instance

  IF @@ROWCOUNT = 0
  BEGIN
    SELECT @status = -1  -- instance does not exist
    ROLLBACK
    RETURN -1
  END

  SELECT @status = -2  -- instance was not in a valid state
  ROLLBACK
  RETURN -2

END 
  