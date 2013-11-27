            
        select rrh.tx_action Action, rrh.dt_action Time, 
				rrh.id_acc UserId, 
				a.nm_login %%%CONCAT%%% '/' %%%CONCAT%%% a.nm_space UserName,
				rrh.tx_comment Details 
				from t_rerun_history rrh 
				left outer join t_account_mapper a on rrh.id_acc=a.id_acc 
				left outer join t_namespace n on a.nm_space=n.nm_space 
				where id_rerun = %%ID_RERUN%% and lower(n.tx_typ_space) != 'metered' 
				order by dt_action
 			