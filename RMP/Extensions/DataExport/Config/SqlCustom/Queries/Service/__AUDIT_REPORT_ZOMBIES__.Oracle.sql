
BEGIN
	
    IF table_exists('ZOMBIES') THEN
        EXECUTE IMMEDIATE 'INSERT INTO ZOMBIES
        SELECT *
        FROM   t_export_workqueue
        WHERE  c_current_process_stage IS NOT NULL';
    ELSE
        EXECUTE IMMEDIATE '
        CREATE GLOBAL TEMPORARY
        TABLE ZOMBIES
        ON COMMIT PRESERVE ROWS
        AS SELECT *
        FROM   t_export_workqueue
        WHERE  c_current_process_stage IS NOT NULL';
    END IF;

	EXECUTE IMMEDIATE '
	INSERT INTO t_export_execute_audit
	  (
		id_work_queue,
		id_rep,
		id_rep_instance_id,
		id_schedule,
		c_sch_type,
		dt_queued,
		dt_sched_run,
		c_use_database,
		c_rep_title,
		c_rep_type,
		c_rep_def_source,		
		c_rep_query_tag,
		c_rep_output_type,		
		c_rep_distrib_type,
		c_rep_destn,
		c_destn_access_user,
		c_use_quoted_identifiers,
		c_generate_control_file,
		c_control_file_delivery_locati,
		c_output_execute_params_info,
		c_exec_type,
		c_compressreport,
		c_compressthreshold,
		c_ds_id,
		c_eop_step_instance_name,
		c_processed_server,
		id_run,
		run_start_dt,
		run_end_dt,
		c_run_result_status,
		c_run_result_descr,
		c_execute_paraminfo,
		c_queuerow_source,
		c_output_file_name
	  )
	SELECT id_work_queue,
		   id_rep,
		   id_rep_instance_id,
		   id_schedule,
		   c_sch_type,
		   dt_queued,
		   dt_sched_run,
		   CASE 
				WHEN c_use_database IS NULL THEN ''(local)''
                else c_use_database
		   END,
		   c_rep_title,
		   c_rep_type,
		   c_rep_def_source,		   
		   c_rep_query_tag,
		   c_rep_output_type,		   
		   c_rep_distrib_type,
		   c_rep_destn,
		   c_destn_access_user,
		   c_use_quoted_identifiers,
		   c_generate_control_file,
		   c_control_file_delivery_locati,
		   c_output_execute_params_info,
		   c_exec_type,
		   c_compressreport,
		   c_compressthreshold,
		   c_ds_id,
		   c_eop_step_instance_name,
		   c_processing_server,
		   id_run,
		   dt_queued,
		   dt_queued,
		   ''ZOMBIE'',
		   ''This report was on the workqueue when the XRep service was started. Confirm it did not complete and run again if required.'',
		   CASE 
				WHEN c_param_name_values IS NULL THEN ''''
				ELSE c_param_name_values
		   END,
		   c_queuerow_source,
		   c_output_file_name
	FROM ZOMBIES';

	EXECUTE IMMEDIATE 'DELETE FROM t_export_workqueue WHERE id_work_queue IN (SELECT id_work_queue FROM ZOMBIES)';

END;
	