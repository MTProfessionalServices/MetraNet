	   
		      begin
		      insert into t_session (id_ss, id_source_sess)
		      select id_ss, id_source_sess from #session;
		      
		      insert into t_session_set (id_ss, id_message, id_svc, session_count, b_root)
		      select id_ss, id_message, id_svc, session_count, b_root from #session_set;
		      
		      insert into t_message(id_message, id_route, dt_crt, dt_assigned, 
			    id_listener, id_pipeline, dt_completed, id_feedback, dt_metered, tx_sc_serialized, tx_ip_address) 
			    select  id_message, null, %%METRADATE%%, null, null, null, 
			    null, null, %%METRADATE%%, '%%CONTEXT%%', '127.0.0.1'
			    from #message;
			    end;
	  