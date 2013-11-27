
create or replace function  empty_cursor
return sys_refcursor
as
  cur sys_refcursor;
begin

  open cur for select 1 from dual where rownum < 0;
  return cur;

end;
			