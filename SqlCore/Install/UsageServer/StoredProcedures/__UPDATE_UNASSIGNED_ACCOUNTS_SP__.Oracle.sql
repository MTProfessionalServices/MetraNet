
/* ===========================================================
1) Parses the comma separated account identifiers (@accountArray) using the user defined function 'CSVToInt'
2) Validates that there are no duplicate accounts in @accountArray
3) Validates that the accounts are unassigned
4) Validates that the accounts aren't already in the state specified by @state
5) If @checkUsage is 1 then
        - Separates the accounts in @accountArray into accounts which
          have usage and those which don't
        - Updates the status of the unassigned accounts which don't have usage to @state
        - Returns the list of accounts which have usage
6) If @checkUsage is 0 then
        - Updates the status of all accounts in @accountArray to @state
7) If @isTransactional is 1 then the procedure uses a transaction otherwise
    it is non-transactional.
7) Updates the status of the interval to 'H' if necessary

Returns the following error codes:
    -1 : Unknown error occurred
    -2 : No accounts in @accountArray
    -3 : Duplicate accounts in @accountArray 
    -4 : Account(s) in @accountArray not a member of the unassigned group of accounts 
    -5 : Accounts(s) in @accountArray already in state specified by @state
  
=========================================================== */
create or replace 
procedure UpdateUnassignedAccounts (
  p_accountarray varchar2,   
  p_id_interval int,   
  p_state char,   
  p_checkusage int,   /* 0 or 1 */
  p_istransactional int,   /* 0 or 1 */
  p_status out int,
  p_cur out sys_refcursor
 ) 
as
  cnt int;
  ignored_status int;
begin
  p_status := -1;

  /* Hold the user specified account id's in @accountArray */
	delete from tmp_accounts_hasusage;

  /* Insert the accounts in @accountArray into @accounts */ 
  insert into tmp_accounts_hasusage
  select column_value, 'N'
  from table(dbo.csvtoint(p_accountarray));

 /* Error if there are no accounts */
  if (sql%rowcount = 0) then
    p_status := -2;
    return;
  end if;

  /* Error if there are duplicate accounts in @accounts */
  select count(1) into cnt from dual
  where exists (
      select id_acc
      from tmp_accounts
      group by id_acc 
      having count(id_acc) > 1);

   if cnt = 1 then
      p_status := -3;

      if (p_istransactional = 1) then
         rollback;
      end if;

      return;
   end if;
   
  /* Error if the accounts in @accounts are not a member unassigned accounts */
  select count(1) into cnt from dual
  where not exists (
      select *
      from tmp_accounts_hasusage acc
      inner join vw_unassigned_accounts ua 
        on ua.accountid = acc.id_acc
      where ua.intervalid = p_id_interval);
  
  if (cnt = 1) then
    p_status := -4;

    if (p_istransactional = 1) then
       rollback;
    end if;

    return;
  end if;

  /* Error if the accounts in @accounts are already in the state specified by @state */
  select count(1) into cnt from dual
  where exists (
      select 1
      from tmp_accounts_hasusage acc
      inner join vw_unassigned_accounts ua 
        on ua.accountid = acc.id_acc
      and ua.state = p_state
      where ua.intervalid = p_id_interval);

  if (cnt = 1) then
    p_status := -5;

    if (p_istransactional = 1) then
       rollback;
    end if;

    return;
  end if;

  /* Separate accounts into two groups. Those that have usage and those that don't.  */
  
  if (p_checkusage = 1) then

    update tmp_accounts_hasusage acc
    set hasusage = 'Y'
    where exists (
        select 1
        from t_acc_usage au
        where au.id_usage_interval = p_id_interval
          and au.id_acc = acc.id_acc);
    
    /* Update the accounts which don't have usage to @state */
    update t_acc_usage_interval aui
    set tx_status = p_state
    where exists (
        select 1
        from tmp_accounts_hasusage accounts
        where accounts.id_acc = aui.id_acc
          and accounts.hasusage = 'N'
          and aui.id_usage_interval = p_id_interval);

  else
    
    /* Update all accounts to @state */
    update t_acc_usage_interval aui
    set tx_status = p_state
    where exists (
        select 1
        from tmp_accounts_hasusage accounts
        where accounts.id_acc = aui.id_acc
        and aui.id_usage_interval = p_id_interval);

  end if;
  
  p_status := 0;
  
  /* Update the status in t_usage_interval. The output status does not matter
     because the interval may not be   updated to hard closed.      */ 
  UpdIntervalStatusToHardClosed( p_id_interval, 0, ignored_status);
  
  /* Return the list of accounts which have usage */
  open p_cur for
  select id_acc
  from tmp_accounts_hasusage
  where hasusage = 'Y';
  
  if (p_istransactional = 1) then
    commit;
  end if;

end UpdateUnassignedAccounts;
 	