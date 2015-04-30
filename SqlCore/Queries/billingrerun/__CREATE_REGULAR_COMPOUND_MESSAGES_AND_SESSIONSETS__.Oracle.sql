
     declare
      /* For performance reasons, break the encapsulation of the TTT package layer. */
      /* In general, this should not be done.                                       */
      v_tx_id dba_2pc_pending.global_tran_id%TYPE   DEFAULT NULL;
     begin
      /* Access the TTT table directly, by storing the transaction id in a          */
      /* local variable, and adding the tx_id column access as required.            */
      v_tx_id := mt_ttt.get_tx_id(); 
      
      insert into ttt_tmp_session (tx_id, id_ss, id_source_sess) 
              select v_tx_id, mod(id_sess, %%NUM_REGULAR_MESSAGES%%) + %%ID_SESSIONSET_START%%, id_parent_source_sess 
              from ttt_tmp_aggregate
              where tx_id = v_tx_id
              order by tx_id, id_sess;

			insert into ttt_tmp_session_set (tx_id, id_ss, id_message, id_svc, session_count, b_root) 
		              select v_tx_id, id_ss, mod(id_ss, %%NUM_REGULAR_MESSAGES%%) + %%ID_MESSAGE_START%%, %%ID_SVC%%, count(*), '1'
			            from ttt_tmp_session where tx_id = v_tx_id
                  and id_ss >= %%ID_SESSIONSET_START%% and id_ss < (%%ID_SESSIONSET_START%% + %%NUM_REGULAR_MESSAGES%%)
			            group by tx_id, id_ss
                  order by tx_id, id_ss;
    			         
			insert into ttt_tmp_message(tx_id, id_message)
			         select tx_id, id_message from ttt_tmp_session_set
			         where tx_id = v_tx_id
               and id_message >= %%ID_MESSAGE_START%% and id_message < (%%ID_MESSAGE_START%% + %%NUM_REGULAR_MESSAGES%%)
               order by tx_id, id_message;
     end;			         


	  