
create or replace procedure getdbname(p_name_hash varchar2, p_name out varchar2)
as
begin
   select name
     into p_name
     from t_dbname_hash dn
    where lower(dn.name_hash) = lower(p_name_hash);
exception
   when no_data_found
   then
      p_name := '';
end;
			