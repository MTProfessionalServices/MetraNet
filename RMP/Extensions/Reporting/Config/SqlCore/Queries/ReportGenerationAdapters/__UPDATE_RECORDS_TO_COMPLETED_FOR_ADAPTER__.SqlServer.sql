
      /* __UPDATE_RECORDS_TO_COMPLETED_FOR_ADAPTER__ */
      if exists (select * from sysobjects where name = 't_report_instance_gen')
			begin
				update t_report_instance_gen set 
				tx_status = 'Completed',
				tx_completor_adapter_name = '%%COMPLETOR_NAME%%',
				n_completor_adapter_runid = '%%COMPLETOR_ID_RUN%%',
				n_succeeded_instances = %%NUM_SUCCEEDED_INSTANCES%%,
				n_failed_instances = %%NUM_FAILED_INSTANCES%%,
				b_reached_threshold = '%%FAILED_THRESHOLD_REACHED%%',
				b_reached_timeout = '%%TIMEOUT_REACHED%%'
				where 
				tx_initiator_adapter_name = '%%INITIATOR_NAME%%' 
				AND tx_rpt_template_unique_name = '%%TEMPLATE_NAME%%' 
				AND n_initiator_adapter_billgrpid = %%ID_BILLGROUP%%
				and tx_status = 'New'
			end
			