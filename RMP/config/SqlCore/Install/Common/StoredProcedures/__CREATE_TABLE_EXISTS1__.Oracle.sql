
create or replace function table_exists1(tab varchar2)
return int
authid current_user
  /* set authid current_user so we have access to 'all_tables' view */
as
begin

  /* use: table_exits() returns 1 if true, 0 otherwise */

  return case when table_exists(tab) then 1 else 0 end;

end;
			