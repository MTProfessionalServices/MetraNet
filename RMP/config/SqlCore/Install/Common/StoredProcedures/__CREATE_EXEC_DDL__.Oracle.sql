
create or replace procedure exec_ddl(stmt varchar2)
authid current_user
as
  pragma autonomous_transaction;
begin
  execute immediate stmt;
end exec_ddl;
			