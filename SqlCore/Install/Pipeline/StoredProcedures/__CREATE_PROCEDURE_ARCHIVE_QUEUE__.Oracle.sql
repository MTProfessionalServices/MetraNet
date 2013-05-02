
create or replace
PROCEDURE archive_queue
(    
  p_update_stats           CHAR DEFAULT 'N',    
  p_sampling_ratio         VARCHAR2 DEFAULT '30',    
  p_result           OUT   VARCHAR2 ) 
AS    
  v_sql1                    VARCHAR2 (4000);   
  v_tab1                    VARCHAR2 (1000);    
  v_var1                    VARCHAR2 (1000);    
  v_vartime                 DATE;    
  v_maxtime                 DATE;    
  c1                        sys_refcursor;   
  c2                        sys_refcursor;
  v_nu_varstatpercentchar   int;    
  v_user_name        varchar2(30);
  max_id_sess        NUMBER;
  partition_exists   int;
  l_partition_name   varchar2(100);
  l_partition_id     NUMBER(10);
  l_t_session_next_part_id NUMBER(10);
  l_t_session_state_next_part_id NUMBER(10);
  l_t_session_set_next_part_id NUMBER(10);
  l_t_message_next_part_id NUMBER(10);
  l_data_default     user_tab_columns.data_default%TYPE DEFAULT 1;
BEGIN   
/* How to run this stored procedure      
	DECLARE      P_RESULT VARCHAR2(200);    
	BEGIN      P_RESULT := NULL;      
	ARCHIVE_QUEUE ( p_result => P_RESULT );    
	dbms_output.put_line(p_result);      
	COMMIT;    
	END;    
	OR      
	DECLARE      
	P_UPDATE_STATS VARCHAR2(200);      
	P_SAMPLING_RATIO VARCHAR2(200);      
	P_RESULT VARCHAR2(200);    
	BEGIN      
	P_UPDATE_STATS := 'Y';      
	P_SAMPLING_RATIO := 100;      
	P_RESULT := NULL;      
	ARCHIVE_QUEUE ( P_UPDATE_STATS, P_SAMPLING_RATIO, P_RESULT );     
	dbms_output.put_line(p_result);      
	COMMIT;    
	END;       
	*/

v_maxtime := dbo.mtmaxdate();   
l_partition_id := 0;
l_t_session_next_part_id := 0;
l_t_session_state_next_part_id := 0;
l_t_session_set_next_part_id := 0;
l_t_message_next_part_id := 0;
  
AddArchiveQueueProcessStatus('Archive Process Started'); 

IF NOT DBMS_DB_VERSION.VER_LE_10 THEN
  EXECUTE IMMEDIATE 'ALTER SESSION SET ddl_lock_timeout = 20';
  DBMS_OUTPUT.PUT_LINE('set ddl_lock_timeout to 20');
END IF;

AddArchiveQueueProcessStatus('drop table tmp_seq_holder - started'); 

IF table_exists('tmp_seq_holder') THEN    
      BEGIN
        EXECUTE IMMEDIATE 'drop table tmp_seq_holder'; 
        EXCEPTION WHEN OTHERS THEN
        p_result := '7000006-archive_queues operation failed->Error in drop temp table -> tmp_seq_holder'; 
        ROLLBACK;
        RETURN;       
      END;
END IF;
AddArchiveQueueProcessStatus('drop table tmp_seq_holder - finished'); 

/* CREATE TABLE TO STORE archive table names and next partition id for all archivable tables.*/
AddArchiveQueueProcessStatus('create table tmp_seq_holder - started'); 
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE tmp_seq_holder as select nm_table_name as table_name, 0 as next_id from t_service_def_log';  
  EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error in create temp table -> tmp_seq_holder';   
  ROLLBACK;
  RETURN;         
END;
AddArchiveQueueProcessStatus('create table tmp_seq_holder - finished'); 

AddArchiveQueueProcessStatus('insert into tmp_seq_holder - started'); 
BEGIN
  EXECUTE IMMEDIATE 'INSERT INTO tmp_seq_holder VALUES (''t_session'', 0)';
  EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error in inserting data into tmp_seq_holder for table name -> t_session';   
  ROLLBACK;
  RETURN;  
END;
BEGIN
  EXECUTE IMMEDIATE 'INSERT INTO tmp_seq_holder VALUES (''t_session_set'', 0)';
  EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error in inserting data into tmp_seq_holder for table name -> t_session_set';   
  ROLLBACK;
  RETURN;  
END;
BEGIN
  EXECUTE IMMEDIATE 'INSERT INTO tmp_seq_holder VALUES (''t_session_state'', 0)';
  EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error in inserting data into tmp_seq_holder for table name -> t_session_state';   
  ROLLBACK;
  RETURN;  
END;
BEGIN
  EXECUTE IMMEDIATE 'INSERT INTO tmp_seq_holder VALUES (''t_message'', 0)';
  EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error in inserting data into tmp_seq_holder for table name -> t_message';   
  ROLLBACK;
  RETURN;  
END;
AddArchiveQueueProcessStatus('insert into tmp_seq_holder - finished'); 


/*******************************************************************************/
/* BEGIN - LOOP ALL TABLES AND create new partition and update tmp_seq_holder
           with new partition id */
/*******************************************************************************/

AddArchiveQueueProcessStatus('create new partition and update tmp_seq_holder with new partition id  - started'); 

v_sql1 := 'SELECT table_name from tmp_seq_holder';

OPEN c1 FOR v_sql1;  

LOOP    
FETCH c1  INTO v_tab1;    
EXIT   WHEN c1 % NOTFOUND;   

BEGIN

AddArchiveQueueProcessStatus('create new partition and update tmp_seq_holder with new partition id for table ' || UPPER(v_tab1) || ' - started'); 

  BEGIN
    execute immediate 'select data_default from '
      || 'user_tab_columns where table_name = UPPER(''' || v_tab1 || ''') and column_name =  UPPER(''ID_PARTITION'')' into l_data_default;
  
    /*
    SELECT data_default 
    into l_data_default 
    from user_tab_columns 
    where table_name = UPPER(v_tab1) 
    and column_name = 'ID_PARTITION';
    */
    EXCEPTION WHEN OTHERS THEN
    p_result := '7000006-archive_queues operation failed->Error while fetching '
              || ' default value from user_tab_columns for table -> ' 
              || UPPER(v_tab1) || 'column ID_PARTITION';   
    ROLLBACK;
    CLOSE c1;
    RETURN;     
  END;
  
  l_partition_id := TO_NUMBER(l_data_default);
  l_partition_id := l_partition_id + 1;
  
  BEGIN
    EXECUTE IMMEDIATE 'UPDATE tmp_seq_holder '
                      || 'SET next_id = ' || l_partition_id || 'where table_name = ''' || v_tab1 || '''';
                      
    EXCEPTION WHEN OTHERS THEN
    p_result := '7000006-archive_queues operation failed->Error while updating '
              || ' next id in tmp_seq_holder for table -> ' || UPPER(v_tab1);
    ROLLBACK;
    CLOSE c1;
    RETURN;                           
  END;
 
  BEGIN           
    
    v_sql1 := 'select count(1) '
          || ' from user_tab_partitions '
          || ' where table_name = UPPER(''' || v_tab1 || ''')'
          || ' and PARTITION_NAME =  UPPER(''P' ||  cast(l_partition_id as varchar) || ''')';
          
    
    
    BEGIN
      execute immediate v_sql1 into partition_exists;
     /*
      EXECUTE IMMEDIATE 'select count(1) '
                    || ' into partition_exists '
                    || ' from user_tab_partitions '
                    || ' where table_name = UPPER(''' || v_tab1 || ''')'
                    || ' and PARTITION_NAME = UPPER(''P' ||  l_partition_id || ''')';
      */
      dbms_output.put_line('partition_exists value -> ' || cast(partition_exists as varchar));
      EXCEPTION WHEN OTHERS THEN
      p_result := '7000006-archive_queues operation failed->Error while fetching '
                || ' no of partitions for table -> ' || UPPER(v_tab1) || '. Error : '  || SQLERRM;
      ROLLBACK;
      CLOSE c1;
      RETURN;                           
    END;
    
    BEGIN
      EXECUTE IMMEDIATE('lock table ' || v_tab1 || ' in exclusive mode');
      EXCEPTION WHEN OTHERS THEN
      p_result := '7000006-archive_queues operation failed->Error while  '
                || ' locking table -> ' || UPPER(v_tab1);
      ROLLBACK;
      CLOSE c1;
      RETURN;    
    END;

    if (TO_NUMBER(partition_exists) = 0) THEN
      BEGIN
       dbms_output.put_line('partition does not exists');
        AddArchiveQueueProcessStatus('adding new partition for table ' || v_tab1);
        EXECUTE IMMEDIATE 'ALTER TABLE ' || v_tab1 || ' ADD PARTITION P' || l_partition_id ||' VALUES (' || l_partition_id ||')';
        EXCEPTION WHEN OTHERS THEN
        p_result := '7000006-archive_queues operation failed->Error while executing alter stmt to add partition for  '
                  || '  table -> ' || UPPER(v_tab1);
        ROLLBACK;
        CLOSE c1;
        RETURN;                                 
      END;
    end if;   
    
    
    BEGIN
      EXECUTE IMMEDIATE('lock table ' || v_tab1 || ' in exclusive mode');
      EXCEPTION WHEN OTHERS THEN
      p_result := '7000006-archive_queues operation failed->Error while  '
                || ' locking table -> ' || UPPER(v_tab1);
      ROLLBACK;
      CLOSE c1;
      RETURN;    
    END;
    
    BEGIN
      v_sql1 :=  'ALTER TABLE ' || v_tab1 || ' ENABLE ROW MOVEMENT';
      dbms_output.put_line(v_sql1);
      EXECUTE IMMEDIATE v_sql1;
      EXCEPTION WHEN OTHERS THEN
      p_result := '7000006-archive_queues operation failed->Error while  '
                || ' enabling row movement for table -> ' || UPPER(v_tab1) || ' error : ' || SQLERRM;
      ROLLBACK;
      CLOSE c1;
      RETURN;                                     
    END;    
    
    
    BEGIN
      EXECUTE IMMEDIATE('lock table ' || v_tab1 || ' in exclusive mode');
      EXCEPTION WHEN OTHERS THEN
      p_result := '7000006-archive_queues operation failed->Error while  '
                || ' locking table -> ' || UPPER(v_tab1);
      ROLLBACK;
      CLOSE c1;
      RETURN;    
    END;
    
    BEGIN
      v_sql1 :=  'ALTER TABLE ' || v_tab1 || ' MODIFY (ID_PARTITION DEFAULT '|| l_partition_id ||')';
      dbms_output.put_line(v_sql1);
      EXECUTE IMMEDIATE v_sql1;
      EXCEPTION WHEN OTHERS THEN
      p_result := '7000006-archive_queues operation failed->Error while  '
                || ' modifying default value for table -> ' || UPPER(v_tab1) || ' error : ' || SQLERRM;
      ROLLBACK;
      CLOSE c1;
      RETURN;                                     
    END;
    
    IF UPPER(v_tab1) = 'T_SESSION' THEN
      dbms_output.put_line('next partition id for t_session' || cast(l_partition_id as varchar));
      l_t_session_next_part_id := l_partition_id;
    END IF;
    
    IF UPPER(v_tab1) = 'T_SESSION_STATE' THEN
      dbms_output.put_line('next partition id for T_SESSION_STATE' || cast(l_partition_id as varchar));
      l_t_session_state_next_part_id := l_partition_id;
    END IF;
    
AddArchiveQueueProcessStatus('create new partition and update tmp_seq_holder with new partition id for table ' || UPPER(v_tab1) || ' - completed'); 
   
  END;
END;  
END LOOP; 
CLOSE c1;  

BEGIN
  IF l_t_session_next_part_id = 0 THEN
    p_result := '7000006-archive_queues operation failed -> problem getting next partition id for t_session';
    ROLLBACK;
    RETURN;
  END IF;
END;

BEGIN
  IF l_t_session_state_next_part_id = 0 THEN
    p_result := '7000006-archive_queues operation failed -> problem getting next partition id for t_session_state';
    ROLLBACK;
    RETURN;
  END IF;
END;


AddArchiveQueueProcessStatus('create new partition and update tmp_seq_holder with new partition id  - completed'); 

/*******************************************************************************/
/* END - LOOP ALL TABLES AND create new partition and update tmp_seq_holder
           with new partition id */
/*******************************************************************************/

 BEGIN
 IF table_exists('TMP_NON_ARCHIVE_DATA') THEN    
      BEGIN
        AddArchiveQueueProcessStatus(' executing drop table tmp_non_archive_data '); 
        EXECUTE IMMEDIATE 'drop table TMP_NON_ARCHIVE_DATA';
        /*EXCEPTION WHEN OTHERS THEN
        AddArchiveQueueProcessStatus(' error while deletign drop table tmp_non_archive_data ' || SQLERRM); 
        RETURN;    */
      END;
 END IF;
 END;

 BEGIN
        AddArchiveQueueProcessStatus(' executing create table tmp_non_archive_data '); 
        EXECUTE IMMEDIATE 'create table tmp_non_archive_data as select sess.id_source_sess from t_session sess where 0=1';
        /*EXCEPTION WHEN OTHERS THEN
         AddArchiveQueueProcessStatus(' error while creating table tmp_non_archive_data ' || SQLERRM); 
          RETURN;    */
 END;
 
 BEGIN
    AddArchiveQueueProcessStatus(' executing create unique index on tmp_non_archive_data'); 
    EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX UQ_TMP_NON_ARCHIVE_DATA ON TMP_NON_ARCHIVE_DATA (ID_SOURCE_SESS)';
  /*EXECUTE IMMEDIATE ' ALTER TABLE TMP_NON_ARCHIVE_DATA 
                        ADD CONSTRAINT PK_TMP_NON_ARCHIVE_DATA PRIMARY KEY ("ID_SOURCE_SESS") ENABLE'; */
   /* EXCEPTION WHEN OTHERS THEN
    AddArchiveQueueProcessStatus(' error while create unique index tmp_non_archive_data ' || SQLERRM); 
    RETURN; */                         
 END;

/*******************************************************************************/
/* BEGIN - LOOP ALL TABLES AND LOCK THEM in EXCLUSIVE MODE.*/
/*******************************************************************************/

AddArchiveQueueProcessStatus(' lock tables in exclusive mode - started'); 

/*
BEGIN
  EXECUTE IMMEDIATE 'lock table t_session_state in exclusive mode';
  EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error while  '
            || ' locking table -> t_session_state';
  ROLLBACK;
  RETURN;      
END;
*/

v_sql1 := 'SELECT table_name '
           || ' FROM tmp_seq_holder '; 

OPEN c1 FOR v_sql1;

LOOP
FETCH c1 into v_tab1;
EXIT WHEN c1 % NOTFOUND;

AddArchiveQueueProcessStatus(' locking table ' || UPPER(v_tab1) || ' in exclusive mode - started'); 

BEGIN
  
  EXECUTE IMMEDIATE('lock table ' || v_tab1 || ' in exclusive mode');
  EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error while  '
            || ' locking table -> ' || UPPER(v_tab1);
  ROLLBACK;
  CLOSE c1;
  RETURN;    
END;

AddArchiveQueueProcessStatus(' locking table ' || UPPER(v_tab1) || ' in exclusive mode - finished'); 

END LOOP;
CLOSE c1;

/*******************************************************************************/
/* END - LOOP ALL TABLES AND LOCK THEM in EXCLUSIVE MODE.*/
/*******************************************************************************/

/*******************************************************************************/
/* BEGIN - Move newly inserted records into old partition to avoid atomic data in two partitions*/
/*******************************************************************************/
v_sql1 := 'SELECT table_name, next_id  '
           || ' FROM tmp_seq_holder ';
OPEN c1 FOR  v_sql1;

AddArchiveQueueProcessStatus(' loop all tables and Move newly inserted records into old partition to avoid atomic data in two partitions- started'); 

LOOP   
FETCH c1   INTO v_tab1, l_partition_id;   

EXIT  WHEN c1 % NOTFOUND;  

AddArchiveQueueProcessStatus(' Move newly inserted records into old parition for table : ' || UPPER(v_tab1)  || ' - started'); 

BEGIN  
  dbms_output.put_line('l_partition_id is ' || TO_NUMBER(l_partition_id - 1));
  dbms_output.put_line('UPDATE ' || v_tab1 || ' SET id_partition = ' || TO_NUMBER(l_partition_id - 1)  || ' WHERE '
                    || ' id_partition = ' || TO_NUMBER(l_partition_id));
                    
  EXECUTE IMMEDIATE 'UPDATE ' || v_tab1 || ' SET id_partition = ' || TO_NUMBER(l_partition_id - 1)  || ' WHERE '
                    || ' id_partition = ' || TO_NUMBER(l_partition_id);

  EXCEPTION  WHEN others THEN   
  p_result := '7000006-archive_queues operation failed->Error in update '
            || 'operation for table -> ' || UPPER(v_tab1) || '. error msg : ' || SQLERRM;   
  ROLLBACK;
  CLOSE c1;   
  RETURN;  

END;

AddArchiveQueueProcessStatus(' Move newly inserted records into old parition for table : ' || UPPER(v_tab1)  || ' - finished'); 

END LOOP;  

CLOSE c1;  

AddArchiveQueueProcessStatus(' loop all tables and Move newly inserted records into old partition to avoid atomic data in two partitions - finished'); 

/*******************************************************************************/
/* END - Move newly inserted records into old partition to avoid atomic data in two partitions*/
/*******************************************************************************/

/* below procedure will create temp table (tmp_non_archive_data), populate
id_source_sess to preserve and create index for performance.*/
BEGIN
  AddArchiveQueueProcessStatus(' call GetNonArchiveRecords with params session_next_part_id ' || cast(l_t_session_next_part_id as varchar) || ' and session_state_next_part_id ' || l_t_session_state_next_part_id || ' - started'); 
  
  GetNonArchiveRecords(l_t_session_next_part_id, l_t_session_state_next_part_id);
  EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error in '
            || '  getNonArchiveRecrods ' || SQLERRM;
  ROLLBACK;
  RETURN;    
END;
AddArchiveQueueProcessStatus(' call GetNonArchiveRecords - finished'); 


/*******************************************************************************/
/* BEGIN - LOOP ALL TABLES AND UPDATE PRESERVE RECORD TO NEXT PARTITION ID*/
/*******************************************************************************/
v_sql1 := 'SELECT table_name, next_id  '
           || ' FROM tmp_seq_holder where table_name like ''t_svc%''';
           
OPEN c1 FOR  v_sql1;

LOOP   
FETCH c1   INTO v_tab1, l_partition_id;   

EXIT  WHEN c1 % NOTFOUND;  

AddArchiveQueueProcessStatus(' loop all tables and update preserve record to next partition id - started'); 

AddArchiveQueueProcessStatus(' update preserve record to next partition id for table ' || UPPER(v_tab1)  || ' - started'); 

BEGIN  
  
  EXECUTE IMMEDIATE 'UPDATE ' || v_tab1 || ' SET ID_PARTITION = ' || l_partition_id || ' WHERE '
                    || ' ID_PARTITION < ' || l_partition_id || ' and id_source_sess in (select id_source_sess from tmp_non_archive_data)';

  EXCEPTION  WHEN others THEN   
  p_result := '7000006-archive_queues operation failed->Error in t_svc update '
            || 'operation for table -> ' || UPPER(v_tab1) || '. error msg : ' || SQLERRM;   
  ROLLBACK;
  CLOSE c1;   
  RETURN;  

END;

AddArchiveQueueProcessStatus(' update preserve record to next partition id for table ' || UPPER(v_tab1)  || ' - finished'); 

BEGIN

  INSERT   INTO t_archive_queue(id_svc,   status,   tt_start,   tt_end)   VALUES(v_tab1,   'A',   v_vartime,   v_maxtime);  
  
  EXCEPTION  WHEN others THEN   
  p_result := '7000006-archive_queues operation failed->Error while inserting '
            || 'records into t_archive_queue for table -> ' || UPPER(v_tab1);   
  ROLLBACK;
  CLOSE c1;   
  RETURN;   
END;   

END LOOP;  

CLOSE c1;  

AddArchiveQueueProcessStatus(' loop all tables and update preserve record to next partition id - finished'); 

/*******************************************************************************/
/* END - LOOP ALL TABLES AND UPDATE PRESERVE RECORD TO NEXT PARTITION ID*/
/*******************************************************************************/


AddArchiveQueueProcessStatus(' update preserve record to next partition id for table t_session - started'); 

BEGIN
  EXECUTE IMMEDIATE 'SELECT next_id from tmp_seq_holder where UPPER(table_name) = ''T_SESSION''' into l_t_session_next_part_id;
  EXCEPTION WHEN OTHERS THEN
    p_result := '7000006-archive_queues operation failed->cannot fetch next_id from tmp_seq_holder for table t_session.' || SQLERRM;   
    ROLLBACK;
    RETURN; 
END;
/* Move preserve data to new partition in t_session*/
BEGIN
  EXECUTE IMMEDIATE 'UPDATE t_session '
                  || ' SET ID_PARTITION = ' || l_t_session_next_part_id
                  || 'WHERE id_source_sess in (select id_source_sess from tmp_non_archive_data) '
                  || 'AND ID_PARTITION < ' || l_t_session_next_part_id;
                  
  /*EXECUTE IMMEDIATE 'insert into t_session_ts select * from t_session where ID_PARTITION < ' || l_t_session_next_part_id;*/
  
EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error in t_session update operation' || SQLERRM;   
  ROLLBACK;
  RETURN; 
END;
AddArchiveQueueProcessStatus(' update preserve record to next partition id for table t_session - finished'); 

/* Move preserve data to new partition in t_session_set*/
AddArchiveQueueProcessStatus(' update preserve record to next partition id for table t_session_set - started'); 


BEGIN
  EXECUTE IMMEDIATE 'SELECT next_id from tmp_seq_holder where UPPER(table_name) = ''T_SESSION_SET''' into l_t_session_set_next_part_id;
  EXCEPTION WHEN OTHERS THEN
    p_result := '7000006-archive_queues operation failed->cannot fetch next_id from tmp_seq_holder for table t_session_set.' || SQLERRM;   
    ROLLBACK;
    RETURN; 
END;

BEGIN  
  EXECUTE IMMEDIATE 'UPDATE t_session_set '
                 || 'SET ID_PARTITION = ' || l_t_session_set_next_part_id 
                 || '  WHERE id_ss IN (SELECT id_ss '
                 || '                  FROM t_session '
                 || '                  WHERE ID_PARTITION = ' || l_t_session_next_part_id || ') '
                 || ' AND ID_PARTITION < ' || l_t_session_set_next_part_id;
                 
  /* EXECUTE IMMEDIATE 'insert into t_session_set_ts  select s.* from t_session_set s where s.ID_PARTITION < ' || l_t_session_set_next_part_id; */                
  
EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error in t_session_set update operation';   
  ROLLBACK;
  RETURN; 
END;
AddArchiveQueueProcessStatus(' update preserve record to next partition id for table t_session_set - finished'); 

/* Move preserve data to new partition in t_message*/
AddArchiveQueueProcessStatus(' update preserve record to next partition id for table t_message - started'); 

BEGIN
  EXECUTE IMMEDIATE 'SELECT next_id from tmp_seq_holder where UPPER(table_name) = ''T_MESSAGE''' into l_t_message_next_part_id;
  EXCEPTION WHEN OTHERS THEN
    p_result := '7000006-archive_queues operation failed->cannot fetch next_id from tmp_seq_holder for table t_message.' || SQLERRM;   
    ROLLBACK;
    RETURN; 
END;

BEGIN  
  EXECUTE IMMEDIATE 'UPDATE t_message '
                 || 'SET ID_PARTITION = ' || l_t_message_next_part_id
                 || ' WHERE id_message IN (SELECT id_message '
                 || '                      FROM t_session_set '
                 || '                      WHERE ID_PARTITION = ' || l_t_session_set_next_part_id || ') '
                 || ' AND ID_PARTITION < ' || l_t_message_next_part_id;

  /* EXECUTE IMMEDIATE 'insert into t_message_ts  select s.* from t_message s where s.ID_PARTITION < ' || l_t_message_next_part_id; */

  EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error in t_message update operation. error ->' || SQLERRM;   
  ROLLBACK;
  RETURN; 
END;
AddArchiveQueueProcessStatus(' update preserve record to next partition id for table t_message - finished'); 

/* Move preserve data to new partition in t_session_state*/
AddArchiveQueueProcessStatus(' update preserve record to next partition id for table t_session_state - started'); 

BEGIN
  EXECUTE IMMEDIATE 'SELECT next_id from tmp_seq_holder where UPPER(table_name) = ''T_SESSION_STATE''' into l_t_session_state_next_part_id;
  
  EXCEPTION WHEN OTHERS THEN
    p_result := '7000006-archive_queues operation failed->cannot fetch next_id from tmp_seq_holder for table T_SESSION_STATE.' || SQLERRM;   
    ROLLBACK;
    RETURN; 
END;

BEGIN
  EXECUTE IMMEDIATE 'UPDATE t_session_state '
                  || 'SET ID_PARTITION = ' || l_t_session_state_next_part_id
                  || 'WHERE id_sess in (select id_source_sess from t_session where ID_PARTITION = ' || l_t_session_next_part_id || ') '
                  || 'AND ID_PARTITION < ' || l_t_session_state_next_part_id;
  
  /*EXECUTE IMMEDIATE 'insert into t_session_State_ts select s.* from t_session_state s where ID_PARTITION < ' || l_t_session_state_next_part_id; */
  
  EXCEPTION WHEN OTHERS THEN
  p_result := '7000006-archive_queues operation failed->Error in t_session_state update operation';   
  ROLLBACK;
  CLOSE c1;   
  RETURN; 
END;
AddArchiveQueueProcessStatus(' update preserve record to next partition id for table t_session_state - finished'); 


/* drop temporary table */
/*
IF table_exists('tmp_non_archive_data') THEN   
  BEGIN
    EXECUTE IMMEDIATE 'drop table tmp_non_archive_data';  
    EXCEPTION WHEN OTHERS THEN
    p_result := '7000006-archive_queues operation failed->Error while dropping temp table tmp_non_archive_data';   
    ROLLBACK;
    CLOSE c1;   
    RETURN; 
  END;
END IF;  

AddArchiveQueueProcessStatus(' dropped temp table tmp_non_archive_data'); 
*/
/* drop temporary table */
/*
IF table_exists('tmp_seq_holder') THEN   
  BEGIN
    EXECUTE IMMEDIATE 'drop table tmp_seq_holder';  
    EXCEPTION WHEN OTHERS THEN
    p_result := '7000006-archive_queues operation failed->Error while dropping temp table tmp_seq_holder';   
    ROLLBACK;
    CLOSE c1;   
    RETURN; 
  END;
END IF;  

AddArchiveQueueProcessStatus(' dropped temp table tmp_seq_holder'); 
*/
/*******************************************************************************/
/* BEGIN - LOOP ALL TABLES AND REMOVE UNWANTED PARTITIONS
/*******************************************************************************/
AddArchiveQueueProcessStatus(' Loop all tables and remove old partitions - started'); 
v_sql1 := 'SELECT table_name, next_id  '
           || ' FROM tmp_seq_holder ';
           
OPEN c1 FOR   v_sql1;

LOOP    
FETCH c1     INTO v_tab1, l_partition_id;    
EXIT   WHEN c1 % NOTFOUND;   

BEGIN
    
    /* LOOP THOROUGH EACH PARTITION AND DROP THEM*/
    AddArchiveQueueProcessStatus(' Looping partitions for table ' || UPPER(v_tab1) || ' to drop partition.'); 
    v_sql1 := 'select partition_name '
      || ' from user_tab_partitions '
      || ' where table_name = UPPER(''' || v_tab1 || ''')'
      || ' and PARTITION_NAME <>  UPPER(''P' ||  cast(l_partition_id as varchar) || ''')';
      
    DBMS_OUTPUT.PUT_LINE(v_tab1);  
    
    OPEN c2 FOR v_sql1;

    LOOP
    FETCH c2 INTO l_partition_name;
    EXIT  WHEN c2 % NOTFOUND;
    
    
    BEGIN
      EXECUTE IMMEDIATE('lock table ' || v_tab1 || ' in exclusive mode');
      EXCEPTION WHEN OTHERS THEN
      p_result := '7000006-archive_queues operation failed->Error while  '
                || ' locking table -> ' || UPPER(v_tab1);
      ROLLBACK;
      CLOSE c2;
      CLOSE c1;
      RETURN;    
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER TABLE ' || v_tab1 || ' DROP PARTITION ' || l_partition_name ||' UPDATE INDEXES';
        EXCEPTION WHEN OTHERS THEN
        p_result := '7000006-archive_queues operation failed->Error while dropping partition for table ' || UPPER(v_tab1) || ' error : ' || SQLERRM;   
        ROLLBACK;
        CLOSE c2;   
        CLOSE c1;
        RETURN;        
    END;
    END LOOP;
    CLOSE C2;
    
END;
END LOOP;
CLOSE c1;  
AddArchiveQueueProcessStatus(' Loop all tables and remove old partitions - finished'); 
/*******************************************************************************/
/* END - LOOP ALL TABLES AND REMOVE UNWANTED PARTITIONS
/*******************************************************************************/

AddArchiveQueueProcessStatus(' update stats - started'); 

  IF(p_update_stats = 'Y') THEN
		SELECT sys_context('USERENV', 'SESSION_USER') into v_user_name FROM dual;
		OPEN c1 FOR
			SELECT nm_table_name
			FROM t_service_def_log;
			LOOP
			FETCH c1 INTO v_tab1;
			EXIT WHEN c1 % NOTFOUND;
      IF(p_sampling_ratio < 5) 
				THEN v_nu_varstatpercentchar := 5;
				ELSIF(p_sampling_ratio >= 100) THEN v_nu_varstatpercentchar := 100;
				ELSE v_nu_varstatpercentchar := p_sampling_ratio;
      END IF;
      AddArchiveQueueProcessStatus(' executing gather_table_stats for table -> ' || UPPER(v_tab1) ); 
			v_sql1 := 'begin dbms_stats.gather_table_stats(ownname=> ''' || v_user_name || ''',
                 tabname=> ''' || v_tab1 || ''', estimate_percent=> ' || v_nu_varstatpercentchar || ',
                 cascade=> TRUE); end;';
      BEGIN
	      EXECUTE IMMEDIATE v_sql1;
        EXCEPTION
        WHEN others THEN
					p_result := '7000022-archive_queues operation failed->Error in update stats';
					ROLLBACK;
					RETURN;
       END;
       END LOOP;
       CLOSE c1;
       
       AddArchiveQueueProcessStatus(' executing gather_table_stats for table t_session' ); 
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000023-archive_queues operation failed->Error in t_session update stats';
             ROLLBACK;
             RETURN;
       END;
       
       AddArchiveQueueProcessStatus(' executing gather_table_stats for table t_session_set' ); 
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION_SET'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000024-archive_queues operation failed->Error in t_session_set update stats';
             ROLLBACK;
             RETURN;
       END;
       
       AddArchiveQueueProcessStatus(' executing gather_table_stats for table t_session_state' ); 
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION_STATE'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000025-archive_queues operation failed->Error in t_session_state update stats';
             ROLLBACK;
             RETURN;
       END;
       
       AddArchiveQueueProcessStatus(' executing gather_table_stats for table t_message' ); 
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_MESSAGE'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000026-archive_queues operation failed->Error in t_message update stats';
             ROLLBACK;
             RETURN;
       END;
  END IF;

  p_result := '0-archive_queue operation successful';
  
  AddArchiveQueueProcessStatus(' update stats - completed'); 
  AddArchiveQueueProcessStatus('Archive Process - completed'); 
COMMIT;
END;

             