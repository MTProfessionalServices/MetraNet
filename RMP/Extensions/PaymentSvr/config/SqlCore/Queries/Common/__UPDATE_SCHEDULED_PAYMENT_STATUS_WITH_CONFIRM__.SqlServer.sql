
		UPDATE t_pv_ps_paymentscheduler 
		SET c_confirmationreceived = N'%%PAYMENT_STATUS%%' 
		WHERE c_originalaccountid = %%ACCOUNT_ID%% and 
		c_originalintervalid = %%INTERVAL_ID%%
		