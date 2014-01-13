
        select rr.id_rerun "Rerun Id", tx_filter "Filter", tx_tag Tag,
				dt_action Time, tx_action "Last Action", rrh.id_acc UserId, 
				a.nm_login %%%CONCAT%%% '/' %%%CONCAT%%% a.nm_space UserName, tx_comment "Comment"
				from t_account_mapper a, t_namespace n, t_rerun rr 
				inner join t_rerun_history rrh on rr.id_rerun = rrh.id_rerun 
				where rrh.dt_action = (select max(rrh2.dt_action) 
				from t_rerun_history rrh2 where rrh2.id_rerun = rr.id_rerun) 
				and rr.id_rerun = (select rrh3.id_rerun from t_rerun_history rrh3
				/* CAUTION: Batch Encoded is case sensitive, so by converting it to upper
					we may mask a bug - although the goal for now is to make behavior consistent with SQL server
				*/
				where rrh3.id_rerun = rr.id_rerun and upper(tx_action)='CREATE' and UPPER(tx_comment) = UPPER('Batch[%%ID_BATCH_ENCODED%%]'))
				and a.id_acc=rrh.id_acc and a.nm_space=n.nm_space and lower(n.tx_typ_space) != 'metered' order by rr.id_rerun desc
 			