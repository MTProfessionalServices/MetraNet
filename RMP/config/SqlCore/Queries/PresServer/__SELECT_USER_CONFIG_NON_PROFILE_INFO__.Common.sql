
      select su.nm_login, su.id_profile, ls.tx_lang_code, am.id_acc, 
      ls.id_site from t_site_user su, t_account_mapper am, 
      t_localized_site ls where %%%UPPER%%%(su.nm_login) = %%%UPPER%%%(N'%%LOGIN_ID%%') and 
      am.nm_login = su.nm_login and %%%UPPER%%%(am.nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%')
      and ls.id_site = su.id_site
			