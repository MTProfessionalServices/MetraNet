
		SELECT au.id_acc, au.amount,au.am_currency, ps.* 
		FROM t_acc_usage au, t_pv_ps_ach_debit ps
		WHERE au.id_sess = ps.id_sess and ps.c_paymentservicetransactionid = 
		'%%PS_TRANSACTION_ID%%'
		