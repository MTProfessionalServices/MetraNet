  
        select
				rr.id_rerun "Rerun Id", tx_filter "Filter", tx_tag Tag, dt_action "Time",
				tx_action "Last Action", rrh.id_acc UserId, 
				a.nm_login || '/' || a.nm_space UserName, 
				tx_comment "Comment"
        from t_account_mapper a, t_namespace n, t_rerun rr 
				inner join t_rerun_history rrh on rr.id_rerun = rrh.id_rerun
        where rrh.dt_action = (select max(rrh2.dt_action) from t_rerun_history rrh2 where rrh2.id_rerun = rr.id_rerun) 
        AND rrh.tx_action = (SELECT MIN(tx_action) FROM T_RERUN_HISTORY rrh2 
				WHERE rrh2.id_rerun = rr.id_rerun 
				AND dt_action =(SELECT MAX(dt_action) FROM T_RERUN_HISTORY WHERE id_rerun=rr.id_rerun))
        and rr.id_rerun = (select rrh3.id_rerun from t_rerun_history rrh3 where rrh3.id_rerun = rr.id_rerun and tx_action='CREATE' 
				and tx_comment = 'Batch[%%ID_BATCH_ENCODED%%]') and a.id_acc=rrh.id_acc 
				and a.nm_space=n.nm_space and n.tx_typ_space != 'metered'
        order by rr.id_rerun desc
      