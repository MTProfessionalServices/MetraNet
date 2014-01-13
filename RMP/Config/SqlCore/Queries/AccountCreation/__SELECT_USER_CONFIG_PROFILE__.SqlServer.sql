
			     select p.val_tag, p.id_profile, p.nm_tag, su.nm_login, 
					 ls.tx_lang_code, p.val_tag, am.id_acc, ls.id_site 
					 from 
					 t_site_user su, t_profile p, t_account_mapper am, 
			     t_localized_site ls where %%%UPPER%%%(su.nm_login) = %%%UPPER%%%(N'%%LOGIN_ID%%') 
				   and su.id_profile = p.id_profile and %%%UPPER%%%(am.nm_login) = %%%UPPER%%%(su.nm_login) and 
					 %%%UPPER%%%(am.nm_space) = %%%UPPER%%%(N'%%NAME_SPACE%%') and ls.id_site = su.id_site
			