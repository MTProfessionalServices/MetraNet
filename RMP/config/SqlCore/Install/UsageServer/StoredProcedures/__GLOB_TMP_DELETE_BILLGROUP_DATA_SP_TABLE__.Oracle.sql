
		create global temporary table tmp_delete_billgroups
		  (
			id_billgroup number(10) not null,
			id_usage_interval number(10) not null
		  ) on commit preserve rows
	