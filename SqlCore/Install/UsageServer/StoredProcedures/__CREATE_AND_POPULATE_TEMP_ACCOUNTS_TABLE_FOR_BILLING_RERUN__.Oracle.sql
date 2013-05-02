
      
/* ===========================================================
Populate the temporary table using @accountArray.
===========================================================*/
create or replace procedure createandpopulatetempaccts(
  p_accountarray varchar2,   
  p_status out int) 
as
begin

  p_status := -1;

  /* Insert the accounts in p_accountarray into p_tx_tablename */ 
  lock table tmp_billing_rerun_accounts in exclusive mode;
  delete tmp_billing_rerun_accounts;

  insert into tmp_billing_rerun_accounts
    select * from table(dbo.csvtoint(p_accountarray));

  p_status := 0;

end createandpopulatetempaccts;

   	