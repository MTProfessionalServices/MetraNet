
					update t_failed_payment set n_retryCount = %%RETRYCOUNT%%, dt_lastretry = %%SYSDATE%%
					where id_interval = %%INTERVAL_ID%% and id_acc = %%ACCOUNT_ID%% and id_payment_instrument = N'%%PI_ID%%'