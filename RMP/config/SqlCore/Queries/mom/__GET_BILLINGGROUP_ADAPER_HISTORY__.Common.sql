          
         select id_audit AuditId, 
				ria.id_instance InstanceId, 
				dt_crt "Time",  
				re.tx_display_name Adapter, 
				re.tx_type "Type", 
				ria.b_ignore_deps "Forced",  
				tx_action "Action", ria.id_acc "UserID",  
				a.nm_login %%%CONCAT%%% '/' %%%CONCAT%%% a.nm_space UserName,
				tx_detail "Details"
        from t_account_mapper a, t_namespace n, t_recevent_inst_audit ria, t_recevent_inst ri, t_recevent re
        where a.id_acc=ria.id_acc and a.nm_space=n.nm_space and lower(n.tx_typ_space) != 'metered'
	      and ria.id_instance = ri.id_instance
	      and ri.id_arg_billgroup = %%ID_BILLGROUP%%
	      and ri.id_event = re.id_event
        order by dt_crt 
 			