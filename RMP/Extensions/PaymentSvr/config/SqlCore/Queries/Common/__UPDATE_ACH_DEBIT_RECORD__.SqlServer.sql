
		UPDATE t_pv_ps_ach_debit 
		SET c_currentstatus = %%PAYMENT_STATUS%% 
		WHERE c_paymentservicetransactionid='%%PS_TRANSACTION_ID%%'
		