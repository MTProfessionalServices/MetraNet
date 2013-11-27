
/* ===========================================================
Used in __GET_EOP_EVENT_INSTANCES_FOR_DISPLAY__
===========================================================*/
create or replace procedure CreatePopTmpBillGroupStatus(
  p_tx_tablename nvarchar2,   
  p_id_interval int,   
  p_status out int) 
as
  v_sql varchar2(4000);
begin
  p_status := -1;

  /* Drop the table @tx_tableName if it exists*/

  if table_exists(p_tx_tablename) then
    exec_ddl('drop table ' || p_tx_tableName);
  end if;

  /* Create the table @tx_tableName */ 
  
  exec_ddl('CREATE TABLE ' || p_tx_tablename || ' (
      id_billgroup number(10) NOT NULL,
      id_usage_interval number(10) NOT NULL,
      status CHAR(1) NOT NULL)');

  /* Insert data from vw_all_billing_groups_status into @tx_tableName */

  if(p_id_interval is null) then
    v_sql := '
      INSERT INTO ' || p_tx_tablename || ' 
      SELECT * FROM vw_all_billing_groups_status ';
    execute immediate v_sql;
  else
   v_sql := '
      INSERT INTO ' || p_tx_tablename || ' 
      SELECT * FROM vw_all_billing_groups_status 
      WHERE id_usage_interval = ' || p_id_interval;
   execute immediate v_sql;
  end if;

  p_status := 0;
end CreatePopTmpBillGroupStatus;
    