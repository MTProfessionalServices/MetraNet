
				SELECT id_acc
				FROM t_account_mapper map
				WHERE map.nm_login = '%%ALIAS%%'
				AND map.nm_space = '%%NAMESPACE%%'
			