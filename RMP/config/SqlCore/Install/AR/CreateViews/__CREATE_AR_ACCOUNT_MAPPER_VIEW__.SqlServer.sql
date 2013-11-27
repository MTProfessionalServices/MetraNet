
            CREATE  VIEW VW_AR_ACC_MAPPER        
            (ID_ACC, ExtAccount, ExtNamespace) 
            AS select am.id_acc, am.nm_login, am.nm_space from t_account_mapper am join t_namespace ns on am.nm_space= ns.nm_space where tx_typ_space='system_ar'
				