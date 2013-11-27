
create or replace function table_exists(tab varchar2)
return boolean
authid current_user
  /* so we have access to 'all_tables' view */
as
   exist int := 0;
begin
   /* check current user's schema first. form: <table> */
   select count(1)
     into exist
     from user_tables
    where table_name = upper(tab);

   if (exist > 0)
   then
      return true;
   end if;

   /* check owner qualified form:   <owner>.<table> */
   SELECT COUNT (1)
     INTO exist
     FROM all_tables
    WHERE owner = UPPER(TRIM(SUBSTR (tab,
                                     1,
                                     INSTR (tab,'.')-1
                                    )))
    and table_name = UPPER (TRIM(SUBSTR (tab,
                                     INSTR (tab,'.')+1
                                    )));

   return(exist > 0);
end;
			