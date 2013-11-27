
Create or replace PROCEDURE DELETESOURCEDATA(p_rerun_table_name varchar2, p_metradate varchar2)
as
v_sql varchar2(4000);
/* values we get from the cursor*/
v_tablename varchar2(255);
v_id_svc number(10);
tablename_cursor sys_refcursor;
begin
    /* delete from the service tables.*/
    v_sql := 'select rr.id_svc, svc.nm_table_name from
              t_enum_data ed
              inner join ' || p_rerun_table_name || N' rr
              on rr.id_svc = ed.id_enum_data
              inner join t_service_def_log svc
              on upper(svc.nm_service_def) = upper(ed.nm_enum_data)
              where (rr.tx_state = ''B'' OR
              rr.tx_state = ''NA'')
              group by rr.id_svc, svc.nm_table_name';

    OPEN tablename_cursor for v_sql;
    LOOP
        FETCH tablename_cursor into v_id_svc, v_tablename;
        exit when tablename_cursor%NOTFOUND;
        v_sql := 'DELETE from ' || v_tablename || ' where id_source_sess in (select id_source_sess from '
                || p_rerun_table_name || ' where id_svc = ' ||
                to_char(v_id_svc) || N' and (tx_state = ''B'' or tx_state = ''NA''))';

        execute immediate v_sql;
    END LOOP;
    CLOSE tablename_cursor;

    /* update t_session_state*/
    v_sql := 'update t_session_state ss
                  set dt_end = TO_TIMESTAMP(''' || p_metradate || ''', ''yyyy-mm-dd HH24:MI:SS.FF'')
                  where exists (select 1 from ' || p_rerun_table_name || ' rr
                  where rr.id_source_sess = ss.id_sess
                  and rr.tx_state <> ''B'')
                  and ss.dt_end = dbo.MTMaxDate()';

    execute immediate v_sql;

    v_sql := 'INSERT INTO t_session_state (id_sess, dt_start, dt_end, tx_state)
              SELECT rr.id_source_sess, TO_TIMESTAMP(''' || p_metradate || ''', ''yyyy-mm-dd HH24:MI:SS.FF'')
                , dbo.MTMaxDate(), ''D''
              from ' || p_rerun_table_name || ' rr
              where rr.tx_state <> ''B'' ';

    execute immediate v_sql;

    /* update t_message for pending and suspended transactions for pending,
       the dt_assigned and dt_completed are set to MTMAXDate, for suspended,
       the dt_completed to MTMaxDate */

    v_sql := N'update t_message
             set dt_assigned = dbo.MTMaxDate()
             where id_message in (
                 select ss.id_message from ' || p_rerun_table_name || ' rr
                 inner join t_session sess
                 on sess.id_source_sess = rr.id_source_sess
                 inner join t_session_set ss
                 on sess.id_ss = ss.id_ss
                 inner join t_message msg
                 on msg.id_message = ss.id_message
                 where rr.tx_state = ''NA'')
                 and dt_assigned is null';

    execute immediate v_sql;

    v_sql := 'update t_message
                 set dt_completed = dbo.MTMaxDate()
                 where id_message in (
                 select ss.id_message from ' || p_rerun_table_name || N' rr
                 inner join t_session sess
                 on sess.id_source_sess = rr.id_source_sess
                 inner join t_session_set ss
                 on sess.id_ss = ss.id_ss
                 inner join t_message msg
                 on msg.id_message = ss.id_message
                 where rr.tx_state = ''NA'')
                 and dt_completed is null';

    execute immediate v_sql;
end;
    