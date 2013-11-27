
      
/* ===========================================================
This procedure operates only on unassigned accounts for the given interval (obtained via id_materialization).

1) Check that no interval-only adapter has executed successfully
2) If @accountArray is NULL then use all the unassigned accounts for the given interval 
3) Parses the comma separated account identifiers (@accountArray, if non-NULL) using the user defined function 'CSVToInt'
2) Validates that there are no duplicate accounts in @accountArray
3) Validates that the accounts in @accountArray are from the set of unassigned accounts
4) Inserts name and description into t_billgroup_tmp
5) Inserts unassigned account ids into  t_billgroup_member_tmp

Returns the following error codes:
    -1 : Unknown error occurred
    -2 : Full materialization has not occurred for this interval
    -3 : Atleast one interval-only adapter has executed successfully
    -4 : There are no unassigned accounts for the interval
    -5 : @accountArray is non-NULL and no accounts in @accountArray
    -6 : @accountArray is non-NULL and duplicate accounts in @accountArray 
    -7 : @accountArray is non-NULL and one or more accounts do not belong to the set of unassigned accounts
    -8 : The given billing group name already exists
=========================================================== */
create or replace 
procedure startuserdefinedgroupcreation(
  p_id_materialization int,    
  p_tx_name nvarchar2,    
  p_tx_description nvarchar2,    
  p_accountarray varchar2,    
  p_status out int) 
as
  cnt int;
  v_id_interval int;
begin

  p_status := -1;
  
  /* Hold the user specified account ids in p_accountarray*/
  
  /* Hold the unassigned account ids for this interval  */
  
  /* Store the interval id */
  select id_usage_interval into v_id_interval
  from t_billgroup_materialization
  where id_materialization = p_id_materialization;
  
   /* CR 14312 Error if a billing group with the given name already exists */
  select count(1) into cnt
  FROM t_billgroup bg
  WHERE tx_name = p_tx_name AND 
        id_usage_interval = v_id_interval;
      
  if cnt != 0 then
    p_status := -8;
    rollback;
    return;
  end if;
  
  /* Error if full materialization has not been done on this interval */
  select count(1) into cnt
  from dual
  where exists (
    select id_materialization
    from t_billgroup_materialization
    where tx_type = 'Full'
      and tx_status = 'Succeeded'
      and id_usage_interval = v_id_interval);
      
  if cnt != 1 then
    p_status := -2;
    rollback;
    return;
  end if;

  /* Error if at least one interval-only adapter has executed successfully */
  select count(1) into cnt from dual
  where exists (
    select id_instance
    from t_recevent_inst ri
    inner join t_recevent re 
      on re.id_event = ri.id_event
    where ri.id_arg_interval = v_id_interval
      and re.tx_billgroup_support = 'Interval'
      and re.tx_type = 'EndOfPeriod'
      and ri.tx_status = 'Succeeded');
      
  if cnt = 1 then
    p_status := -3;
    rollback;
    return;
  end if;

  /* Get all the open unassigned accounts for the interval */ 
  insert into tmp_unassignedaccounts
  select accountid
  from vw_unassigned_accounts vua
  where vua.state = 'O'
    and vua.intervalid = v_id_interval;

  select count(id_acc) into cnt from tmp_unassignedaccounts;
  
  if cnt = 0 then
    p_status := -4;
    rollback;
    return;
  end if;

  /* If p_accountarrayis NULL then transfer the accounts from 
    tmp_unassignedAccounts to tmp_accounts and continue */

  if p_accountarray is null then
    insert into tmp_accounts select * from tmp_unassignedaccounts;

  else
    /* p_accountarray is not NULL - do validations */
    
    /* Insert the accounts in p_accountarray into @accounts */ 
    insert into tmp_accounts 
    select * from table(dbo.csvtoint(p_accountarray));
  
    /* Error if there are no accounts */
    if sql%rowcount = 0 then
      p_status := -5;
      rollback;
      return;
    end if;

    /* Error if there are duplicate accounts in @accounts */
    select count(1) into cnt from dual
    where exists (
      select id_acc from tmp_accounts
      group by id_acc having count(id_acc) > 1);

    if cnt = 1 then
      p_status := -6;
      rollback;
      return;
    end if;

    /* Error if the accounts in @accounts are not a member of @unassignedAccounts */
    select count(1) into cnt from dual
    where exists (
      select id_acc
      from tmp_accounts acc
      where id_acc not in (
        select id_acc
        from tmp_unassignedaccounts));
    
    if cnt = 1 then
      p_status := -7;
      rollback;
      return;
    end if;
    
   end if; /* end ELSE */

  /* Insert row into t_billgroup_tmp */           
  INSERT into t_billgroup_tmp (id_billgroup, id_materialization, tx_name, tx_description)
  VALUES (seq_t_billgroup_tmp.nextval, p_id_materialization, p_tx_name, p_tx_description);
  
  /* Insert rows into t_billgroup_member_tmp */           
  INSERT INTO t_billgroup_member_tmp (id_materialization, tx_name, id_acc)           
  SELECT p_id_materialization, p_tx_name, acc.id_acc           
  FROM tmp_accounts acc;
  
  p_status := 0;

  COMMIT;

end startuserdefinedgroupcreation;
 	