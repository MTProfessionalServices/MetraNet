
				/* __MARK_RECORDS_AS_NEW__ */
				if exists (select * from sysobjects where name = 't_report_instance_gen')
				begin
					update t_report_instance_gen set 
					tx_status = 'New',
					tx_completor_adapter_name = null,
					n_completor_adapter_runid = null,
					n_succeeded_instances = null,
					n_failed_instances = null,
					b_reached_threshold = null,
					b_reached_timeout = null
					where 
					n_completor_adapter_runid = %%ID_RUN%%
					AND n_initiator_adapter_billgrpid = %%ID_BILLGROUP%%
				end
			