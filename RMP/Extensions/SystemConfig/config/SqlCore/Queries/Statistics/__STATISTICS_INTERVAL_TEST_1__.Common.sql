
				select id_sess, tx_UID, id_acc, id_payee, amount 
				from t_acc_usage where id_usage_interval = %%ID_INTERVAL%%  
			