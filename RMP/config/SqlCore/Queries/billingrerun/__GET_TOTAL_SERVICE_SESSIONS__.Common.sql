
      select count(*) as num_service_sessions from 
			  %%RERUN_TABLE_NAME%%  rr 
			  inner join %%SVC_TABLE_NAME%% svc %%%READCOMMITTED%%%
			  on rr.id_source_sess = svc.id_source_sess
			  where rr.id_svc = %%ID_SVC%% and rr.tx_state <> 'C' and rr.tx_state <> 'S'
 
	  