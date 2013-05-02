
      select am.id_acc from t_account_mapper am where 
      %%%UPPER%%%(am.nm_login) = %%%UPPER%%%(N'%%LOGIN_ID%%') and %%%UPPER%%%(am.nm_space) = 
      %%%UPPER%%%(N'%%NAME_SPACE%%')
			