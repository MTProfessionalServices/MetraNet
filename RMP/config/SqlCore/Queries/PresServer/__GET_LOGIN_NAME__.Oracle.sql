
      select nm_login 
      from t_user_credentials 
      where upper(nm_login) = upper(N'%%LOGIN_ID%%') 
        and tx_password = N'%%PASSWORD%%' 
        and nm_space = N'%%NAME_SPACE%%'
	