
        insert into t_payment_audit (
		id_audit,
		id_acc, 
		nm_action, 
	   	nm_routingnumber, 
		nm_lastfourdigits, 
		nm_accounttype, 
		nm_bankname, 
		nm_expdate, 
	    id_expdatef,
	    dt_occurred,
		tx_IP_subscriber,
		tx_phone_number,
		tx_IP_CSR,
		id_CSR,
		tx_notes)
		values (
		ps_seq_audit.NextVal,
		%%ACCOUNT_ID%%,
		'%%ACTION_NAME%%',
		'%%ROUTING_NUMBER%%',
		'%%LAST_FOUR_DIGITS%%',
		'%%ACCOUNT_TYPE%%',
		'%%BANK_NAME%%',
		'%%EXP_DATE%%',
		%%EXP_DATE_FORMAT%%,
	    GetUTCDate(),
		'%%SUBSCRIBER_IP%%',
		'%%PHONE_NUNBER%%',
		'%%CSR_IP%%',
		'%%CSR_ID%%',
		'%%NOTES%%')
	  