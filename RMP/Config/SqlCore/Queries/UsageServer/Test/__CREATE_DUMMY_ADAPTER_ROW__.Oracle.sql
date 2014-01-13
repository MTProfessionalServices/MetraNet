
/* ===========================================================
Create a dummy adapter row with the given status.
============================================================== */
insert into t_recevent_inst(id_instance, id_event, id_arg_interval, b_ignore_deps, tx_status)
  select SEQ_T_RECEVENT_INST.NEXTVAL, id_event, %%ID_INTERVAL%%, 'Y', '%%STATUS%%'
  from t_recevent
  where tx_name = '%%EVENT_NAME%%'
 