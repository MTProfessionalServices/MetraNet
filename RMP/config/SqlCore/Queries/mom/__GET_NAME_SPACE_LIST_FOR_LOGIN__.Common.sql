           
				select * from t_namespace where lower(tx_typ_space) <> 'system_mps' 
				and lower(tx_typ_space) <> 'metered' and lower(tx_typ_space) <>  'system_csr'
 			