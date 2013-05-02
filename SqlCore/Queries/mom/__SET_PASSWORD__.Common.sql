           
				update t_user_credentials set tx_password=N'%%TX_PASSWORD%%' 
				where nm_login=N'%%NM_LOGIN%%' and nm_space=LOWER(N'%%NM_SPACE%%')
 			