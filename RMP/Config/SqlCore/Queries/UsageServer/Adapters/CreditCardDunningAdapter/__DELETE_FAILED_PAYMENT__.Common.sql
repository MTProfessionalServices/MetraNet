
			   delete from t_failed_payment where 
						id_interval = %%INTERVAL_ID%% and
						id_acc = %%ACCOUNT_ID%% and 
						id_payment_instrument = N'%%PI_ID%%'