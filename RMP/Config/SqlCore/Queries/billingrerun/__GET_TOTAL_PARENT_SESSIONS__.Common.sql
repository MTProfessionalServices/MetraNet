

       select count(*) as num_parent_sessions from 
			      %%RERUN_TABLE_NAME%%
			      rr where rr.id_svc = %%ID_SVC%%
			      and rr.id_parent_source_sess is null and rr.tx_state <> 'C' and rr.tx_state <> 'S'
     
	  