
				/* __GET_NEWLY_SCHEDULED_TEMPLATES_BY_BILLGROUP__ */
				if exists (select * from sysobjects where name = 't_report_instance_gen')
				begin
					select n_initiator_adapter_runid as RunID,tx_rpt_template_unique_name as TemplateName,n_expected_instances as ExpectedInstances
					from t_report_instance_gen where tx_initiator_adapter_name = '%%INITIATOR_NAME%%'
					and n_initiator_adapter_billgrpid = %%ID_BILLGROUP%%
					and tx_status = 'New'
				end
			