
create or replace 
procedure SubmitEventForReversal (
  p_dt_now date,   
  p_id_instance int,   
  p_b_ignore_deps varchar2,   
  p_dt_effective date,   
  p_id_acc int,   
  p_tx_detail nvarchar2,   
  p_status out int) 
as
  is_checkpoint int;
  cnt int;
begin
  
  p_status := -99;
  
  /* if the instance is a checkpoint, synchronously unacknowledges it */ 
  for i in (
      select 1 as one
      from t_recevent_inst inst, t_recevent evt
      where evt.id_event = inst.id_event
        and inst.id_instance = p_id_instance
        and evt.tx_type = 'Checkpoint')
  loop
    is_checkpoint := i.one;
  end loop;
  
  if (is_checkpoint = 1) then
    UnacknowledgeCheckpoint(p_dt_now, p_id_instance, p_b_ignore_deps, p_id_acc, 
        p_tx_detail, p_status);
  
    if(p_status = 0) then
      commit;
    else
      rollback;
    end if;
  
    return;
  end if;
  
  /* updates the instance's state to 'ReadyToReverse' */
  update t_recevent_inst
  set 
    tx_status = 'ReadyToReverse',
    b_ignore_deps = p_b_ignore_deps,
    dt_effective = p_dt_effective
  where rowid in (
    select inst.rowid
    from t_recevent_inst inst
    inner join t_recevent evt 
      on evt.id_event = inst.id_event left
    outer join t_usage_interval ui 
      on ui.id_interval = inst.id_arg_interval 
    left outer join vw_all_billing_groups_status bgs 
      on bgs.id_billgroup = inst.id_arg_billgroup
    where /* event is active */
          evt.dt_activated <= p_dt_now
     and (evt.dt_deactivated is null 
      or p_dt_now < evt.dt_deactivated)
     and evt.tx_reverse_mode in ('Auto', 'Custom', 'NotNeeded')
     and inst.id_instance = p_id_instance
     and /* instance must have previously succeeded or failed */
        inst.tx_status in('Succeeded',   'Failed',   'ReadyToReverse')
     and /* billing group, if any, must be in the closed state
            interval, if any, must not be hard closed */
          (inst.id_arg_interval is null 
          or inst.id_arg_billgroup is null 
          or bgs.status = 'C' 
          or ui.tx_interval_status != 'H')
      );
  
  /* if the update was made, return successfully */
  if (sql%rowcount = 1) then
    /* records the action */ 
    insert into t_recevent_inst_audit (id_audit, id_instance, id_acc, 
        tx_action, b_ignore_deps, dt_effective, tx_detail, dt_crt)
    values (seq_t_recevent_inst_audit.nextval, p_id_instance, p_id_acc,
        'SubmitForReversal', p_b_ignore_deps, p_dt_effective, p_tx_detail, p_dt_now);
    commit;
    p_status := 0;
    return;
  end if;

  /* otherwise, attempts to figure out what went wrong */
  select count(*) into cnt
  from t_recevent_inst
  where id_instance = p_id_instance;
  
  if (cnt = 0) then
    /* instance doesn't exist at all */
    rollback;
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
    and inst.tx_status in('Succeeded', 'Failed')
    and inst.id_instance = p_id_instance;
  
  if (cnt = 0) then
    /* instance is not in the proper state */
    rollback;
    p_status := -2;
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
    and evt.tx_reverse_mode in('Auto', 'Custom', 'NotNeeded')
    and inst.id_instance = p_id_instance;
  
  if (cnt = 0) then
    /* event is not reversible  */
    rollback;
    p_status := -3;
    return;
  end if;
  
  select count(1)  into cnt
  from t_recevent_inst inst
  left outer join t_usage_interval ui 
    on ui.id_interval = inst.id_arg_interval
  left outer join vw_all_billing_groups_status bgs 
    on bgs.id_billgroup = inst.id_arg_billgroup
  where inst.id_instance = p_id_instance
        /* (inst.id_arg_interval is null or ui.tx_interval_status = 'c')
          billing group, if any, must be in the closed state
          interval, if any, must not be hard closed
        */
    and ( inst.id_arg_interval is null 
          or inst.id_arg_billgroup is null 
          or bgs.status = 'C' 
          or ui.tx_interval_status != 'H');
  
  if (cnt = 0) then
    /* end-of-period instance's usage interval is not in the proper state */
    rollback;
    p_status := -5;
    return;
  end if;
  
  /* couldn't submit for some other unknown reason  */
  rollback;
  p_status := -99;
  
end SubmitEventForReversal;
