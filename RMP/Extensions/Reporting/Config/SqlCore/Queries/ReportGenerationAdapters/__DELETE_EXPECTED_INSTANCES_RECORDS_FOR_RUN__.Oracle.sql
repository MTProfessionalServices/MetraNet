
      /* __DELETE_EXPECTED_INSTANCES_RECORDS_FOR_RUN__ */
      begin
      if table_exists('t_report_instance_gen') then
		delete from t_report_instance_gen
				  where n_initiator_adapter_runid = %%ID_RUN%%
				  and n_initiator_adapter_billgrpid = %%ID_BILLGROUP%%;
		end if;
	  end;
		