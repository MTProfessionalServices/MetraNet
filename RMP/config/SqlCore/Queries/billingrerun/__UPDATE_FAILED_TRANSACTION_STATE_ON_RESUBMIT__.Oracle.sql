	   
		 	  update t_failed_transaction ft
	             set State = 'R',
	             dt_StateLastModifiedTime = %%METRADATE%%
	             where exists(select ft.tx_failureID from
	             %%RERUN_TABLE_NAME%% rr
	             where rr.id_source_sess = ft.tx_failureID
	             and rr.tx_state = 'B')
	             