
			UPDATE t_adjustment_transaction  set c_Status = 'A'
			/* also update billing interval id, because now is */
			/* when transaction really considered adjusted */
			,id_usage_interval = dbo.GetCurrentIntervalID(%%%SYSTEMDATE%%%, %%%SYSTEMDATE%%%, id_acc_payer)
			%%PREDICATE%%
			AND c_Status = 'P'
			