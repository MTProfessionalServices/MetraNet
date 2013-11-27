
		UPDATE t_pv_ps_paymentscheduler 
		SET c_currentstatus = (SELECT id_enum_data FROM t_enum_data where nm_enum_data = 'metratech.com/paymentserver/PaymentStatus/Archive')  
		WHERE c_originalaccountid = %%ACCOUNT_ID%% AND c_confirmationrequested = '1' AND c_confirmationreceived = '0' 
		AND c_currentstatus = (SELECT id_enum_data FROM t_enum_data where nm_enum_data = 'metratech.com/paymentserver/PaymentStatus/Pending')
		