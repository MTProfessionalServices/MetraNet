
			   insert into t_failed_payment 
				(id_interval, id_acc, id_payment_instrument, dt_original_trans, 
							 nm_description, nm_currency, n_amount, n_retrycount) values 
				(%%INTERVAL_ID%%, %%ACCOUNT_ID%%, N'%%PI_ID%%', %%DT_ORIG%%, 
							 N'%%DESC%%', N'%%CURRENCY%%', %%AMOUNT%%, 0)