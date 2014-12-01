          
         select ria.id_audit, 
				ria.id_instance, 
				ria.dt_crt,  
				re.tx_display_name, 
				re.tx_type, 
				ria.b_ignore_deps,  
				ria.tx_action,
        ria.id_acc,  
				a.nm_login %%%CONCAT%%% '/' %%%CONCAT%%% a.nm_space as tx_username,
				ria.tx_detail
        from t_account_mapper a, t_namespace n, t_recevent_inst_audit ria, t_recevent_inst ri, t_recevent re
        where a.id_acc=ria.id_acc and a.nm_space=n.nm_space and lower(n.tx_typ_space) != 'metered'
	      and ria.id_instance = ri.id_instance
	      and ri.id_arg_billgroup = %%ID_BILLGROUP%%
	      and ri.id_event = re.id_event
 			