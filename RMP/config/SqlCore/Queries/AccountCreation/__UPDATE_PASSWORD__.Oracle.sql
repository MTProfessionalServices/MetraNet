
			     update t_user_credentials set tx_password = '%%PASSWORD%%'
					 where upper(nm_login) = upper(N'%%LOGIN_ID%%')
			