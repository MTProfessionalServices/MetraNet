
begin
	insert into t_account_type_view_map (id_type, id_account_view)
		select %%ACCOUNTTYPEID%%, id_enum_data
		from t_enum_data where upper(nm_enum_data) = upper('%%ACCOUNTVIEWNAME%%');

	if (sql%notfound) then 
		raise no_data_found; 
	end if;

	exception 
		when dup_val_on_index then null;
end;
			