select id_invoice, invoice_string  
				from t_invoice
				where 
				id_acc = %%ACCOUNT_ID%% and id_interval = %%INTERVAL_ID%%  and namespace = '%%NAME_SPACE%%'
		