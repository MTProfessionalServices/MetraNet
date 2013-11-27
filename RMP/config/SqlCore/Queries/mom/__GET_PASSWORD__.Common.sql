           
				select tx_password password from t_user_credentials where LOWER(nm_login)=LOWER(N'%%NM_LOGIN%%') and lower(nm_space)=LOWER(N'%%NM_SPACE%%')
 			