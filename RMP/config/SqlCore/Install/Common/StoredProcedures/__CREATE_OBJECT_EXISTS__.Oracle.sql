
create or replace function object_exists (
   obj varchar2
)
   return boolean authid current_user   /* so we have access to 'all_tables' view */
as
   exist int := 0;
begin   /* check current user's schema first. form: <table> */
   select count (1)
   into   exist
   from   user_objects
   where  object_name = upper (obj);

   if (exist > 0) then
      return true;
   end if;

   /* check owner qualified form:   <owner>.<table> */
   select count (1)
   into   exist
   from   all_objects
   where  owner || '.' || object_name = upper (obj);

   return (exist > 0);
end;
			