
COMMENT ON TABLE t_partition_interval_map IS 'The view consists of two tables "t_usage_interval" and "t_partition"';

COMMENT ON TABLE T_VW_ACCTRES IS 'The view consists of five tables "t_account_mapper", "t_av_internal", "t_account_state", "t_payment_redirection" and "t_acc_usage_cycle"';

COMMENT ON TABLE T_VW_ACCTRES_BYID IS 'The view consists of five tables "t_account", "t_payment_redirection", "t_account_state", "t_av_internal" and "t_acc_usage_cycle"';

COMMENT ON TABLE t_vw_allrateschedules IS 'The view consists of two views "t_vw_allrateschedules_po" and "t_vw_allrateschedules_pl"';

COMMENT ON TABLE t_vw_allrateschedules_pl IS 'The view consists of two views "t_rsched", "t_effectivedate", "t_pi_template" and "t_pi_rulesetdef_map"';

COMMENT ON TABLE t_vw_allrateschedules_po IS 'The view consists of three tables "t_pl_map", "t_rsched" and "t_effectivedate"';

COMMENT ON TABLE t_vw_allrateschedules_po_icb IS 'The view consists of three tables "t_pl_map", "t_rsched" and "t_effectivedate"';

COMMENT ON TABLE t_vw_allrateschedules_po_noicb IS 'The view consists of three tables "t_pl_map", "t_rsched" and "t_effectivedate"';

COMMENT ON TABLE t_vw_base_props IS 'The view consists of two tables "t_base_props" and "t_description"';

COMMENT ON TABLE T_VW_EFFECTIVE_SUBS IS 'The view consists of two tables "t_sub" and "t_gsubmember_historical"';

COMMENT ON TABLE t_vw_expanded_sub IS 'The view consists of three tables "t_sub", "t_group_sub" and "t_gsubmember"';

COMMENT ON TABLE t_vw_pilookup IS 'The view consists of three tables "t_vw_effective_subs", "t_pl_map" and "t_base_props"';

COMMENT ON TABLE t_vw_rc_arrears_fixed IS 'The view consists of three tables "t_pl_map", "t_recur" and "t_sub"';

COMMENT ON TABLE t_vw_rc_arrears_relative IS 'The view consists of four tables "t_pl_map", "t_recur", "t_vw_effective_subs" and "t_acc_usage_cycle"';

COMMENT ON TABLE vw_acc_po_restrictions IS 'The view consists of two tables "t_account" and "t_po_account_type_map"';

COMMENT ON TABLE VW_ADJUSTMENT_DETAILS IS 'The view consists of four tables "t_adjustment_transaction", "VW_AJ_INFO" view, "t_base_props" and "t_description"';

COMMENT ON TABLE VW_ADJUSTMENT_SUMMARY IS 'The view consists of two tables "t_adjustment_transaction" and "t_usage_interval"';

COMMENT ON TABLE VW_AJ_INFO IS 'The view consists of four tables "t_acc_usage", "t_adjustment_transaction", "t_acc_usage_interval" and "t_adjustment_type"';

COMMENT ON TABLE vw_all_billing_groups_status IS 'The view consists of two tables "t_billgroup" and "t_acc_usage_interval"';

COMMENT ON TABLE VW_AR_ACC_MAPPER IS 'The view consists of two tables "t_account_mapper" and "t_namespace"';

COMMENT ON TABLE vw_audit_log IS 'The view consists of five tables "t_audit", "t_audit_events", "t_description", "t_account_mapper" and "t_audit_details"';

COMMENT ON TABLE VW_HIERARCHYNAME IS 'The view consists of four tables "t_account_mapper", "t_namespace", "t_enum_data" and "t_av_contact"';

COMMENT ON TABLE vw_interval_billgroup_counts IS 'The view creates from one view "vw_all_billing_groups_status" which is grouped by id_usage_interval';

COMMENT ON TABLE VW_MPS_ACC_MAPPER IS 'The view consists of three tables "t_account_mapper", "t_namespace", "t_enum_data" and "t_av_contact"';

COMMENT ON TABLE vw_mps_or_system_acc_mapper IS 'The view consists of four tables "t_account_mapper", "t_namespace", "t_enum_data" and "t_av_contact"';

COMMENT ON TABLE VW_MPS_OR_SYSTEM_HIERARCHYNAME IS 'The view consists of three tables "t_account_mapper", "t_namespace", "t_enum_data" and "t_av_contact"';

COMMENT ON TABLE VW_NOTDELETED_ADJ_DETAILS IS 'The view consists of fives tables "t_adjustment_transaction", "VW_AJ_INFO", "t_base_props", "t_description" and "t_base_props"';

COMMENT ON TABLE vw_paying_accounts IS 'The view consists of three tables "t_acc_usage_interval", "t_account_mapper" and "t_namespace"';

COMMENT ON TABLE vw_unassigned_accounts IS 'The view consists of three tables "vw_paying_accounts", "t_billgroup_member" and "t_billgroup"';

COMMENT ON TABLE vw_bus_partition_accounts IS 'The view gets list of business partition accounts and it consists of four tables "t_account", "t_account_type", "t_account_ancestor" and "t_account_mapper" ';
