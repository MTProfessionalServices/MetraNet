     
			select rr.id_rerun "RerunId", tx_filter Filter, tx_tag Tag,
            dt_action Time, tx_action "LastAction", rrh.id_acc UserId, 
            a.nm_login %%%CONCAT%%% '/' %%%CONCAT%%% a.nm_space UserName,
            (select rrh3.tx_comment from t_rerun_history rrh3 where 
            rrh3.id_rerun = rr.id_rerun and %%%UPPER%%%(rrh3.tx_action) = 'CREATE') "Comment"
            from t_rerun rr
            inner join t_rerun_history rrh 
            on rr.id_rerun = rrh.id_rerun
            inner join t_account_mapper a
            on rrh.id_acc = a.id_acc
            inner join t_namespace n
            on lower(a.nm_space) = lower(n.nm_space)
            where lower(n.tx_typ_space)!= 'metered'
            and %%%UPPER%%%(rrh.tx_action) = 'END ABANDON'
            order by rr.id_rerun desc
 			