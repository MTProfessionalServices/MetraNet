
		      select id_account_view,nm_account_view,nm_table_name from t_account_view_log 
		      WHERE lower(nm_account_view) = lower(N'%%AV_NAME%%')
     