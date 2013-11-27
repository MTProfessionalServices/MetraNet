
		/* __GET_NEWLY_SCHEDULED_TEMPLATES__ */
		select n_initiator_adapter_runid as RunID,tx_rpt_template_unique_name as TemplateName,n_expected_instances as ExpectedInstances
			from t_report_instance_gen where tx_initiator_adapter_name = '%%INITIATOR_NAME%%'
			and tx_status = 'New'
			