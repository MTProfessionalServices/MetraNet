
CREATE OR REPLACE PROCEDURE CREATETESTRECUREVENTINST 
  (
    id_event INT,
    id_arg_interval INT,
    id_arg_billgroup INT,
    dt_arg_start DATE,
    dt_arg_end DATE,
    id_instance OUT INT 
  )
AS
BEGIN

  INSERT INTO t_recevent_inst
    (ID_INSTANCE,id_event, id_arg_interval, id_arg_billgroup, dt_arg_start, dt_arg_end,
     b_ignore_deps, dt_effective, tx_status)
  VALUES 
    (seq_t_recevent_inst.NEXTVAL, CreateTestRecurEventInst.id_event, CreateTestRecurEventInst.id_arg_interval, 
     CreateTestRecurEventInst.id_arg_billgroup, CreateTestRecurEventInst.dt_arg_start,
     CreateTestRecurEventInst.dt_arg_end, 'Y', NULL, 'NotYetRun');

  select seq_t_recevent_inst.currval into id_instance from dual;
END;
 