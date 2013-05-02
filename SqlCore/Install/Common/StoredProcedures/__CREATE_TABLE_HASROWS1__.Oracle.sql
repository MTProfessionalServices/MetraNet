
create or replace function table_hasrows1(tab varchar2)
return int
authid current_user
as
begin

  return case when table_hasrows(tab)
      then 1 else 0 end;

end;
			