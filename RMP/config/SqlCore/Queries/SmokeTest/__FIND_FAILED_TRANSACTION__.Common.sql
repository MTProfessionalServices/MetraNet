
		select COUNT(*) as error_count from %%%NETMETER_PREFIX%%%t_failed_transaction where tx_ErrorMessage like '%%%LIKE_CONDITION%%%'
		and tx_Batch_Encoded = '%%BATCH_ID%%'
		