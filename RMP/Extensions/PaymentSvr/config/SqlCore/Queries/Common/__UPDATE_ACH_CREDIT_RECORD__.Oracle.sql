
		UPDATE t_pv_ps_ach_credit
		SET c_currentstatus = %%PAYMENT_STATUS%% 
		WHERE c_paymentservicetransactionid='%%PS_TRANSACTION_ID%%'
		