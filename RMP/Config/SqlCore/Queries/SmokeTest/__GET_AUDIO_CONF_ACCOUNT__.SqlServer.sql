
			select top 1 tam.nm_login as name from t_po
				join t_base_props tbp on t_po.id_po = tbp.id_prop
				join t_sub on t_po.id_po = t_sub.id_po
				join t_account_mapper tam on t_sub.id_acc = tam.id_acc
			where tbp.nm_name like '%%OFFERING%%'
		  