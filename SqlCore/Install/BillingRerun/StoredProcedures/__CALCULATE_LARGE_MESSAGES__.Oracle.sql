
create or replace procedure CalculateLargeMessages(
      p_rerunID int,
      p_num_large_messages OUT int,
      p_num_large_session_sets OUT int)
as

   v_sql varchar2(4000);

begin   
   select count(*) into p_num_large_messages from tmp_aggregate_large;
    
   v_sql := 'insert into tmp_child_session_sets (id_sess, id_parent_sess, id_svc, cnt)
                select seq_childss_' || to_char(p_rerunID) || '.nextval, t.id_sess, t.id_svc, t.numsess
                from 
                ( select prnt.id_sess, rr.id_svc, count(*) as numsess
                from t_rerun_session_' || to_char(p_rerunID) || ' rr
                inner join tmp_aggregate_large prnt
                on prnt.id_parent_source_sess=rr.id_parent_source_sess
				group by prnt.id_sess, rr.id_svc) t ';
   execute immediate v_sql;
   
   select NVL(max(id_sess), 0) + p_num_large_messages into p_num_large_session_sets
    from tmp_child_session_sets;
  
end;
            