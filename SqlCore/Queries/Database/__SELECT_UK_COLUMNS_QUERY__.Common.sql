
			select pvp.nm_column_name from %%%NETMETER_PREFIX%%%t_unique_cons uc 
			join %%%NETMETER_PREFIX%%%t_unique_cons_columns ucc on uc.id_unique_cons = ucc.id_unique_cons
			join %%%NETMETER_PREFIX%%%t_prod_view_prop pvp on ucc.id_prod_view_prop = pvp.id_prod_view_prop
			where uc.nm_table_name = '%%TABLE_NAME%%'
		