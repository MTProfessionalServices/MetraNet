	   
		   update ft
	             set State = 'R',
	             dt_StateLastModifiedTime = %%METRADATE%%,
                 resubmit_Guid = NULL,
                 dt_Start_Resubmit = NULL
	             from %%RERUN_TABLE_NAME%% rr
	             inner join t_failed_transaction ft WITH (READCOMMITTED)
	             on rr.id_source_sess = ft.tx_failureID
	             where rr.tx_state = 'B'
	   	 

	  