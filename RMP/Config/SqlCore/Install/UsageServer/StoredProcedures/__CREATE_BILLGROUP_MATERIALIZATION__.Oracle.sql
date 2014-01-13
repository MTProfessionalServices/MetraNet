
      
/* ===========================================================
Inserts a row in t_billgroup_materialization 
Returns the materialization id

Returns:
-1 if an unknown error has occurred
-2 could not clean temporary data
-3 if this interval is hard closed
-4 if this interval does not have any paying accounts
-5 if atleast one interval-only adapter has executed successfully for the given interval
      and it's a rematerialization or a user defined billing group creation
-6 if an 'EOP' adapter associated with the given interval is 'Running' or 'Reversing'
-7 if a full materialization has already happened for the given interval
-8 if a materialization is in progress for the given interval
=========================================================== */
create or replace 
procedure createbillgroupmaterialization(
  p_id_user_acc int,    
  p_dt_start date,    
  p_id_parent_billgroup int,    
  p_id_usage_interval int,    
  p_tx_type varchar2,    
  p_id_materialization out int,    
  p_status out int) 
as
  cnt int;
begin

  p_status := -1;
  p_id_materialization := 0;

  /* Clean out temporary data */ 
  cleanupMaterialization(null, null, null, null, p_status);
  
  if (p_status != 0) then
    p_status := -2;
    rollback;
    return;
  end if;

  /* Reset status */
  p_status := -1;

  /* Return error if this interval is hard closed */
  select count(id_interval) into cnt
    from t_usage_interval
    where id_interval = p_id_usage_interval
    and tx_interval_status = 'H';

  if (cnt > 0) then
    p_status := -3;
    rollback;
    return;
  end if;

  /* Return error if this interval does not have any paying accounts */
  cnt:= 0;
  select count(accountid) into cnt
    from vw_paying_accounts
    where intervalid = p_id_usage_interval;
    
  if (cnt = 0) then
    p_status := -4;
    rollback;
    return;
  end if;

  /* Error if at least one interval-only adapter has executed successfully 
    for the given interval for a rematerialization */
  select count(id_instance) into cnt
  from t_recevent_inst ri
  inner join t_recevent re 
    on re.id_event = ri.id_event
  where ri.id_arg_interval = p_id_usage_interval
    and re.tx_billgroup_support = 'Interval'
    and re.tx_type = 'EndOfPeriod'
    and ri.tx_status = 'Succeeded';

  if (p_tx_type = 'Rematerialization' or p_tx_type = 'UserDefined')
      and cnt > 0 then
    p_status := -5;
    rollback;
    return;
  end if;

  /* Return error if there are any EOP adapter instances running 
    or reversing in this interval */
  select count(1) into cnt
  from t_recevent_inst ri
  inner join t_recevent re 
    on re.id_event = ri.id_event
  where ri.id_arg_interval = p_id_usage_interval
    and re.tx_type = 'EndOfPeriod'
    and ri.tx_status in('Running',     'Reversing');

  if cnt > 0 then
    p_status := -6;
    rollback;
    return;
  end if;

  /* Return error if this is a pull list and the parent billing group 
    is not soft closed 

   IF (p_tx_type = 'PullList' AND 
       EXISTS (SELECT status 
                   FROM vw_all_billing_groups_status 
                   WHERE id_billgroup = p_id_parent_billgroup AND
                               status != 'C'))
       BEGIN
           SET p_status = -7
           ROLLBACK
           RETURN 
       END 
  */
  
  select count(1) into cnt
  from t_billgroup_materialization bm
  where bm.tx_status = 'InProgress'
    and bm.id_usage_interval = p_id_usage_interval;
  
  if cnt = 0 then
     /* Cannot have more than one 'Full' materialization for a given interval */
    select count(1) into cnt
    from t_billgroup_materialization bm
    where bm.tx_status = 'Succeeded'
      and bm.tx_type = 'Full'
      and bm.id_usage_interval = p_id_usage_interval;

    if p_tx_type = 'Full' and cnt > 0 then
      p_status := -7;
      rollback;
      return;
    else
      /* insert a new row into t_billgroup_materialization */
      select seq_billgroup_materialization.nextval into p_id_materialization
      from dual;
      
      insert into t_billgroup_materialization(id_materialization, id_user_acc,
        dt_start, id_parent_billgroup, id_usage_interval,
        tx_status, tx_type)
      values(p_id_materialization, p_id_user_acc,    
        p_dt_start, p_id_parent_billgroup, p_id_usage_interval,
        'InProgress', p_tx_type);
      
      /* assign the new identity created */
      p_status := 0;
      commit;
    end if;

  else
     p_status := -8;
     rollback;
     return;
  end if;

end createbillgroupmaterialization;
 	