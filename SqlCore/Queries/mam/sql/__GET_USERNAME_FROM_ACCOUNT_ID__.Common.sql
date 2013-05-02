
				SELECT * from t_account_mapper, t_namespace where t_account_mapper.id_acc=%%ACCOUNT_ID%% 
				and t_account_mapper.nm_space=t_namespace.nm_space 
				and lower(t_namespace.tx_typ_space) in ('system_mps', 'system_csr', 'system_rate', 'system_ops', 'metered')
			