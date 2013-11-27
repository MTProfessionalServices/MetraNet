
      /* __DELETE_EXPECTED_INSTANCES_RECORDS_FOR_RUN__ */
      if exists (select * from sysobjects where name = 't_report_instance_gen')
      begin
		delete from t_report_instance_gen
		where n_initiator_adapter_runid = %%ID_RUN%%
		and n_initiator_adapter_billgrpid = %%ID_BILLGROUP%%
	  end
		