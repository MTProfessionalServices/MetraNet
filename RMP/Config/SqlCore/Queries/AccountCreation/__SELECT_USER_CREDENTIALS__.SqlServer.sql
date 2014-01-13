
			   select nm_login, tx_password, nm_space from t_user_credentials
				 where %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%LOGIN_ID%%') and tx_password = N'%%PASSWORD%%'
				 and %%%UPPER%%%(nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
			