
create or replace function table_hasrows2(tab varchar2) return SYS_REFCURSOR AS st_cursor SYS_REFCURSOR;
begin
  open st_cursor for
  select table_hasrows1(tab) as value from dual;
  return st_cursor;
end;
			