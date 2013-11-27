
      
/* ===========================================================
1) Parses the comma separated account identifiers (@accountArray) using the user defined function 'CSVToInt'
2) Validates that there are no duplicate accounts in @accountArray
3) Validates that the accounts are from the parent billing group (id_parent_billgroup)
4) Inserts name and description into t_billgroup_tmp
5) Inserts user specified account ids into  t_billgroup_member_tmp

Returns the following error codes:
    -1 : Unknown error occurred
    -2 : No accounts in @accountArray
    -3 : Duplicate accounts in @accountArray 
    -4 : Account(s) in @accountArray not a member of id_parent_billgroup 
    -5 : Accounts in @accounts are all the member accounts of id_parent_billgroup

=========================================================== */
CREATE OR REPLACE
procedure startchildgroupcreation(   
  p_id_materialization int,       
  p_tx_name nvarchar2,       
  p_tx_description nvarchar2,       
  p_id_parent_billgroup int,       
  p_accountarray varchar2,       
  p_status out int)  
as   
  cnt int; 
begin    

  p_status := -1;      /* Hold the user specified account id's in p_accountarray */

  /* Insert the accounts in p_accountarray into tmp_accounts */ 
  insert into tmp_accounts
  select * from table(dbo.csvtoint(p_accountarray));
  
  /* Error if there are no accounts */
  if sql%rowcount = 0 then
    p_status := -2;
    rollback;
    return;
  end if;
  
  /* Error if there are duplicate accounts in tmp_accounts */
  cnt := 0;
  select count(1) into cnt 
  from dual
  where exists (
    select id_acc
    from tmp_accounts
    group by id_acc having count(id_acc) > 1);

  if cnt > 0 then
    p_status := -3;
    rollback;
    return;
  end if;
  
  /* Error if the accounts in tmp_accounts are not a member of id_parent_billgroup */
  cnt := 0;
  select count(1) into cnt 
  from dual
  where exists (
    select id_acc
    from tmp_accounts
    where id_acc not in (
      select id_acc
      from t_billgroup_member
      where id_billgroup = p_id_parent_billgroup));

  if cnt > 0 then
    p_status := -4;
    rollback;
    return;
  end if;
  
  /* Error if the accounts in tmp_accounts are all the member accounts of id_parent_billgroup */
  
  cnt := 0;
  select count(1) into cnt
  from dual
  where (
    select count(id_acc)
    from t_billgroup_member
    where id_billgroup = p_id_parent_billgroup) 
    = (
    select count(bgm.id_acc)
    from t_billgroup_member bgm
    inner join tmp_accounts acc 
      on acc.id_acc = bgm.id_acc
    where bgm.id_billgroup = p_id_parent_billgroup);

  if cnt > 0 then
    p_status := -5;
    rollback;
    return;
  end if;
  
  /* Insert row into t_billgroup_tmp */ 
  insert into t_billgroup_tmp(
    id_materialization, tx_name, tx_description, 
    id_billgroup)
  values(
    p_id_materialization, p_tx_name, p_tx_description,
    seq_t_billgroup_tmp.nextval);
  
  /* Insert rows into t_billgroup_member_tmp */ 
  insert into t_billgroup_member_tmp(id_materialization, tx_name, id_acc)
  select p_id_materialization, p_tx_name, acc.id_acc
  from tmp_accounts acc;
  
  p_status := 0;
  commit;
  
end startchildgroupcreation;
    	