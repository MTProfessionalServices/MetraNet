
	UPDATE t_pv_ps_paymentscheduler set c_currentstatus = %%PAYMENT_STATUS%%,
	c_paymentprovidercode=%%PAYMENTPROVIDERCODE%%, c_paymentproviderstatus='%%RESPSTRING%%', c_laststatusupdate =GetDate() 
	WHERE c_paymentservicetransactionid='%%PS_TRANSACTION_ID%%'
	