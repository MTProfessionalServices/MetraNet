--1
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_amp_accountqualgro" and "t_amp_accountqualifi"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='account_qualification_groups'

--2
 EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "t_amp_decisiontype", "t_amp_decisionattrib" and "agg_param_name_map"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='agg_param_table_col_map'

--3
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_amp_decisionglobal" and "agg_param_name_map"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='agg_param_table_master'

--4
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_amp_decisiontype" and "t_amp_decisionattrib"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='amp_sorted_decisions'

--5
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_amp_chargequalgroup" and "t_amp_chargequalific"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='charge_qualification_groups'

--6
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_usage_interval" and "t_partition"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_partition_interval_map'

--7
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of five tables "t_account_mapper", "t_av_internal", "t_account_state", "t_payment_redirection" and "t_acc_usage_cycle"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='T_VW_ACCTRES'

--8
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of five tables "t_account", "t_payment_redirection", "t_account_state", "t_av_internal" and "t_acc_usage_cycle"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='T_VW_ACCTRES_BYID'

--9
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two views "t_vw_allrateschedules_po" and "t_vw_allrateschedules_pl"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_vw_allrateschedules'

--10
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two views "t_rsched", "t_effectivedate", "t_pi_template" and "t_pi_rulesetdef_map"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_vw_allrateschedules_pl'

--11
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "t_pl_map", "t_rsched" and "t_effectivedate"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_vw_allrateschedules_po'

--12
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "t_pl_map", "t_rsched" and "t_effectivedate"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_vw_allrateschedules_po_icb'

--13
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "t_pl_map", "t_rsched" and "t_effectivedate"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_vw_allrateschedules_po_noicb'

--14
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_base_props" and "t_description"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_vw_base_props'

--15
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_sub" and "t_gsubmember_historical"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='T_VW_EFFECTIVE_SUBS'

--16
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "t_sub", "t_group_sub" and "t_gsubmember"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_vw_expanded_sub'

--17
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "t_vw_effective_subs", "t_pl_map" and "t_base_props"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_vw_pilookup'

--18
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "t_pl_map", "t_recur" and "t_sub"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_vw_rc_arrears_fixed'

--19
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of four tables "t_pl_map", "t_recur", "t_vw_effective_subs" and "t_acc_usage_cycle"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='t_vw_rc_arrears_relative'

--20
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of one table "t_amp_usagechargefie"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='usage_charge_fields'

--21
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_amp_usagequalgroup" and "t_amp_usagequalifica"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='usage_qualification_groups'

--22
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_account" and "t_po_account_type_map"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='vw_acc_po_restrictions'

--23
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of four tables "t_adjustment_transaction", "VW_AJ_INFO" view, "t_base_props" and "t_description"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='VW_ADJUSTMENT_DETAILS'

--24
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_adjustment_transaction" and "t_usage_interval"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='VW_ADJUSTMENT_SUMMARY'

--25
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of four tables "t_acc_usage", "t_adjustment_transaction", "t_acc_usage_interval" and "t_adjustment_type"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='VW_AJ_INFO'

--26
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_billgroup" and "t_acc_usage_interval"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='vw_all_billing_groups_status'

--27
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of two tables "t_account_mapper" and "t_namespace"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='VW_AR_ACC_MAPPER'

--28
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of five tables "t_audit", "t_audit_events", "t_description", "t_account_mapper" and "t_audit_details"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='vw_audit_log'

--29
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of four tables "t_account_mapper", "t_namespace", "t_enum_data" and "t_av_contact"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='VW_HIERARCHYNAME'

--30
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view creates from one view "vw_all_billing_groups_status" which is grouped by id_usage_interval',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='vw_interval_billgroup_counts'

--31
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "t_account_mapper", "t_namespace", "t_enum_data" and "t_av_contact"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='VW_MPS_ACC_MAPPER'

--32
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of four tables "t_account_mapper", "t_namespace", "t_enum_data" and "t_av_contact"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='vw_mps_or_system_acc_mapper'

--33
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "t_account_mapper", "t_namespace", "t_enum_data" and "t_av_contact"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='VW_MPS_OR_SYSTEM_HIERARCHYNAME'

--34
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of fives tables "t_adjustment_transaction", "VW_AJ_INFO", "t_base_props", "t_description" and "t_base_props"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='VW_NOTDELETED_ADJ_DETAILS'

--35
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "t_acc_usage_interval", "t_account_mapper" and "t_namespace"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='vw_paying_accounts'

--36
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view consists of three tables "vw_paying_accounts", "t_billgroup_member" and "t_billgroup"',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='vw_unassigned_accounts'

--37
EXEC sys.sp_addextendedproperty
@name=N'MS_Description', @value='The view gets list of business partition accounts and it consists of four tables "t_account", "t_account_type", "t_account_ancestor" and "t_account_mapper" ',
@level0type=N'SCHEMA',@level0name=N'dbo',
@level1type=N'VIEW',@level1name='vw_bus_partition_accounts'
