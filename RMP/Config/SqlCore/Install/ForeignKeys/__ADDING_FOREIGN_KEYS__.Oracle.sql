					alter table t_acc_usage add constraint fk2_t_acc_usage foreign key(id_payee)
					references t_account(id_acc);
					alter table t_acc_usage add constraint fk3_t_acc_usage foreign key(id_prod)
					references t_po(id_po);

					alter table t_acc_usage_cycle add constraint fk1_t_acc_usage_cycle foreign key(id_acc)
					references t_account(id_acc);

					alter table T_ACC_USAGE_CYCLE add  constraint FK2_T_ACC_USAGE_CYCLE
					foreign key (ID_USAGE_CYCLE) references T_USAGE_CYCLE (ID_USAGE_CYCLE);

					alter table t_acc_usage_interval add constraint fk1_t_acc_usage_interval foreign key(id_acc)
					references t_account(id_acc);

					alter table t_acc_usage_interval add constraint fk2_t_acc_usage_interval
					foreign key(id_usage_interval) references t_usage_interval(id_interval);

/*					alter table t_account_ancestor add constraint fk1_t_account_ancestor */
/*					foreign key(id_ancestor) references t_account(id_acc); */

/*					alter table t_account_ancestor add constraint fk2_t_account_ancestor */
/*					foreign key(id_descendent) references t_account(id_acc); */

					alter table T_ACCOUNT_MAPPER add constraint FK1_T_ACCOUNT_MAPPER
					foreign key (NM_SPACE)  references T_NAMESPACE (NM_SPACE);

					alter table T_ACCOUNT_STATE add  constraint FK1_T_ACCOUNT_STATE
					foreign key (ID_ACC)  references T_ACCOUNT (ID_ACC);

					alter table T_ACCOUNT_STATE_HISTORY add  constraint FK1_T_ACCOUNT_STATEHIS
					foreign key (ID_ACC) references T_ACCOUNT (ID_ACC);

					alter table T_ACC_TEMPLATE add  constraint FK1_T_ACC_TEMPLATE
					foreign key (ID_FOLDER) references T_ACCOUNT (ID_ACC);

					alter table T_ACC_TEMPLATE_PROPS add  constraint FK1_T_ACC_TEMPLATE_PROPS
					foreign key (ID_ACC_TEMPLATE) references T_ACC_TEMPLATE (ID_ACC_TEMPLATE);

					alter table T_ACC_TEMPLATE_SUBS add  constraint FK2_T_ACC_TEMPLATE_SUBS
					foreign key (ID_ACC_TEMPLATE) references T_ACC_TEMPLATE (ID_ACC_TEMPLATE);

					alter table T_ACC_TEMPLATE_SUBS_PUB add  constraint FK2_T_ACC_TEMPLATE_SUBS_PUB
					foreign key (ID_ACC_TEMPLATE) references T_ACC_TEMPLATE (ID_ACC_TEMPLATE);

					alter table t_aggregate add constraint fk1_t_aggregate
					foreign key(id_usage_cycle) references t_usage_cycle(id_usage_cycle);

					alter table t_aggregate add constraint fk2_t_aggregate
					foreign key(id_cycle_type) references t_usage_cycle_type(id_cycle_type);

					alter table t_aggregate add constraint fk3_t_aggregate
					foreign key(id_prop) references t_base_props(id_prop);

					alter table T_AUDIT add constraint FK1_T_AUDIT
					foreign key (ID_EVENT) references T_AUDIT_EVENTS (ID_EVENT);

					alter table T_AUDIT_DETAILS add  constraint FK1_T_AUDIT_DETAILS
					foreign key (ID_AUDIT) references T_AUDIT (ID_AUDIT) on delete cascade;

					alter table T_CALENDAR add constraint FK1_T_CALENDAR
					foreign key (ID_CALENDAR) references T_BASE_PROPS (ID_PROP);

					alter table T_CALENDAR_DAY add  constraint FK1_T_CALENDAR_DAY
					foreign key (ID_CALENDAR) references T_CALENDAR (ID_CALENDAR);

					alter table T_CALENDAR_HOLIDAY add  constraint FK1_T_CALENDAR_HOLIDAY
					foreign key (ID_DAY) references T_CALENDAR_DAY (ID_DAY);

					alter table T_CALENDAR_PERIODS add  constraint FK1_T_CALENADAR_PERIODS
					foreign key (ID_DAY) references T_CALENDAR_DAY (ID_DAY);

					alter table T_CAPABILITY_INSTANCE add  constraint FK1_T_CAPABILITY_INSTANCE
					foreign key (ID_POLICY) references T_PRINCIPAL_POLICY (ID_POLICY);

					alter table T_COMPOSITOR add  constraint FK1_T_COMPOSITOR
					foreign key (ID_ATOMIC)  references T_ATOMIC_CAPABILITY_TYPE (ID_CAP_TYPE);

					alter table T_COMPOSITOR add constraint FK2_T_COMPOSITOR
					foreign key (ID_COMPOSITE) references T_COMPOSITE_CAPABILITY_TYPE (ID_CAP_TYPE);

					alter table t_counter_map	add constraint fk1_t_counter_map
					foreign key (id_counter) references t_counter (id_prop);


					alter table t_counter_map	add constraint fk2_t_counter_map
					foreign key (id_pi)	references t_base_props (id_prop);

					alter table t_counter_metadata add constraint fk1_t_counter_metadata
					foreign key (id_prop) references t_base_props (id_prop);

					alter table t_counter	add constraint FK1_t_counter
					foreign key (id_prop)	references t_base_props (id_prop);

					alter table t_counter	add constraint FK2_t_counter
					foreign key (id_counter_type)	references t_counter_metadata (id_prop);

					alter table t_counter_params_metadata add constraint fk1_t_counter_params_metadata
					foreign key (id_counter_meta)	references t_counter_metadata (id_prop);

					alter table t_counter_params_metadata	add constraint fk2_t_counter_params_metadata
					foreign key (id_prop)	references t_base_props (id_prop);

					alter table t_counter_params	add constraint fk1_t_counter_params
					foreign key (id_counter) references t_counter (id_prop);

					alter table t_counter_params add constraint fk2_t_counter_params
					foreign key (id_counter_param_meta)	references t_counter_params_metadata (id_prop);

					alter table t_counter_param_predicate add constraint fk_t_counter_params
					foreign key(id_counter_param) references t_counter_params(id_counter_param);

					alter table t_counter_param_predicate add constraint fk_t_prod_view_prop
					foreign key(id_pv_prop) references t_prod_view_prop(id_prod_view_prop);

					alter table t_counter_param_map add constraint fk_param_map_counter_params
					foreign key(id_counter_param) references t_counter_params(id_counter_param);

					alter table t_counter_param_map add constraint fk_param_map_counter
					foreign key(id_counter) references t_counter(id_prop);

					alter table t_counter_param_map add constraint fk_pmap_ctr_params_metadata
					foreign key(id_counter_param_meta) references t_counter_params_metadata(id_prop);

					alter table T_COUNTERPROPDEF add  constraint FK1_T_COUNTERPROPDEF
					foreign key (ID_PROP) references T_BASE_PROPS (ID_PROP);

					alter table T_DECIMAL_CAPABILITY add  constraint FK1_T_DECIMAL_CAPABILITY
					foreign key (ID_CAP_INSTANCE) references T_CAPABILITY_INSTANCE (ID_CAP_INSTANCE);

					alter table T_DESCRIPTION add  constraint FK1_T_DESCRIPTION
					foreign key (ID_DESC) references T_MT_ID (ID_MT);

					alter table t_description add constraint fk2_t_description
					foreign key(id_lang_code) references t_language(id_lang_code);

					alter table T_DISCOUNT add  constraint FK1_T_DISCOUNT
					foreign key (ID_PROP) references T_BASE_PROPS (ID_PROP);

					alter table t_discount add constraint fk2_t_discount
					foreign key(id_usage_cycle) references t_usage_cycle(id_usage_cycle);

					alter table t_discount add constraint fk3_t_discount
					foreign key(id_cycle_type) references t_usage_cycle_type(id_cycle_type);

					alter table T_ENUM_CAPABILITY add  constraint FK1_T_ENUM_CAPABILITY
					foreign key (ID_CAP_INSTANCE) references T_CAPABILITY_INSTANCE (ID_CAP_INSTANCE);

					alter table T_ENUM_DATA add  constraint FK1_T_ENUM_DATA
					foreign key (ID_ENUM_DATA) references T_MT_ID (ID_MT);

					alter table T_GROUP_SUB add  constraint FK1_T_GROUP_SUB
					foreign key (ID_USAGE_CYCLE) references T_USAGE_CYCLE (ID_USAGE_CYCLE);

					alter table T_GROUP_SUB add  constraint FK2_T_GROUP_SUB
					foreign key (ID_DISCOUNTACCOUNT) references T_ACCOUNT (ID_ACC);

					alter table T_GROUP_SUB add  constraint FK3_T_GROUP_SUB
					foreign key (ID_CORPORATE_ACCOUNT) references T_ACCOUNT (ID_ACC);

					alter table T_GSUBMEMBER add  constraint FK1_T_GSUBMEMBER
					foreign key (ID_GROUP) references T_GROUP_SUB (ID_GROUP);

					alter table T_GSUBMEMBER add  constraint FK2_T_GSUBMEMBER
					foreign key (ID_ACC) references T_ACCOUNT (ID_ACC);

					alter table T_GSUBMEMBER_HISTORICAL add  constraint FK1_T_GSUBMEMBERHIS
					foreign key (ID_GROUP) references T_GROUP_SUB (ID_GROUP);

					alter table T_GSUBMEMBER_HISTORICAL add  constraint FK2_T_GSUBMEMBERHIS
					foreign key (ID_ACC) references T_ACCOUNT (ID_ACC);

					alter table T_IMPERSONATE add  constraint FK1_T_IMPERSONATE
					foreign key (ID_ACC) references T_ACCOUNT (ID_ACC);

					alter table T_IMPERSONATE add  constraint FK2_T_IMPERSONATE
					foreign key (ID_OWNER) references T_ACCOUNT (ID_ACC);

					alter table T_BILL_MANAGER add  constraint FK1_T_BILL_MANAGER
					foreign key (ID_ACC) references T_ACCOUNT (ID_ACC);

					alter table T_BILL_MANAGER add  constraint FK2_T_BILL_MANAGER
					foreign key (ID_MANAGER) references T_ACCOUNT (ID_ACC);

					alter table T_NONRECUR add  constraint FK1_T_NONRECUR
					foreign key (ID_PROP) references T_BASE_PROPS (ID_PROP);

					alter table T_PATH_CAPABILITY add  constraint FK1_T_PATH_CAPABILITY
					foreign key (ID_CAP_INSTANCE) references T_CAPABILITY_INSTANCE (ID_CAP_INSTANCE);

					alter table T_PAYMENT_REDIRECTION add  constraint FK1_T_PAYMENT_REDIRECTION
					foreign key (ID_PAYER) references T_ACCOUNT (ID_ACC);

					alter table T_PAYMENT_REDIRECTION add  constraint FK2_T_PAYMENT_REDIRECTION
					foreign key (ID_PAYEE) references T_ACCOUNT (ID_ACC);

					alter table T_PAYMENT_REDIR_HISTORY add  constraint FK1_T_PAYMENT_REDIRECTION_HIS
					foreign key (ID_PAYER)  references T_ACCOUNT (ID_ACC);

					alter table T_PAYMENT_REDIR_HISTORY add  constraint FK2_T_PAYMENT_REDIRECTION_HIS
					foreign key (ID_PAYEE) references T_ACCOUNT (ID_ACC);

					alter table T_PC_INTERVAL add  constraint FK_T_PC_INTERVAL
					foreign key (ID_CYCLE) references T_USAGE_CYCLE (ID_USAGE_CYCLE);

					alter table T_PI add  constraint FK1_T_PI
					foreign key (ID_PI) references T_BASE_PROPS (ID_PROP);

					alter table t_pi add constraint fk2_t_pi
					foreign key(id_parent) references t_pi(id_pi);

					alter table T_PI_RULESETDEF_MAP add  constraint FK1_T_PI_RULESETDEF_MAP
					foreign key (ID_PI) references T_PI (ID_PI);

					alter table T_PI_RULESETDEF_MAP add  constraint FK1_T_RULESETDEF_MAP
					foreign key (ID_PT) references T_RULESETDEFINITION (ID_PARAMTABLE);

				 	alter table T_PIPELINE_SERVICE add  constraint FK1_T_PIPELINE_SERVICE foreign key (ID_PIPELINE)
				  	references T_PIPELINE (ID_PIPELINE);

					alter table T_PIPELINE_SERVICE add  constraint FK2_T_PIPELINE_SERVICE foreign key (ID_SVC)
					references T_ENUM_DATA (ID_ENUM_DATA);

					alter table T_PL_MAP add constraint FK1_T_PL_MAP
					foreign key (ID_ACC) references T_ACCOUNT (ID_ACC);

					alter table T_PL_MAP add  constraint FK2_T_PL_MAP
					foreign key (ID_PI_TEMPLATE) references T_BASE_PROPS (ID_PROP);

					alter table T_PL_MAP add  constraint FK3_T_PL_MAP
					foreign key (ID_PI_INSTANCE) references T_BASE_PROPS (ID_PROP);

					alter table T_PL_MAP add  constraint FK4_T_PL_MAP
					foreign key (ID_PI_TYPE) references T_PI (ID_PI);

					alter table T_PL_MAP add  constraint FK5_T_PL_MAP
					foreign key (ID_PO) references T_PO (ID_PO);

					alter table T_PL_MAP add  constraint FK6_T_PL_MAP
					foreign key (ID_PRICELIST) references T_PRICELIST (ID_PRICELIST);

					alter table T_PL_MAP add  constraint FK7_T_PL_MAP
					foreign key (ID_PARAMTABLE) references T_RULESETDEFINITION (ID_PARAMTABLE);

					alter table t_pl_map add constraint fk8_t_pl_map
					foreign key(id_pi_instance_parent) references t_base_props(id_prop);

					alter table T_PO add  constraint FK1_T_PO
					foreign key (ID_PO) references T_BASE_PROPS (ID_PROP);

					alter table T_PO add  constraint FK2_T_PO
					foreign key (ID_EFF_DATE) references T_EFFECTIVEDATE (ID_EFF_DATE);

					alter table T_PO add  constraint FK3_T_PO
					foreign key (ID_AVAIL) references T_EFFECTIVEDATE (ID_EFF_DATE);

					alter table T_POLICY_ROLE add  constraint FK1_T_POLICY_ROLE
					foreign key (ID_POLICY) references T_PRINCIPAL_POLICY (ID_POLICY);

					alter table T_POLICY_ROLE add  constraint FK2_T_POLICY_ROLE
					foreign key (ID_ROLE) references T_ROLE (ID_ROLE);

					alter table T_PRICELIST add  constraint FK1_T_PRICELIST
					foreign key (ID_PRICELIST) references T_BASE_PROPS (ID_PROP);

					alter table T_PRINCIPAL_POLICY add  constraint FK1_T_PRINCIPAL_POLICY
					foreign key (ID_ACC) references T_ACCOUNT (ID_ACC);

					alter table T_PRINCIPAL_POLICY add  constraint FK2_T_PRINCIPAL_POLICY
					foreign key (ID_ROLE) references T_ROLE (ID_ROLE);

					alter table T_RECUR add  constraint FK1_T_RECUR
					foreign key (ID_PROP) references T_BASE_PROPS (ID_PROP);

					alter table T_RECUR add  constraint FK2_T_RECUR
					foreign key (ID_USAGE_CYCLE) references T_USAGE_CYCLE (ID_USAGE_CYCLE);

					alter table t_recur add constraint fk3_t_recur
					foreign key(id_cycle_type) references t_usage_cycle_type(id_cycle_type);

					alter table T_RSCHED add  constraint FK1_T_RSCHED
					foreign key (ID_SCHED) references T_BASE_PROPS (ID_PROP);

					alter table T_RSCHED add  constraint FK2_T_RSCHED
					foreign key (ID_EFF_DATE) references T_EFFECTIVEDATE (ID_EFF_DATE);

					/*alter table T_RSCHED add  constraint FK3_T_RSCHED
					foreign key (ID_PI_TEMPLATE) references T_PI_TEMPLATE (ID_TEMPLATE); 		*/

					alter table T_RSCHED add  constraint FK4_T_RSCHED
					foreign key (ID_PRICELIST) references T_PRICELIST (ID_PRICELIST);

					alter table T_RSCHED add  constraint FK5_T_RSCHED
					foreign key (ID_PT) references T_RULESETDEFINITION (ID_PARAMTABLE);

					alter table T_RULESETDEFINITION add  constraint FK1_T_RULESETDEFINITION
					foreign key (ID_PARAMTABLE) references T_BASE_PROPS (ID_PROP);

					alter table T_SITE_USER add  constraint FK1_T_SITE_USER
					foreign key (ID_SITE) references T_LOCALIZED_SITE (ID_SITE);

					alter table T_SUB add constraint FK1_T_SUB
					foreign key (ID_ACC) references T_ACCOUNT (ID_ACC);

					alter table T_SUB add  constraint FK2_T_SUB
					foreign key (ID_GROUP) references T_GROUP_SUB (ID_GROUP);

					alter table t_sub add constraint fk3_t_sub
					foreign key(id_po) references t_po(id_po);

					alter table T_SUB_HISTORY add  constraint FK1_T_SUB_HISTORY
					foreign key (ID_ACC) references T_ACCOUNT (ID_ACC);

					alter table T_SUB_HISTORY add  constraint FK2_T_SUB_HISTORY
					foreign key (ID_GROUP) references T_GROUP_SUB (ID_GROUP);

					alter table t_sub_history add constraint fk3_t_sub_history
					foreign key(id_po) references t_po(id_po);
					alter table T_USAGE_CYCLE add constraint FK1_T_USAGE_CYCLE
					foreign key (ID_CYCLE_TYPE) references T_USAGE_CYCLE_TYPE (ID_CYCLE_TYPE);

					alter table T_USAGE_INTERVAL add  constraint FK1_T_USAGE_INTERVAL
					foreign key (ID_USAGE_CYCLE) references T_USAGE_CYCLE (ID_USAGE_CYCLE);

					alter table t_user_credentials add constraint fk1_t_user_credentials
					foreign key(nm_login,nm_space) references t_account_mapper(nm_login,nm_space);
					alter table T_VIEW_HIERARCHY add constraint FK1_T_VIEW_HIERARCHY
					foreign key(ID_VIEW) references T_ENUM_DATA(ID_ENUM_DATA);

					alter table T_VIEW_HIERARCHY add constraint FK2_T_VIEW_HIERARCHY
					foreign key(ID_VIEW_PARENT) references T_ENUM_DATA(ID_ENUM_DATA);

					alter table t_charge add constraint t_charge_FK1
					foreign key (id_pi) references t_pi (id_pi);

					alter table t_charge add constraint t_charge_FK2
					foreign key (id_amt_prop) references t_prod_view_prop (id_prod_view_prop);

					alter table t_charge_prop add constraint t_charge_prop_FK1
					foreign key (id_charge) references t_charge (id_charge);

					alter table t_charge_prop add constraint t_charge_prop_FK2
					foreign key (id_prod_view_prop) references t_prod_view_prop (id_prod_view_prop);

					alter table t_prod_view add constraint t_prod_view_FK1
					foreign key (id_view) references t_enum_data (id_enum_data);

					alter table t_prod_view_prop add constraint t_prod_view_prop_FK1
					foreign key (id_prod_view) references t_prod_view (id_prod_view);

					alter table t_adjustment_type add constraint adjustment_type_fk1
					foreign key (id_prop) references t_base_props(id_prop);


					alter table t_adjustment_type add constraint adjustment_type_fk2
					foreign key (id_pi_type) references t_pi(id_pi);

					alter table t_adjustment_transaction add constraint t_adjustment_trx_fk3
					foreign key (id_aj_template) references t_adjustment(id_prop);
					alter table t_adjustment_transaction add constraint t_adjustment_trx_fk4
					foreign key (id_aj_instance) references t_adjustment(id_prop);

					alter table t_adjustment add constraint t_adjustment_fk1
					foreign key (id_pi_instance) references t_base_props(id_prop);
					
					alter table t_adjustment add constraint t_adjustment_fk2
					foreign key (id_pi_template) references t_pi_template(id_template);
					
					alter table t_adjustment add constraint t_adjustment_fk3
					foreign key (id_adjustment_type) references t_adjustment_type(id_prop);
					
					alter table t_adjustment_type_prop add constraint adjustment_type_prop_fk1
					foreign key (id_adjustment_type) references t_adjustment_type(id_prop);
					
					alter table t_adjustment_type_prop add constraint adjustment_type_prop_fk2
					foreign key (id_prop) references t_base_props(id_prop);
					
					alter table t_recur_value add constraint t_recur_value_fk1
					foreign key (id_prop) references t_recur(id_prop);
					
					alter table t_gsub_recur_map add constraint t_gsub_recur_map_fk1
					foreign key (id_group) references t_group_sub(id_group);
					
					alter table t_gsub_recur_map add constraint t_gsub_recur_map_fk2
					foreign key (id_prop) references t_recur(id_prop);
					
					alter table t_gsub_recur_map add constraint t_gsub_recur_map_fk3
					foreign key (id_acc) references t_account(id_acc);
					
					alter table t_acc_ownership add constraint t_acc_ownership_fk1
					foreign key (id_owner) references t_account(id_acc);
					
					alter table t_acc_ownership add constraint t_acc_ownership_fk2
					foreign key (id_owned) references t_account(id_acc);
					
					
					alter table t_acc_ownership add constraint t_acc_ownership_fk3
					foreign key (id_relation_type) references t_enum_data(id_enum_data);
					
					alter table t_unique_cons add constraint fk1_t_unique_cons
					foreign key (id_prod_view) references t_prod_view (id_prod_view);
					
					alter table t_unique_cons_columns add constraint fk1_t_unique_cons_col
					foreign key (id_unique_cons) references t_unique_cons (id_unique_cons);
					
					alter table t_unique_cons_columns add constraint fk2_t_unique_cons_col
					foreign key (id_prod_view_prop) references t_prod_view_prop (id_prod_view_prop);
					
					alter table t_acctype_descendenttype_map add constraint fk1_t_acctype_destype_map
					foreign key (id_type) references t_account_type (id_type);
					
					alter table t_acctype_descendenttype_map add constraint fk2_t_acctype_destype_map
					foreign key (id_descendent_type) references t_account_type (id_type);
					
					alter table t_account add constraint fk1_t_account
					foreign key (id_type) references t_account_type(id_type);
										
					/* foreign keys for T_LOCALIZED_ITEMS table */
					alter table t_localized_items add constraint FK_LOCAL_TO_LOCAL_ITEMS_TYPE
					foreign key(id_local_type) references t_localized_items_type(id_local_type);
					
					alter table t_localized_items add constraint FK_LOCALIZE_TO_T_LANGUAGE
					foreign key(id_lang_code) references t_language (id_lang_code);
