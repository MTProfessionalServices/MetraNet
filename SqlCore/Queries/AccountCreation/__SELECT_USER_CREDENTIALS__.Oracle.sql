
			   select nm_login, tx_password, nm_space from t_user_credentials
				 where upper(nm_login) = upper(N'%%LOGIN_ID%%') and tx_password = N%%PASSWORD%%'
				 and upper(nm_space) = upper(N'%%NAME_SPACE%%')
			