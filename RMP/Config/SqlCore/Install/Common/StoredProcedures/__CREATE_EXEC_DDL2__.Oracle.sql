
create or replace procedure exec_ddl2(stmt varchar2,   code out int,   errm out varchar2)
authid current_user
as
  pragma autonomous_transaction;
begin
  execute immediate stmt;
  code := sqlcode;
  errm := sqlerrm;
exception
  when others then
    code := sqlcode;
    errm := sqlerrm;
end exec_ddl2;
			