
		create global temporary table tmp_new_acc_interval_map
		  (
			id_acc number(10) not null,
			id_usage_interval number(10) not null,
			tx_status varchar2(1)
		  ) on commit preserve rows
	