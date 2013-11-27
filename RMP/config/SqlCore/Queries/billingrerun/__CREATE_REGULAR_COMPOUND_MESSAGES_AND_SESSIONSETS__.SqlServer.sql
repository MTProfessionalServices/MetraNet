
      -- creating sessionsets for the parent svc
    	insert into #session (id_ss, id_source_sess) 
		              select (id_sess%%%NUM_REGULAR_MESSAGES%%) + %%ID_SESSIONSET_START%%, id_parent_source_sess 
			            from #aggregate

			insert into #session_set (id_ss, id_message, id_svc, session_count, b_root) 
		              select id_ss, (id_ss%%%NUM_REGULAR_MESSAGES%%) + %%ID_MESSAGE_START%%, %%ID_SVC%%, count(*), '1'
			            from #session where id_ss >= %%ID_SESSIONSET_START%% and id_ss < (%%ID_SESSIONSET_START%% + %%NUM_REGULAR_MESSAGES%%)
			          group by id_ss
    			         
			insert into #message (id_message)
			         select id_message from #session_set
			         where id_message >= %%ID_MESSAGE_START%% and id_message < (%%ID_MESSAGE_START%% + %%NUM_REGULAR_MESSAGES%%)


	  