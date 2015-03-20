begin
  /* For performance reasons, break the encapsulation of the TTT package layer. */
  /* In general, this should not be done. */
  declare numChildrenSvc number(10);
  v_tx_id dba_2pc_pending.global_tran_id%TYPE         DEFAULT NULL;
  begin 
    /* Access the TTT table directly, by storing the transaction id in a local variable, */
    /* and adding the tx_id column access as required. */
    v_tx_id := mt_ttt.get_tx_id();
    
    select count(*) into numChildrenSvc
	  from ttt_tmp_svc_relations
	  where parent_id_svc = %%ID_SVC%% and tx_id = v_tx_id;
    if(numChildrenSvc > 0) then 
        begin
          -- you could have some parents with no children at all (CR13174) which
			    -- would be missed in the original inner join. Changing the inner join
			    -- to left outer and adding the case statement fixes that.
          insert into ttt_tmp_aggregate (tx_id, id_sess, id_parent_source_sess, sessions_in_compound)
                 select  v_tx_id, seq_aggregate_%%RERUN_ID%%.nextval, t.id_parent_source_sess, t.sessions_in_compound
                  from (
                        select rr_parent.id_source_sess as id_parent_source_sess, sum(case when rr_child.id_source_sess       is null then 0 else 1 end) + 1 as sessions_in_compound
                        from %%RERUN_TABLE_NAME%% rr_parent
                        left join %%RERUN_TABLE_NAME%% rr_child
                                  on rr_parent.id_source_sess = rr_child.id_parent_source_sess
                        where rr_parent.id_parent_source_sess is null
                              and rr_parent.id_svc = %%ID_SVC%%
                              and rr_parent.tx_state = 'B'
                        group by rr_parent.id_source_sess
                        having count(*) < 400
                       ) t;
          
          insert into ttt_tmp_aggregate_large (tx_id, id_sess, id_parent_source_sess, sessions_in_compound)
                 select  v_tx_id, seq_aggregate_large_%%RERUN_ID%%.nextval, t.id_parent_source_sess, t.sessions_in_compound
                 from(
                    select rr_parent.id_source_sess as id_parent_source_sess, count(*) + 1 as sessions_in_compound
                    from %%RERUN_TABLE_NAME%% rr_parent
                    inner join %%RERUN_TABLE_NAME%% rr_child on rr_parent.id_source_sess = rr_child.id_parent_source_sess
                    where rr_parent.id_parent_source_sess is null 
                          and rr_parent.id_svc = %%ID_SVC%%
                          and rr_parent.tx_state = 'B'
                    group by rr_parent.id_source_sess
                    having count(*) >= 400
                 )t;
        end;
    else
        begin
          insert into ttt_tmp_aggregate(tx_id, id_sess, id_parent_source_sess, sessions_in_compound)
                      select v_tx_id, seq_aggregate_%%RERUN_ID%%.Nextval, id_source_sess, 1
			                from %%RERUN_TABLE_NAME%%
			                where id_svc = %%ID_SVC%%
                            and tx_state = 'B';
        end;
    End if;
  end;
end;                 