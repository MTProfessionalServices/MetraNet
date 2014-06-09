
        select tam.nm_login, 
			tam.nm_space,
			tuc.tx_password, 
			tuc.dt_expire, 
			tuc.dt_last_login, 
			tuc.dt_last_logout, 
			tuc.num_failures_since_login,
			tuc.dt_auto_reset_failures, 
			tuc.b_enabled,
			/* Sign of authentication type: if "0" then use ActiveDirectory source for gets credential data, else use internal MetraNet source. */
			/* Unlike C++ code the C# enum contains 0 and 1 values instead of 1 and 2 */
			CASE WHEN tuc.nm_login IS NULL THEN 1 ELSE 0 END AS auth_type
		from 
			t_account_mapper tam  %%%READCOMMITTED%%% LEFT JOIN t_user_credentials tuc  %%%READCOMMITTED%%% ON tuc.nm_login = tam.nm_login AND tuc.nm_space = tam.nm_space

		where 
			%%%UPPER%%%(tam.nm_login) = %%%UPPER%%%(N'%%USERNAME%%') and %%%UPPER%%%(tam.nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%') 
        