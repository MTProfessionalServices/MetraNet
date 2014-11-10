
	
				create index parent_idx_t_acc_usage  on t_acc_usage(id_parent_sess)

				create index FK2_T_ACC_USAGE_CYCLE ON T_ACC_USAGE_CYCLE(ID_USAGE_CYCLE)

 				create index fk2idx_t_acc_usage_interval  on t_acc_usage_interval(id_usage_interval,tx_status)  

				create clustered index fk1idx_T_ACCOUNT_STATE_HISTORY  on T_ACCOUNT_STATE_HISTORY (ID_ACC) 

				create index fk1idx_T_ACC_TEMPLATE_PROPS  on T_ACC_TEMPLATE_PROPS (ID_ACC_TEMPLATE)   

				create index fk2idx_T_ACC_TEMPLATE_SUBS  on T_ACC_TEMPLATE_SUBS (ID_ACC_TEMPLATE)  

				create index fk1idx_t_aggregate  on t_aggregate (id_usage_cycle)  

				create index fk2idx_t_aggregate  on t_aggregate (id_cycle_type)  

				create index fk1idx_T_AUDIT  on T_AUDIT (ID_EVENT) 

				create index fk2idx_T_AUDIT  on T_AUDIT (id_entity) 

				create index fk1idx_T_AUDIT_DETAILS  on T_AUDIT_DETAILS (ID_AUDIT)  

				create index fk1idx_T_CALENDAR_DAY  on T_CALENDAR_DAY (ID_CALENDAR) 

				create index fk1idx_T_CALENDAR_HOLIDAY  on T_CALENDAR_HOLIDAY (ID_DAY)  

				create index fk1idx_T_CALENDAR_PERIODS  on T_CALENDAR_PERIODS (ID_DAY)  

				create index fk1idx_T_CAPABILITY_INSTANCE  on T_CAPABILITY_INSTANCE (ID_POLICY) 

				create index fk2idx_T_COMPOSITOR  on T_COMPOSITOR (ID_COMPOSITE)  
	
				create index fk2idx_t_counter_map	on t_counter_map (id_pi)	  

				create index fk2idx_t_counter	on t_counter (id_counter_type)	

				create index fk1idx_t_counter_params_metadata on t_counter_params_metadata (id_counter_meta)	
	 				
				create index fk1idx_t_counter_params on t_counter_params (id_counter_param_meta) 
				
				create index fk2idx_t_description  on t_description (id_lang_code)  

				create index fk2idx_t_discount  on t_discount (id_usage_cycle)  

				create index fk3idx_t_discount  on t_discount (id_cycle_type)  

				create index fk1idx_T_GROUP_SUB  on T_GROUP_SUB (ID_USAGE_CYCLE)   

				create index fk2idx_T_GROUP_SUB  on T_GROUP_SUB (ID_DISCOUNTACCOUNT) 

				create index fk3idx_T_GROUP_SUB  on T_GROUP_SUB (ID_CORPORATE_ACCOUNT)   

				create clustered index fk1idx_T_GSUBMEMBER  on T_GSUBMEMBER (ID_ACC)  

				create index fk2idx_T_GSUBMEMBER  on T_GSUBMEMBER (ID_GROUP)   

				create clustered index fk1idx_T_GSUBMEMBER_HISTORICAL  on T_GSUBMEMBER_HISTORICAL (ID_ACC)  

				create index fk2idx_T_GSUBMEMBER_HISTORICAL  on T_GSUBMEMBER_HISTORICAL (ID_GROUP) 

				create index fk3idx_T_GSUBMEMBER_HISTORICAL  on T_GSUBMEMBER_HISTORICAL (ID_GROUP,ID_ACC, TT_END)

				create clustered index fk1idx_T_IMPERSONATE  on T_IMPERSONATE (ID_ACC)  

				create index fk2idx_T_IMPERSONATE  on T_IMPERSONATE (ID_OWNER) 
        
        create clustered index fk1idx_T_BILL_MANAGER  on T_BILL_MANAGER (ID_ACC)  

				create index fk2idx_T_BILL_MANAGER  on T_BILL_MANAGER (ID_MANAGER) 

				create index fk2idx_T_PAYMENT_REDIRECTION  on T_PAYMENT_REDIRECTION (ID_PAYER) 

				create clustered index fk1idx_T_PAYMENT_REDIR_HISTORY  on T_PAYMENT_REDIR_HISTORY (ID_PAYEE) 

				create index fk2idx_T_PAYMENT_REDIR_HISTORY  on T_PAYMENT_REDIR_HISTORY (ID_PAYER) 

				create index fk1idx_T_PC_INTERVAL  on T_PC_INTERVAL (ID_CYCLE) 

				create index fk2idx_t_pi  on t_pi (id_parent) 

				create index fk2idx_T_PI_RULESETDEF_MAP  on T_PI_RULESETDEF_MAP (ID_PT)  

				create clustered index fk1idx_T_PL_MAP  on T_PL_MAP (ID_PO)  

				create index fk2idx_T_PL_MAP  on T_PL_MAP (ID_ACC) 

				create index fk3idx_T_PL_MAP  on T_PL_MAP (ID_PI_TEMPLATE) 

				create index fk4idx_T_PL_MAP  on T_PL_MAP (ID_PI_INSTANCE) 

				create index fk5idx_T_PL_MAP   on T_PL_MAP (ID_PI_TYPE)  

				create index fk6idx_T_PL_MAP  on T_PL_MAP (ID_PRICELIST)  

				create index fk7idx_T_PL_MAP  on T_PL_MAP (ID_PARAMTABLE) 

				create index fk8idx_t_pl_map  on t_pl_map (id_pi_instance_parent)  

				create index id_subidx_t_pl_map  on t_pl_map (id_sub)  

				create index fk2idx_T_PO  on T_PO (ID_EFF_DATE)  

				create index fk3idx_T_PO  on T_PO (ID_AVAIL) 

				create index fk2idx_T_POLICY_ROLE  on T_POLICY_ROLE (ID_ROLE) 

				create index fk1idx_T_PRINCIPAL_POLICY  on T_PRINCIPAL_POLICY (ID_ACC)  

				create index fk2idx_T_PRINCIPAL_POLICY  on T_PRINCIPAL_POLICY (ID_ROLE) 

				create index fk2idx_T_RECUR  on T_RECUR (ID_USAGE_CYCLE) 

				create index fk3idx_t_recur  on t_recur (id_cycle_type)  

				create index fk2idx_T_RSCHED  on T_RSCHED (ID_EFF_DATE)

				create index fk3idx_T_RSCHED  on T_RSCHED (ID_PI_TEMPLATE)  

				create index fk4idx_T_RSCHED  on T_RSCHED (ID_PRICELIST)  

				create index fk5idx_T_RSCHED  on T_RSCHED (ID_PT)  

				create index fk1idx_T_SITE_USER  on T_SITE_USER (ID_SITE) 

				create index fk1idx_T_SUB  on T_SUB (ID_ACC)  

				create index fk2idx_T_SUB  on T_SUB (ID_GROUP) 

				create index fk3idx_t_sub  on t_sub (id_po)  

				create index fk1idx_T_SUB_HISTORY  on T_SUB_HISTORY (ID_ACC) 

				create index fk2idx_T_SUB_HISTORY  on T_SUB_HISTORY (ID_GROUP) 

				create index fk3idx_t_sub_history  on t_sub_history	(id_po)  

				create index fk1idx_T_USAGE_CYCLE  on T_USAGE_CYCLE (ID_CYCLE_TYPE) 

				create index fk1idx_T_USAGE_INTERVAL  on T_USAGE_INTERVAL (ID_USAGE_CYCLE) 

				create index fk2idx_T_VIEW_HIERARCHY  on T_VIEW_HIERARCHY (ID_VIEW_PARENT) 

				create index idx_nm_tag_profile on t_profile(nm_tag)
        
        create index t_charge_FK1IDX on t_charge (id_pi)

        create index t_charge_FK2IDX on t_charge (id_amt_prop)

        create index t_charge_prop_FK1IDX on t_charge_prop (id_charge)

        create index t_charge_prop_FK2IDX on t_charge_prop (id_prod_view_prop)

    		create index t_recur_value_FK2IDX on t_recur_value (id_sub)

    		create index t_gsub_recur_map_FK2IDX on t_gsub_recur_map (id_prop)

    		create index t_gsub_recur_map_FK3IDX on t_gsub_recur_map (id_acc)

				create index t_adjustment_fk1idx on t_adjustment(id_pi_instance)

				create index t_adjustment_fk2idx on t_adjustment(id_pi_template)

				create index t_adjustment_fk3idx on t_adjustment(id_adjustment_type)

				create index t_adjustment_transaction_fk1idx on t_adjustment_transaction(id_aj_template)

				create index t_adjustment_transaction_fk2idx on t_adjustment_transaction(id_aj_instance)

				create index t_adjustment_transaction_fk3idx on t_adjustment_transaction(id_sess)

				create index t_adjustment_type_fk1idx on t_adjustment_type(id_pi_type)

				create index t_adjustment_type_prop_fk1idx on t_adjustment_type_prop(id_adjustment_type)

				create index t_counter_param_map_fk1idx on t_counter_param_map(id_counter)

				create index t_counter_param_map_fk2idx on t_counter_param_map(id_counter_param_meta)

				create index t_counter_param_predicate_fk1idx on t_counter_param_predicate(id_counter_param)

				create index t_counter_param_predicate_fk2idx on t_counter_param_predicate(id_pv_prop)

				create index t_failed_transaction_msix_fk1idx on t_failed_transaction_msix(id_failed_transaction)

				create index t_po_fk4idx on t_po(id_nonshared_pl)

				create index t_recevent_dep_fk1idx on t_recevent_dep(id_event)

				create index t_recevent_inst_fk1idx on t_recevent_inst(id_event)

				create index t_recevent_inst_audit_fk1idx on t_recevent_inst_audit(id_instance)

				create index t_recevent_run_fk1idx on t_recevent_run(id_instance)

				create index t_recevent_run_batch_fk1idx on t_recevent_run_batch(tx_batch_encoded)

				create index t_recevent_run_batch_fk2idx on t_recevent_run_batch(id_run)

				create index t_recevent_run_details_fk1idx on t_recevent_run_details(id_run)

				create index t_rerun_history_fk1idx on t_rerun_history(id_rerun)

				create clustered index t_invoice_range_idx on t_invoice_range(id_interval)
				
				-- additional indexes
				CREATE  INDEX [idx1_T_CAPABILITY_INSTANCE] ON [dbo].[t_capability_instance]([id_cap_instance])
				CREATE  INDEX [idx2_T_CAPABILITY_INSTANCE] ON [dbo].[t_capability_instance]([id_parent_cap_instance])	
		        create index t_session_set_fk1idx on t_session_set(id_message)
		        CREATE  INDEX idx_t_account_id_acc_ext ON t_account(id_acc_ext)
		        create index idx_t_message on t_message(dt_assigned,id_message)
		        
		      -- fk indexes for partioning metadata
		      create index t_unique_cons_fk1idx on t_unique_cons(id_prod_view)
		      
		      create index t_unique_cons_columns_fk1idx on t_unique_cons_columns(id_prod_view_prop)
		      
		      create index idx1_t_session on t_session(id_source_sess)
		      
		      
				