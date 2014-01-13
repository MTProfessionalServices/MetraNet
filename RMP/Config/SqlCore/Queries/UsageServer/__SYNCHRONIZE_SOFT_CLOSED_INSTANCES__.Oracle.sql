
			UPDATE t_recevent_inst inst
			SET id_event = %%NEW_EVENT_ID%%
			where exists (select 'x' 
			FROM t_usage_interval ui 
			where ui.id_interval = inst.id_arg_interval
			and
			inst.id_event = %%OLD_EVENT_ID%% AND
			ui.tx_interval_status = 'C')
	  