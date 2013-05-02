
 begin
    	insert into tmp_session (id_ss, id_source_sess) 
		              select id_sess + %%ID_SESSIONSET_START%%, id_parent_source_sess 
			            from tmp_aggregate_large;

		insert into tmp_session_set (id_ss, id_message, id_svc, session_count, b_root) 
		              select id_sess + %%ID_SESSIONSET_START%%, id_sess + %%ID_MESSAGE_START%%, %%ID_SVC%%, 1, '1'
			            from tmp_aggregate_large;
    			         
		insert into tmp_message(id_message) 
			  select id_message
			    from tmp_session_set
			    where id_message > %%ID_MESSAGE_START%%;
			              
		insert into tmp_session (id_ss, id_source_sess) 
				select css.id_sess + %%NUM_LARGE_MESSAGES%% + %%ID_SESSIONSET_START%%, rr.id_source_sess
				from  %%RERUN_TABLE_NAME%% rr
				inner join tmp_aggregate_large prnt on prnt.id_parent_source_sess=rr.id_parent_source_sess
				inner join tmp_child_session_sets css on css.id_parent_sess=prnt.id_sess and css.id_svc=rr.id_svc;
			                 
     	insert into tmp_session_set (id_ss, id_message, id_svc, session_count, b_root) 
				select id_sess + %%NUM_LARGE_MESSAGES%% + %%ID_SESSIONSET_START%%, id_parent_sess + %%ID_MESSAGE_START%%, id_svc, cnt, '0'
				from tmp_child_session_sets;
	
     
  end;	   
	  