
CREATE PROCEDURE CreateTestRecurEventInst 
  (
    @id_event INT,
    @id_arg_interval INT,
    @id_arg_billgroup INT,
    @dt_arg_start DATETIME,
    @dt_arg_end DATETIME,
    @id_instance INT OUTPUT
  )
AS

BEGIN
  BEGIN TRAN

  INSERT INTO t_recevent_inst
    (id_event, id_arg_interval, id_arg_billgroup, dt_arg_start, dt_arg_end,
     b_ignore_deps, dt_effective, tx_status)
  VALUES 
    (@id_event, @id_arg_interval, @id_arg_billgroup, @dt_arg_start,
     @dt_arg_end, 'Y', NULL, 'NotYetRun')

  SELECT @id_instance = @@IDENTITY

  COMMIT
END
  