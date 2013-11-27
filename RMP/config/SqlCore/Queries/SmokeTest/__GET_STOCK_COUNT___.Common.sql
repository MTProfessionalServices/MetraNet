
		select COUNT(*) as stock_count from %%%NETMETER_PREFIX%%%t_pv_stocks where c_transactionid in (%%IN_CLAUSE%%)
		and c_tx_batchid = '%%BATCH_ID%%'
		