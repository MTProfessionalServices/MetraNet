
declare 
	parenttype int;
	childtype int;
begin
	select id_type into parenttype
		from t_account_type 
		where upper(name) = upper('%%PARENT_NAME%%');
		
	select id_type into childtype
		from t_account_type 
		where upper(name) = upper('%%DESC_NAME%%');
	
    insert into t_acctype_descendenttype_map 
    (
      select parenttype, childtype from 
        (select count(1) as existsCount from t_acctype_descendenttype_map where id_type = parenttype and id_descendent_type = childtype) existance
      where
        existance.existsCount = 0
    );
end;
			