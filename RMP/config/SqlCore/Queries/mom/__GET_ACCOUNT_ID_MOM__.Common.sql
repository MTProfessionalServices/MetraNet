           
				select * from t_account_mapper where LOWER(nm_login)=lower(N'%%USER_NAME%%') and lower(nm_space)=LOWER(N'%%NAME_SPACE%%')
 			