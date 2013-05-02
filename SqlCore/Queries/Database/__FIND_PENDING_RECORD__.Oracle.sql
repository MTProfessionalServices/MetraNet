
				select *
				from t_acc_usage au, t_pv_AccountCreditRequest pv
				where pv.id_sess = au.id_sess and au.id_usage_interval=pv.id_usage_interval and au.id_sess = %%SESSION_ID%% and pv.c_status = 'PENDING'
			