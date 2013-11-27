
create or replace procedure getdbnamehash(p_name varchar2, p_name_hash out varchar2)
as
   v_name varchar2(30);
   v_name_hash varchar2(128);
begin
   /* First compute the hash */
   select case
             when length(p_name) > 30
                then substr(p_name, 1, 21) || '_' || to_char(ora_hash(lower(p_name)), 'FMXXXXXXXX')
             else p_name
          end
     into p_name_hash
     from dual;

   /* Not likely, but might need collision detection here. */

   /* Insert the name, hash pair for reference */
   begin
      insert into t_dbname_hash
                  (name, name_hash
                  )
           values (p_name, p_name_hash
                  );
   exception
      when dup_val_on_index
      then
         null;
   end;
end;
			