
begin
	insert into t_account_type_view_map (id_type, id_account_view, account_view_name)
		select %%ACCOUNTTYPEID%%, id_enum_data, '%%REALACCOUNTVIEWNAME%%'
		from t_enum_data where upper(nm_enum_data) = upper('%%ACCOUNTVIEWNAME%%');

	if (sql%notfound) then 
		raise no_data_found; 
	end if;

	exception 
		when dup_val_on_index then null;
end;
			