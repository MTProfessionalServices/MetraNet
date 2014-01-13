
	      select sum(amount) as "Usage Total Amount"
	      from t_acc_usage where id_usage_interval = %%ID_INTERVAL%% 
		