declare
  /* For performance reasons, break the encapsulation of the TTT package layer. */
  /* In general, this should not be done.                                       */
  v_tx_id dba_2pc_pending.global_tran_id%TYPE   DEFAULT NULL;
 begin
    /* Access the TTT table directly, by storing the transaction id in a          */
    /* local variable, and adding the tx_id column access as required.            */
    v_tx_id := mt_ttt.get_tx_id();
    	
    insert into ttt_tmp_session (tx_id, id_ss, id_source_sess) 
		              select v_tx_id, id_sess + %%ID_SESSIONSET_START%%, id_parent_source_sess 
			            from ttt_tmp_aggregate_large
                  where tx_id = v_tx_id;

		insert into ttt_tmp_session_set (tx_id, id_ss, id_message, id_svc, session_count, b_root) 
		              select v_tx_id, id_sess + %%ID_SESSIONSET_START%%, id_sess + %%ID_MESSAGE_START%%, %%ID_SVC%%, 1, '1'
			            from ttt_tmp_aggregate_large
                  where tx_id = v_tx_id;
    			         
		insert into ttt_tmp_message(tx_id, id_message) 
			  select v_tx_id, id_message
			    from ttt_tmp_session_set
			    where id_message > %%ID_MESSAGE_START%%
            and tx_id = v_tx_id;
			              
		insert into ttt_tmp_session (tx_id, id_ss, id_source_sess) 
				select v_tx_id, css.id_sess + %%NUM_LARGE_MESSAGES%% + %%ID_SESSIONSET_START%%, rr.id_source_sess
				from  %%RERUN_TABLE_NAME%% rr
				inner join ttt_tmp_aggregate_large prnt on prnt.id_parent_source_sess=rr.id_parent_source_sess and prnt.tx_id = v_tx_id
				inner join ttt_tmp_child_session_sets css on css.id_parent_sess=prnt.id_sess and css.id_svc=rr.id_svc and css.tx_id = v_tx_id;
			                 
     	insert into ttt_tmp_session_set (tx_id, id_ss, id_message, id_svc, session_count, b_root) 
				select v_tx_id, id_sess + %%NUM_LARGE_MESSAGES%% + %%ID_SESSIONSET_START%%, id_parent_sess + %%ID_MESSAGE_START%%, id_svc, cnt, '0'
				from ttt_tmp_child_session_sets
        where tx_id = v_tx_id;
	
     
  end;	   
	  