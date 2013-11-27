
                            select am1.nm_login from t_account_mapper am1, t_account_mapper am2 where
                            am2.id_acc=am1.id_acc and upper(am2.nm_login)=upper('%%FROM_ACCOUNT_ID%%') and 
                            upper(am2.nm_space)=upper(N'%%FROM_NAMESPACE%%') and upper(am1.nm_space)=upper(N'%%TO_NAMESPACE%%')
			