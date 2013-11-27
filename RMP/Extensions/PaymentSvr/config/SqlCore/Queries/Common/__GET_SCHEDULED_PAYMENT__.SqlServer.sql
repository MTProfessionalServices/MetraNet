
		SELECT 
		    au.id_acc, 
				au.amount,au.am_currency, 
				ps.*, 
				ach.nm_authreceived, 
				ach.nm_validated 
		from 
			t_ps_ach ach
		    LEFT OUTER JOIN t_pv_ps_paymentscheduler ps on ps.c_lastfourdigits = ach.nm_lastfourdigits
		    and ps.c_bankaccounttype = ach.id_accounttype
		    and ps.c_originalaccountid = ach.id_acc
		    and ps.c_routingnumber = ach.nm_routingnumber
			JOIN t_acc_usage au on au.id_sess = ps.id_sess
		WHERE 
		    ps.c_paymentservicetransactionid = N'%%PS_TRANSACTION_ID%%'
		