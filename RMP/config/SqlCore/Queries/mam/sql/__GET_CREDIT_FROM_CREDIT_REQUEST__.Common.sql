
				select * from t_pv_AccountCredit pv, t_acc_usage au where pv.c_RequestID=%%REQUEST_ID%%
				and au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval
			