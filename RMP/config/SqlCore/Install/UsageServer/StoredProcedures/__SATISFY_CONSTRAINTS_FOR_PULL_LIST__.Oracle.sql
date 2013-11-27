

/* ===========================================================
This query adds extra accounts to the t_billgroup_member_tmp table
in order to satisfy grouping constraints specified in the t_billgroup_constraint table.

For the given id_materialization, the t_billgroup_member_tmp table
contains the mapping of the pull list name to the accounts specified by the user.

For each of the user specified accounts 
  - get the group which it belongs to 
  - get those accounts in the group which do not belong to the set of user specified accounts
  - if any of the accounts obtained above do not belong to the parent billing group 
        then return error
      else 
        add those accounts into t_billgroup_member_tmp if they don't exist.
        (new accounts are added with the b_extra flag set to 1)
              

Returns:
-1 if an unknown error has occurred
-2 one or more accounts needed to satisfy the constraints do not belong to the parent billing group
-3 the parent billing group becomes empty due to constraints
============================================================== */
create or replace 
procedure satisfyconstraintsforpulllist(
  p_id_materialization int,    
  p_id_parent_billgroup int,    
  p_status out int) 
as
  cnt int;
  v_id_usage_interval int;
  v_pulllistname nvarchar2(50);
  
  a int;
  b int;
  c int;
  
begin
  /* initialize p_status to failure (-1) */
  p_status := -1;

  /* Store the id_usage_interval */

  select id_usage_interval into v_id_usage_interval
  from t_billgroup_materialization
  where id_materialization = p_id_materialization;
  
  select tx_name into v_pulllistname
  from t_billgroup_member_tmp
  where id_materialization = p_id_materialization
    and rownum = 1;

  /* Select the candidate groups based on the user specified accounts
  in t_billgroup_member_tmp for this materialization */ 
  insert into tmp_otherbillgroups
  select bc.id_group
  from t_billgroup_member_tmp bgmt
  inner join t_billgroup_constraint bc 
    on bc.id_acc = bgmt.id_acc
  where bc.id_usage_interval = v_id_usage_interval
    and bgmt.id_materialization = p_id_materialization;

  /* Select the extra accounts */ 
  insert into tmp_accounts
  select id_acc
  from t_billgroup_constraint
  where id_group in
    (select id_group from tmp_otherbillgroups)
    and id_usage_interval = v_id_usage_interval
    /* do not add accounts that have been specified by the user */
    and id_acc not in
      (select id_acc from t_billgroup_member_tmp
      where id_materialization = p_id_materialization);

  /* Error if the accounts in tmp_accounts are not a member of id_parent_billgroup */
  cnt := 0;
  select count(1) into cnt from dual
  where exists (
        select count(id_acc)
        from tmp_accounts)
    and exists (
        select id_acc
        from tmp_accounts
        where id_acc not in (
          select id_acc
          from t_billgroup_member
          where id_billgroup = p_id_parent_billgroup));

  if cnt > 0 then
    p_status := -2;
    rollback;
    return;
  end if;

   /* Check that not all the accounts of the parent billing group are being pulled out */
  select count(id_acc) into c from t_billgroup_member
  where id_billgroup = p_id_parent_billgroup;

  select count(id_acc) into b from t_billgroup_member_tmp
  where id_materialization = p_id_materialization;

  select count(id_acc) into c from tmp_accounts;

  if (a + b) = c then
    p_status := -3;
    rollback;
    return;
  end if;

  /* Add the extra accounts into t_billgroup_member_tmp */ 
  insert into t_billgroup_member_tmp(id_materialization,
    tx_name, id_acc, b_extra)
  select p_id_materialization,
    v_pulllistname, id_acc, 1
  from tmp_accounts;

  p_status := 0;
  commit;

end satisfyconstraintsforpulllist;
        	