
    	insert into #session (id_ss, id_source_sess) 
		              select id_sess + %%ID_SESSIONSET_START%%, id_parent_source_sess 
			            from #aggregate_large

			insert into #session_set (id_ss, id_message, id_svc, session_count, b_root) 
		              select id_sess + %%ID_SESSIONSET_START%%, id_sess + %%ID_MESSAGE_START%%, %%ID_SVC%%, 1, '1'
			            from #aggregate_large
    			         
			insert into #message(id_message) 
			  select  id_message
			    from #session_set
			    where id_message > %%ID_MESSAGE_START%%
			              
		  insert into #session (id_ss, id_source_sess) 
				select css.id_sess + %%NUM_LARGE_MESSAGES%% + %%ID_SESSIONSET_START%%, rr.id_source_sess
				from  %%RERUN_TABLE_NAME%% rr
				inner join #aggregate_large prnt on prnt.id_parent_source_sess=rr.id_parent_source_sess
				inner join #child_session_sets css on css.id_parent_sess=prnt.id_sess and css.id_svc=rr.id_svc
			                 
     	insert into #session_set (id_ss, id_message, id_svc, session_count, b_root) 
				select id_sess + %%NUM_LARGE_MESSAGES%% + %%ID_SESSIONSET_START%%, id_parent_sess + %%ID_MESSAGE_START%%, id_svc, cnt, '0'
				from #child_session_sets
	
  	  