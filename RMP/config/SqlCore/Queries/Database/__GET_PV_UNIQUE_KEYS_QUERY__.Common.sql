
			select uc.constraint_name, uc.nm_table_name from %%%NETMETER_PREFIX%%%t_unique_cons uc 
			join %%%NETMETER_PREFIX%%%t_prod_view pv on pv.id_prod_view = uc.id_prod_view
			where pv.nm_table_name = '%%TABLE_NAME%%'
		