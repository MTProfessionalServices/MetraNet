   
        select id_audit AuditId, id_instance InstanceId, ria.b_ignore_deps Forced, dt_crt "Time",  
				tx_action Action, ria.id_acc UserId,  
				a.nm_login %%%CONCAT%%% '/' %%%CONCAT%%% a.nm_space "UserName", tx_detail as Details, 
				'Adapter' "Type"
        from t_account_mapper a, t_namespace n,t_recevent_inst_audit ria
        where a.id_acc=ria.id_acc and a.nm_space=n.nm_space and lower(n.tx_typ_space) != 'metered' and id_instance = %%ID_INSTANCE%%
        order by dt_crt   
 			