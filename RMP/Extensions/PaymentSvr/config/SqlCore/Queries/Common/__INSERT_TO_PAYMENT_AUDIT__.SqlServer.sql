
        insert into t_payment_audit (
		id_acc, 
		nm_action, 
	   	nm_routingnumber, 
		nm_lastfourdigits, 
		nm_accounttype, 
		nm_bankname, 
		nm_expdate, 
	    id_expdatef, 
		tx_IP_subscriber,
		tx_phone_number,
		tx_IP_CSR,
		id_CSR,
		tx_notes)
		values (
		%%ACCOUNT_ID%%,
		N'%%ACTION_NAME%%',
		N'%%ROUTING_NUMBER%%',
		N'%%LAST_FOUR_DIGITS%%',
		N'%%ACCOUNT_TYPE%%',
		N'%%BANK_NAME%%',
		N'%%EXP_DATE%%',
		%%EXP_DATE_FORMAT%%,
		N'%%SUBSCRIBER_IP%%',
		N'%%PHONE_NUNBER%%',
		N'%%CSR_IP%%',
		N'%%CSR_ID%%',
		N'%%NOTES%%')
	  