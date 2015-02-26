WHENEVER SQLERROR EXIT SQL.SQLCODE 
SET SERVEROUTPUT ON

declare
  version varchar2(15);
  any_rows_found number;
begin
  select '8.1.1' into version from dual;
  
  select count(*) into any_rows_found from t_sys_upgrade  where target_db_version = version;
  if any_rows_found =0 then
    DBMS_OUTPUT.PUT_LINE('Insert a row into t_sys_upgrade');
    insert into t_sys_upgrade 
      (UPGRADE_ID, target_db_version, dt_start_db_upgrade, db_upgrade_status) 
    values 
      ((SELECT MAX(upgrade_id)+1 FROM t_sys_upgrade), version, sysdate, 'R');
  end if;
end;
/
