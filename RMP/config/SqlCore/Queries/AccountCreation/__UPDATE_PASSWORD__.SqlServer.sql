
			     update t_user_credentials set tx_password = N'%%PASSWORD%%'
					 where %%%UPPER%%%(nm_login) = %%%UPPER%%%(N'%%LOGIN_ID%%')
			