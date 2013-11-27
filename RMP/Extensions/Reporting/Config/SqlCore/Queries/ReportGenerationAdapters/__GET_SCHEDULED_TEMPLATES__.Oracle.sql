
      /* __GET_SCHEDULED_TEMPLATES__ */
		select tx_rpt_template_unique_name as TemplateName from t_report_instance_gen 
			where n_initiator_adapter_runid = %%ID_RUN%%
			and n_initiator_adapter_billgrpid = %%ID_BILLGROUP%%
			