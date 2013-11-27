
			Insert into %%DELTA_TABLE_NAME%% select * from %%BASE_TABLE_NAME%% bt
			where exists (select 1 from %%RERUN_TABLE_NAME%% rerun where bt.id_sess = rerun.id_sess 
						  and bt.id_usage_interval = rerun.id_interval and rerun.tx_state = 'A');
		