   
        select ria.id_audit,
               ria.id_instance,
               ria.b_ignore_deps,
               ria.dt_crt,  
               ria.tx_action,
               ria.id_acc,  
               a.nm_login %%%CONCAT%%% '/' %%%CONCAT%%% a.nm_space as tx_username,
               'Adapter' as tx_type,
               ria.tx_detail,
               '' as tx_display_name
        from t_account_mapper a, t_namespace n,t_recevent_inst_audit ria
        where a.id_acc=ria.id_acc and a.nm_space=n.nm_space and lower(n.tx_typ_space) != 'metered' and ria.id_instance = %%ID_INSTANCE%% 			