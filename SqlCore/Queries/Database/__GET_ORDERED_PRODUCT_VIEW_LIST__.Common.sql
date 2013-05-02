
		select nm_name from %%%NETMETER_PREFIX%%%t_prod_view where LOWER(nm_table_name) != 't_acc_usage' ORDER BY id_prod_view
		