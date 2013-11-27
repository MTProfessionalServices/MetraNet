
		UPDATE t_pv_ps_paymentscheduler 
		SET c_currentstatus = (SELECT id_enum_data FROM t_enum_data where nm_enum_data = 'METRATECH.COM/PAYMENTSERVER/PAYMENTSTATUS/ARCHIVE')  
		WHERE c_originalaccountid = %%ACCOUNT_ID%% AND c_confirmationrequested = N'1' AND c_confirmationreceived = N'0' 
		AND c_currentstatus = (SELECT id_enum_data FROM t_enum_data where nm_enum_data = 'METRATECH.COM/PAYMENTSERVER/PAYMENTSTATUS/PENDING')
		