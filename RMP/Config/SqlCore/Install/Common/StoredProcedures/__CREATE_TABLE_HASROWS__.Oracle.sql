
CREATE OR REPLACE
function table_hasrows(tab varchar2)
return boolean
authid current_user
as
  hasrows int := 0;
begin

  if table_exists(tab) then
    execute immediate '
        select count(1) from dual
        where exists (select 1 from ' || tab || ')'
        into hasrows;
    /* into hasrows */
  end if;

  return hasrows > 0;

end;
			