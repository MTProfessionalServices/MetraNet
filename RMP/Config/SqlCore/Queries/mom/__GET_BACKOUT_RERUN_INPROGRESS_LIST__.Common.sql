            
			select rr.id_rerun "RerunId",
			tx_filter Filter, tx_tag Tag,dt_action Time,
			tx_action "LastAction", rrh.id_acc UserId, 
			a.nm_login %%%CONCAT%%% '/' %%%CONCAT%%% a.nm_space UserName,
			(select rrh3.tx_comment from t_rerun_history rrh3 
			where rrh3.id_rerun = rr.id_rerun and %%%UPPER%%%(rrh3.tx_action) = 'CREATE') "Comment"
			from t_account_mapper a, 
			t_namespace n, t_rerun rr 
			inner join t_rerun_history rrh on rr.id_rerun = rrh.id_rerun 
			where rrh.dt_action = (select max(rrh2.dt_action) from t_rerun_history rrh2 
			where rrh2.id_rerun = rr.id_rerun) and a.id_acc=rrh.id_acc 
			and a.nm_space=n.nm_space and lower(n.tx_typ_space) != 'metered' 
			and not %%%UPPER%%%(tx_action)='END ABANDON' 
			order by rr.id_rerun desc
 			