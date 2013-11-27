
      
/* ===========================================================
  Validate the following for the given materialization:
    1) The accounts in t_billgroup_source_acc are not repeated
    2) The accounts in t_billgroup_member_tmp are 
        not repeated i.e. each account is matched to exactly 
        one billing group name. 
    3) All accounts in t_billgroup_source_acc are present in t_billgroup_member_tmp
    4) Each billing group has atleast one account.


Returns the following error codes - for the given materialization:
    -1 : Unknown error occurred
    -2 : If there are duplicate accounts in t_billgroup_source_acc 
    -3 : If there are duplicate accounts in t_billgroup_member_tmp 
    -4 : If all accounts in t_billgroup_source_acc are not present in t_billgroup_member_tmp
    -5 : Each billing group in t_billgroup_tmp has atleast one account
    -6 : If there are duplicate billing group names in t_billgroup_tmp
=========================================================== */
create or replace procedure validatebillgroupassignments(
  p_id_materialization int,    
  p_billinggroupscount out int,    
  p_status out int)
  
as
  cnt int;
  numjoinaccounts int;
  numoriginalaccounts int;

begin

  /* initialize p_status to unknown error  */
  p_status := -1;
  p_billinggroupscount := 0;
  
  /* check for duplicate id_acc in t_billgroup_source_acc */
  select count(1) into cnt from dual
  where exists (
    select id_acc
    from t_billgroup_source_acc
    where id_materialization = p_id_materialization
    group by id_acc having count(id_acc) > 1);

  if cnt = 1 then
    p_status := -2; 
    return;
  end if;

  /*  check for duplicate id_acc in t_billgroup_member_tmp  */
  select count(1) into cnt from dual
  where exists (
    select id_acc
    from t_billgroup_member_tmp
    where id_materialization = p_id_materialization
    group by id_acc having count(id_acc) > 1);
    
  if cnt = 1 then
    p_status := -3; 
    return;
  end if;

  /* check that all accounts in t_billgroup_source_acc are present in           
    t_billgroup_member_tmp */
  select count(bgsa.id_acc) into numjoinaccounts
  from t_billgroup_source_acc bgsa
  inner join t_billgroup_member_tmp bgt 
    on bgt.id_acc = bgsa.id_acc
    and bgt.id_materialization = bgsa.id_materialization
  where bgsa.id_materialization = p_id_materialization;
  
  select count(id_acc) into numoriginalaccounts
  from t_billgroup_source_acc
  where id_materialization = p_id_materialization;

  if numjoinaccounts <> numoriginalaccounts then 
    p_status := -4; 
    return;
  end if;

  /* Check that each billing group in t_billgroup_tmp has atleast one account */
  select count(1) into cnt from dual
  where exists (
    select tx_name
    from t_billgroup_tmp
    where tx_name not in (
          select tx_name
          from t_billgroup_member_tmp
          where id_materialization = p_id_materialization)
      and id_materialization = p_id_materialization);

  if cnt = 1 then
    p_status := -5; 
    return;
  end if;

  /* Check that there are no duplicate billing group names in t_billgroup_member */
  select count(1) into cnt from dual
  where exists (
      select tx_name
      from t_billgroup_tmp
      where id_materialization = p_id_materialization
      group by tx_name having count(tx_name) > 1);

  if cnt = 1 then
    p_status := -6; 
    return;
  end if;

  select count(id_billgroup) into p_billinggroupscount
  from t_billgroup_tmp
  where id_materialization = p_id_materialization;

    p_status := -0; 

end validatebillgroupassignments;
     	