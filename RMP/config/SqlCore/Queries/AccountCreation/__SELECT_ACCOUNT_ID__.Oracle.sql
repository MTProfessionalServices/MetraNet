
			   select am.id_acc from t_account_mapper am where 
				 upper(am.nm_login) = upper(N'%%LOGIN_ID%%') and upper(am.nm_space) = upper(N'%%NAME_SPACE%%')
			