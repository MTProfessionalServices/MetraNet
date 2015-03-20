declare
  /* For performance reasons, break the encapsulation of the TTT package layer. */
  /* In general, this should not be done.*/
  v_tx_id dba_2pc_pending.global_tran_id%TYPE           DEFAULT NULL;
begin 
  /* Access the TTT table directly, by storing the transaction id in a local variable,*/
  /* and adding the tx_id column access as required. */
  v_tx_id := mt_ttt.get_tx_id();
  
  insert into ttt_tmp_session (tx_id, id_ss, id_source_sess)
              select v_tx_id, id_ss + (%%NUM_REGULAR_MESSAGES%% * %%I%%), rr.id_source_sess
              from %%RERUN_TABLE_NAME%% rr
              inner join ttt_tmp_session ss on ss.tx_id = v_tx_id and ss.id_source_sess = rr.id_parent_source_sess
              where ss.id_ss >= %%ID_SESSIONSET_START%%
                    and ss.id_ss < %%ID_SESSIONSET_START%% + (%%NUM_REGULAR_MESSAGES%% * %%I%%)
                    and rr.id_svc = %%ID_CHILD_SVC%%
              order by ss.tx_id, ss.id_ss, ss.id_source_sess;
              
  insert into ttt_tmp_session_set (tx_id, id_ss, id_message, id_svc, session_count, b_root)
              select /* + USE_MERGE(tmpss tmpparent) */ 
                     tmpss.tx_id, tmpss.id_ss, tmpparent.id_message, %%ID_CHILD_SVC%%, numrecs, '0'
              from (
                      select ss.tx_id, min(rr.id_parent_source_sess) id_parent_source_sess, ss.id_ss, count(*) numrecs
                      from ttt_tmp_session ss
                      inner join %%RERUN_TABLE_NAME%% rr on ss.tx_id = v_tx_id and ss.id_source_sess = rr.id_source_sess
                      where ss.tx_id = v_tx_id and ss.id_ss >= (%%ID_SESSIONSET_START%% + (%%NUM_REGULAR_MESSAGES%% * %%I%%))
                            and ss.id_ss < (%%ID_SESSIONSET_START%% + (%%NUM_REGULAR_MESSAGES%% * (%%I%% + 1)))
                      group by ss.tx_id, ss.id_ss
                      order by ss.tx_id, ss.id_ss, min(rr.id_parent_source_sess)
                    ) tmpss
                   inner join(
                       select parent.tx_id, parent.id_ss, parent.id_source_sess, parentset.id_message
                       from ttt_tmp_session parent
                       inner join ttt_tmp_session_set parentset 
                                  on parentset.tx_id  = parent.tx_id and parentset.id_ss = parent.id_ss
                       where parent.tx_id = v_tx_id and parentset.id_message >= %%ID_MESSAGE_START%%
                             and parentset.id_message < %%ID_MESSAGE_START%% + %%NUM_REGULAR_MESSAGES%%
                       order by parent.tx_id, parent.id_ss, parent.id_source_sess
                   ) tmpparent
                   on tmpparent.tx_id = tmpss.tx_id
               and tmpparent.id_source_sess = tmpss.id_parent_source_sess;
 
 end;