
        		insert into t_nonrecurring_event_run
				values (seq_t_nonrecurring_event_run.nextval, %%ID_INTERVAL%%, 
				TO_DATE('%%DT_START%%', 'YYYY/MM/DD HH24:MI:SS'),
				TO_DATE('%%DT_END%%', 'YYYY/MM/DD HH24:MI:SS'),
				'%%ADAPTER_NAME%%','%%ADAPTER_METHOD%%','%%CONFIG_FILE%%')
			