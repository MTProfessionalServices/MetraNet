  
        select rr.id_rerun as 'Rerun Id',tx_filter as 'Filter',tx_tag as 'Tag',dt_action as 'Time',tx_action as 'Last Action',
        rrh.id_acc as 'UserId', a.nm_login + '/' + a.nm_space as 'UserName',tx_comment as 'Comment' 
        from t_account_mapper a, t_namespace n, t_rerun rr 
        inner join t_rerun_history rrh 
        on rr.id_rerun = rrh.id_rerun 
        where rrh.dt_action = (select max(rrh2.dt_action) from t_rerun_history rrh2 where rrh2.id_rerun = rr.id_rerun) 
        and rr.id_rerun = (select rrh3.id_rerun from t_rerun_history rrh3 where rrh3.id_rerun = rr.id_rerun 
        and tx_action='CREATE' 
        and tx_comment = 'Batch[%%ID_BATCH_ENCODED%%]') 
        and a.id_acc=rrh.id_acc and a.nm_space=n.nm_space and n.tx_typ_space != 'metered' 
        order by rr.id_rerun desc
 			