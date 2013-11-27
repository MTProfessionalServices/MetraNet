
		create global temporary table tmp_uidlist	(
			tx_uid raw(16) not null
		) on commit preserve rows
    