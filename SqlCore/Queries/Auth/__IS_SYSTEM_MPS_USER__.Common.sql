
     SELECT 1 
     FROM t_account_mapper AM JOIN
     t_namespace NS ON NS.nm_space = AM.nm_space 
     WHERE NS.tx_typ_space = 'system_mps'
     AND AM.nm_login = '%%USERNAME%%' 
     AND AM.nm_space = '%%NAMESPACE%%'
				