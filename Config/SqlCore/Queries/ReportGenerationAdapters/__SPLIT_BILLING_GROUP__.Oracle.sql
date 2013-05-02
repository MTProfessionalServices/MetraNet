
      /* __SPLIT_BILLING_GROUP__ */
      begin
      if table_exists 't_report_instance_gen') then
		insert into t_report_instance_gen
		select n_initiator_adapter_runid=%%ID_RUN_CHILD%%,
			  n_initiator_adapter_billgrpid=%%ID_BILLGROUP_CHILD%%,
			  n_report_runid,n_report_billgroupid,tx_initiator_adapter_name,tx_rpt_template_unique_name,
			  n_expected_instances = %%EXPECTED_INSTANCES%%,
			  tx_status varchar,tx_completor_adapter_name,
			  n_completor_adapter_runid,n_succeeded_instances,n_failed_instances,
			  b_reached_threshold,b_reached_timeout
		from t_report_instance_gen rpt
		where rpt.n_initiator_adapter_runid = %%ID_RUN_PARENT%%
		and rpt.n_initiator_adapter_billgrpid = %%ID_BILLGROUP_PARENT%%
		and tx_rpt_template_unique_name = '%%TEMPLATE_NAME%%' 

		/* Update original group
		update t_report_instance_gen
		set n_expected_instances = (n_expected_instances - %%EXPECTED_INSTANCES%%)
		where n_initiator_adapter_runid = %%ID_RUN_PARENT%%
		and n_initiator_adapter_billgrpid = %%ID_BILLGROUP_PARENT%%
		and tx_rpt_template_unique_name = '%%TEMPLATE_NAME%%';
		end if;
	  end;
		