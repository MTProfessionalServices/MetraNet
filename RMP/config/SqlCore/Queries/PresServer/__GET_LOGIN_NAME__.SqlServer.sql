
      select nm_login 
      from t_user_credentials 
      where nm_login = N'%%LOGIN_ID%%' 
        and tx_password = N'%%PASSWORD%%' 
        and nm_space = LOWER(N'%%NAME_SPACE%%')
			