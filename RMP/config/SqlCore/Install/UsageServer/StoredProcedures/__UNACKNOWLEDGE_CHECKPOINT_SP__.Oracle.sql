
create or replace
procedure UnacknowledgeCheckpoint(
  p_dt_now date, 
  p_id_instance int, 
  p_b_ignore_deps varchar2, 
  p_id_acc int, 
  p_tx_detail nvarchar2, 
  p_status out int) 
as
  cnt int;
  unsatisfied_deps int;
begin

  /* NOTE: for now, just use the calling procedure's transaction */

  p_status := -99;

	delete from tmp_deps;
  /* enforces that the checkpoints dependencies are satisfied */

  if (p_b_ignore_deps = 'N') then

    unsatisfied_deps := dbo.GetEventReversalDeps(p_dt_now, p_id_instance);
    
    select count(1) into cnt
    from tmp_deps
    where tx_status <> 'NotYetRun';

    if (cnt > 0) then
      p_status := -4; /* deps aren't satisfied */
      return;
    end if;

  end if;

  /* updates the checkpoint instance's state to 'NotYetRun' */

  update t_recevent_inst
  set tx_status = 'NotYetRun',
    b_ignore_deps = p_b_ignore_deps,
    dt_effective = null
  where rowid in (
      select inst.rowid 
      from t_recevent_inst inst
      inner join t_recevent evt 
        on evt.id_event = inst.id_event
      inner join vw_all_billing_groups_status bgs 
        on bgs.id_billgroup = inst.id_arg_billgroup
      where /* event is active */
            evt.dt_activated <= p_dt_now
       and (evt.dt_deactivated is null 
            or p_dt_now < evt.dt_deactivated)
       and inst.id_instance = p_id_instance
       and /* checkpoint must presently be in the Succeeded or Failed state */
          inst.tx_status in('Succeeded', 'Failed')
       and /* interval, if any, must be in the closed state */
          bgs.status = 'C'
  );

  if (sql%rowcount = 1) then
    /* records the action */
    insert into t_recevent_inst_audit( id_audit, id_instance, id_acc,
        tx_action, b_ignore_deps, dt_effective, tx_detail, dt_crt)
    values (seq_t_recevent_inst_audit.nextval, p_id_instance, p_id_acc,
        'Unacknowledge', p_b_ignore_deps, null, p_tx_detail, p_dt_now);

    p_status := 0;
    return;

  end if;
  
  /* otherwise, attempts to figure out what went wrong */

  select count(1) into cnt
  from t_recevent_inst
  where id_instance = p_id_instance;

  if (cnt = 0) then
    /* the instance does not exist */
    p_status := -1;
    return;
  end if;

  select count(1) into cnt
  from t_recevent_inst inst
  inner join t_recevent evt 
    on evt.id_event = inst.id_event
  where /* event is active */
        evt.dt_activated <= p_dt_now
   and (evt.dt_deactivated is null 
        or p_dt_now < evt.dt_deactivated)
   and inst.tx_status in('Succeeded',   'Failed')
   and inst.id_instance = p_id_instance;

  if (cnt = 0) then
    /* instance is not in the proper state */
    p_status := -2;
    return;
  end if;

  select count(1) into cnt
  from t_recevent_inst inst 
  inner join vw_all_billing_groups_status bgs 
    on bgs.id_billgroup = inst.id_arg_billgroup
  where inst.id_instance = p_id_instance
    and bgs.status = 'C';

  if (cnt = 0) then
    /* end-of-period instance's usage interval is not in the proper state */
    p_status := -5;
    return;

  end if;

  /* couldn't submit for some other unknown reason  */
  p_status := -99;

end UnacknowledgeCheckpoint;
