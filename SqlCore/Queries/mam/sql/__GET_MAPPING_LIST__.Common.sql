
				select nm_login,am.nm_space,tx_desc,tx_typ_space from t_account_mapper am, 
				t_namespace ns where am.id_acc=%%ACCOUNT_ID%%  
				and am.nm_space=ns.nm_space and lower(ns.tx_typ_space) in ('metered', 'system_ar')
			