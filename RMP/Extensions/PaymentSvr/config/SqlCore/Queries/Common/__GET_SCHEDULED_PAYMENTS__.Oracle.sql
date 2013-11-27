
		SELECT 
		    au.id_acc, 
				au.amount,
				au.am_currency, 
				ps.*, 
				ach.nm_authreceived, 
				ach.nm_validated 
		FROM 
		    t_acc_usage au, 
				t_pv_ps_paymentscheduler ps, 
				t_ps_ach ach
		WHERE 
		    au.id_sess = ps.id_sess and 
				ps.c_lastfourdigits = ach.nm_lastfourdigits(+) and 
				ps.c_bankaccounttype = ach.id_accounttype(+)
				and ps.c_originalaccountid = ach.id_acc(+) and 
				ps.c_routingnumber = ach.nm_routingnumber(+)
       