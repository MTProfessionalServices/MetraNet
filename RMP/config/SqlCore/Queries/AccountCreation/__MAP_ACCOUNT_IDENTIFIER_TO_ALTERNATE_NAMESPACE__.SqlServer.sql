
        select am1.nm_login from t_account_mapper am1, t_account_mapper am2 where
        am2.id_acc=am1.id_acc and %%%UPPER%%%(am2.nm_login)=%%%UPPER%%%('%%FROM_ACCOUNT_ID%%') and 
        %%%UPPER%%%(am2.nm_space)=%%%UPPER%%%(N'%%FROM_NAMESPACE%%') and %%%UPPER%%%(am1.nm_space)=%%%UPPER%%%(N'%%TO_NAMESPACE%%')
			