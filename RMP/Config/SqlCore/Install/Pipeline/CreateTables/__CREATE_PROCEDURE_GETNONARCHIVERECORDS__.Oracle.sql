
create or replace
procedure GetNonArchiveRecords(ignore_session_part_id int, ignore_state_part_id int)
authid current_user 
as  
pragma autonomous_transaction; 
v_maxtime DATE;
v_count int;
v_sql varchar(1000);
begin   
  v_maxtime := dbo.mtmaxdate();
   
   
    
    
    
    BEGIN
     v_sql := 'INSERT INTO TMP_NON_ARCHIVE_DATA     '
      || ' SELECT sess.id_source_sess   ' 
      || ' FROM t_session sess  ' 
      || ' WHERE NOT EXISTS    (SELECT 1    ' 
      || '                      FROM t_session_state state ' 
      || '                      WHERE state.id_sess = sess.id_source_sess ' 
      || '                      AND state.ID_PARTITION <> ' || ignore_state_part_id || ') ' 
      || ' AND sess.ID_PARTITION <> ' || ignore_session_part_id  
      || ' UNION ALL   ' 
      || ' SELECT id_sess  ' 
      || ' FROM t_session_state state   ' 
      || ' WHERE tx_state IN(''F'',   ''R'')   ' 
      || ' AND state.ID_PARTITION <> ' || ignore_state_part_id || ' AND state.dt_end = ''' || v_maxtime || ''''; 
      dbms_output.put_line(v_sql);   
      AddArchiveQueueProcessStatus(' executing 1st insert stmt to tmp_non_archive_data'); 
      execute immediate v_sql;
     /* EXCEPTION WHEN OTHERS THEN
      AddArchiveQueueProcessStatus(' error while inserting data into table tmp_non_archive_data ' || SQLERRM); 
      dbms_output.put_line('exception occurred in insert into tmp_non_archive_data'); 
      RETURN;    */
    END;
    

  
  
  BEGIN
    AddArchiveQueueProcessStatus(' executing select stmt to find any prod-view with b_can_resubmit_from is N'); 
    EXECUTE IMMEDIATE 'SELECT COUNT(1)  '
                || ' FROM t_prod_view  '
                || ' WHERE b_can_resubmit_from = ''N'''  
                || ' AND nm_table_name NOT LIKE ''t_acc_usage''' into v_count;   
      /*EXCEPTION WHEN OTHERS THEN
      AddArchiveQueueProcessStatus(' error while creating table tmp_non_archive_data ' || SQLERRM); 
      RETURN;     */
  END;
  
  IF(v_count > 0) THEN   
  BEGIN     
    AddArchiveQueueProcessStatus(' executing 2nd insert stmt to tmp_non_archive_data joining t_acc_usage and checking interval status. '); 
    v_sql := 'INSERT INTO TMP_NON_ARCHIVE_DATA     '
      || ' SELECT state.id_sess     '
      || ' FROM t_acc_usage au     '
      || ' INNER JOIN t_session_state state ON au.tx_uid = state.id_sess     '
      || ' INNER JOIN t_prod_view prod ON au.id_view = prod.id_view      '
      || ' AND prod.b_can_resubmit_from = ''N''     '
      || ' WHERE state.dt_end = ''' || v_maxtime ||  ''' AND state.ID_PARTITION <> ' || ignore_state_part_id || ' AND '
      || ' au.id_usage_interval IN     (SELECT DISTINCT id_interval        '
      || '                                  FROM t_usage_interval        '
      || '                                  WHERE tx_interval_status <> ''H'')';   
      EXECUTE IMMEDIATE v_sql;
      dbms_output.put_line(v_sql);   
      /*EXCEPTION WHEN OTHERS THEN
      AddArchiveQueueProcessStatus(' error while inserting into table tmp_non_archive_data ' || SQLERRM); 
      RETURN;      */
  END;  
  END IF;     
  
  
  /*
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE TMP_NON_ARCHIVE_DATA MODIFY ("ID_SOURCE_SESS" NOT NULL)';
    EXCEPTION WHEN OTHERS THEN
    AddArchiveQueueProcessStatus(' error while alter table tmp_non_archive_data ' || SQLERRM); 
    RETURN;      
  END;
  */
  

  
  COMMIT;
  
END;

    