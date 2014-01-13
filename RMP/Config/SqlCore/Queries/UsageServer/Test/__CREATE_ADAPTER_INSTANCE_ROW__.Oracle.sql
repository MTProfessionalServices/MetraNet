
/* ===========================================================
Create a row in t_recevent_inst.
============================================================== */
INSERT INTO t_recevent_inst(id_instance, id_event, id_arg_interval, id_arg_billgroup, b_ignore_deps, tx_status)
SELECT SEQ_T_RECEVENT_INST.NEXTVAL, %%ID_EVENT%%, %%ID_INTERVAL%%, %%ID_BILLGROUP%%, 'Y', 'ReadyToRun' FROM Dual
 