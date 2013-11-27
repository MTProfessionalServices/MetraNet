
		update t_pv_ps_paymentscheduler 
		SET c_currentstatus = %%PAYMENT_STATUS%%,c_laststatusupdate =GetDate() 
		WHERE c_paymentservicetransactionid='%%PS_TRANSACTION_ID%%'
		