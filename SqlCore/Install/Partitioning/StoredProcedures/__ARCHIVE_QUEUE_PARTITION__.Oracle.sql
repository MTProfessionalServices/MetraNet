CREATE OR REPLACE
PROCEDURE archive_queue_partition(
    p_update_stats		VARCHAR2 DEFAULT 'N',
    p_sampling_ratio	VARCHAR2 DEFAULT '30',
    p_current_time		DATE DEFAULT NULL,
    p_result		OUT VARCHAR2
)
AUTHID CURRENT_USER
AS
    /* This SP is called from from basic SP - [archive_queue] if DB is partitioned */

    /*
    How to run this stored procedure:   
	DECLARE
		v_result VARCHAR2(2000);
	BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
		archive_queue_partition ( p_result => v_result );
		DBMS_OUTPUT.put_line (v_result);
	END;
    
    Or if we want to update statistics and change current date/time also:   
    DECLARE 
        v_result            VARCHAR2(2000),
        v_current_time  DATE
    BEGIN
        v_current_time := SYSDATE;
        archive_queue_partition (
             p_update_stats => 'Y',
             p_sampling_ratio => 30,
             p_current_time => v_current_time,
             p_result => v_result
             );
        DBMS_OUTPUT.put_line (v_result);
    END;
    */
    
    v_is_part_enabled			VARCHAR2(1);
    v_current_time				DATE;
    v_next_allow_run_time		DATE;
    v_current_id_partition		INT;
    v_new_current_id_partition	INT;
    v_old_id_partition			INT;
    v_no_need_to_run			INT;
    v_meter_tablespace_name		VARCHAR2(50);
    v_count_records				INT;
	v_time_count				NUMBER;
	
BEGIN   
    
    /* Force using single processor's core */
	EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DDL';
	EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
	EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL QUERY';
	
    SELECT UPPER(b_partitioning_enabled) INTO v_is_part_enabled FROM t_usage_server;
    /* Nothing to do if system isn't enabled for partitioning */
    IF v_is_part_enabled <> 'Y' THEN 
        dbms_output.put_line('Partitioning is not enabled, so can not execute archive_queue_partition sp.');
        RETURN;
    END IF;
    
    DBMS_OUTPUT.put_line ('Starting archive queue process for partitioned Meter tables ');
    
    IF p_current_time IS NULL THEN
         v_current_time := SYSDATE;
    ELSE
         v_current_time := p_current_time;
    END IF;
    
    arch_q_p_get_status(
		p_current_time => v_current_time,
		p_next_allow_run_time => v_next_allow_run_time,
		p_current_id_partition => v_current_id_partition,
		p_new_current_id_partition  => v_new_current_id_partition,
		p_old_id_partition => v_old_id_partition,
		p_no_need_to_run => v_no_need_to_run );
    
    IF v_no_need_to_run = 1 THEN
        dbms_output.put_line('No need to run archive operation.');
        RETURN;
    END IF;
    
    IF v_next_allow_run_time IS NULL THEN
         dbms_output.put_line('Partition Schema and Default "id_partition" had already been updated. Skipping this step...');
    ELSE
        v_meter_tablespace_name := prtn_GetMeterPartFileGroupName();

        arch_q_p_apply_next_partition(
            p_new_current_id_partition => v_new_current_id_partition,
            p_current_time => v_current_time,
            p_meter_tablespace_name => v_meter_tablespace_name,
            p_meter_partition_field_name =>  'id_partition' );
	END IF;
	
	/* If it is the 1-st time of running [archive_queue_partition] there are only 2 partitions.
	* It is early to archive data.
	* When 3-rd partition is created the oldest one is archiving.
	* So, meter tables always have 2 partition.*/
	SELECT COUNT(current_id_partition)
	INTO v_count_records
	FROM   t_archive_queue_partition;

	IF ( v_count_records  > 2 ) THEN      

		/* Append temp table tt_id_sess_to_keep with IDs of sessions from the 'oldest' partition that should not be archived */
		arch_q_p_get_id_sess_to_keep( p_old_id_partition => v_old_id_partition );

		arch_q_p_prep_all_keep_ses_tab( p_old_id_partition => v_old_id_partition );
		
		BEGIN
      DBMS_OUTPUT.ENABLE(1000000);
			dbms_output.put_line('Pausing pipeline...');
			v_time_count := dbms_utility.get_time;
			PausePipelineProcessing( p_state => 1 );
			dbms_output.put_line('Pipeline was paused after ' || ((dbms_utility.get_time-v_time_count)/100) || ' seconds.');
			v_time_count := dbms_utility.get_time;

			/* Switch out old data, switch in preserved sessions for alll Meter tables. */
			arch_q_p_switch_out_part_all( p_old_id_partition => v_old_id_partition );

			PausePipelineProcessing( p_state => 0 );
			dbms_output.put_line('Pipeline was resumed after ' || ((dbms_utility.get_time-v_time_count)/100) || ' seconds.');
		EXCEPTION
		  WHEN OTHERS THEN
			PausePipelineProcessing( p_state => 0);
			dbms_output.put_line('Pipeline was resumed after exception! "Paused" period: ' || ((dbms_utility.get_time-v_time_count)/100) || ' seconds.');
			RAISE;
		END;

		/* Drop all old data of Meter tables. */
		arch_q_p_drop_temp_tables( p_old_id_partition => v_old_id_partition );

		/*	Rebuild GLOBAL indexes, that became UNUSABLE after EXCHANGE PARTITION operation.
			They can appear if unique constraint was added to any Service Definition*/
		dbms_output.put_line('Check for UNUSABLE indexes...');
		FOR x IN (  SELECT INDEX_NAME
					FROM   USER_INDEXES
					WHERE  TABLE_NAME IN (	SELECT UPPER(nm_table_name)
											FROM   t_service_def_log)
						AND STATUS = 'UNUSABLE' )
		LOOP
			dbms_output.put_line('Rebuilding UNUSABLE index: "' || x.INDEX_NAME || '"');
			EXECUTE IMMEDIATE 'ALTER INDEX ' || x.INDEX_NAME || ' REBUILD ONLINE';
		END LOOP;

		BEGIN	
			EXECUTE IMMEDIATE 'DROP TABLE tt_tab_names_with_sess_to_keep';
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -942 THEN
				RAISE;
			END IF;
		END;

		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE tt_id_sess_to_keep';
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -942 THEN
				RAISE;
			END IF;
		END;

	END IF;

	/* Update next_allow_run value in [t_archive_queue_partition] table.
	* This is an indicator of successful archivation*/
	prtn_get_next_allow_run_date(
			current_datetime => v_current_time,
			next_allow_run_date => v_next_allow_run_time );

	UPDATE t_archive_queue_partition
	SET next_allow_run = v_next_allow_run_time
	WHERE current_id_partition = v_new_current_id_partition;

	COMMIT;

/* [TBD] Remove specification of sampling_ratio for update stats.
5 and 1 % can be hardly too big percent for some meter table and for some - very small */

/* Use the same update stats approach as in archive_queue_nonpartition */

  IF(p_update_stats = 'Y') THEN
  dbms_output.put_line(' update stats - started'); 
  
  DECLARE
	v_nu_varstatpercentchar	INT;
	v_tab1					VARCHAR2 (30);
	v_user_name				VARCHAR2 (30);
	v_sql1					VARCHAR2 (4000);
	c1						sys_refcursor;
  BEGIN
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
      dbms_output.put_line(' executing gather_table_stats for table -> ' || UPPER(v_tab1) ); 
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
       
       dbms_output.put_line(' executing gather_table_stats for table t_session' ); 
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
       
       dbms_output.put_line(' executing gather_table_stats for table t_session_set' ); 
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
       
       dbms_output.put_line(' executing gather_table_stats for table t_session_state' ); 
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
       
       dbms_output.put_line(' executing gather_table_stats for table t_message' ); 
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
  END;
  
  dbms_output.put_line(' update stats - completed'); 
  END IF;

	dbms_output.put_line('Archive Process - completed'); 
    p_result := '0-archive_queue_partition operation successful';
END;
