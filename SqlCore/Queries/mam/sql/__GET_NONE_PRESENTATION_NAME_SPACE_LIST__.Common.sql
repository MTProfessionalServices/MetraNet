
				select nm_space,tx_desc from t_namespace where lower(tx_typ_space) in ('metered', 'system_ar')
			