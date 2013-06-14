
				SELECT map.nm_login nm_login, map.nm_space nm_space
                /*, map.id_acc id_acc, acc.dt_crt dt_crt */
                from t_account_mapper map
				INNER JOIN t_account acc on map.id_acc=acc.id_acc 
				