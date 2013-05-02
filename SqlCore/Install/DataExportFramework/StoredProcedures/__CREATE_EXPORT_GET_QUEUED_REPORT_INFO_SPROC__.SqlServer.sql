
      CREATE PROCEDURE [dbo].[Export_GetQueuedReportInfo]
      @id_work_queue	CHAR(36),
      @system_datetime DATETIME
      AS
      BEGIN
	      SET NOCOUNT ON

	      SELECT	c_rep_title, c_rep_type, c_rep_def_source, c_rep_query_source, c_rep_query_tag,  
			      lower(c_rep_output_type) AS 'c_rep_output_type', c_rep_distrib_type, c_rep_destn, 
			      ISNULL(c_destn_direct, 0) AS 'c_destn_direct', c_destn_access_user, c_destn_access_pwd, 
			      c_generate_control_file, c_control_file_delivery_location AS 'c_control_file_delivery_locati', c_exec_type, c_compressreport, 
			      ISNULL(c_compressthreshold, -1) as [c_compressthreshold], ISNULL(c_ds_id, 0) as 'c_ds_id', c_eop_step_instance_name,	
			      dt_last_run, dt_next_run, c_output_execute_params_info, c_use_quoted_identifiers,
			      id_rep_instance_id, id_schedule, c_sch_type, dt_sched_run, replace(c_param_name_values,'%','^') as 'c_param_name_values' , c_xmlconfig_loc, 
			      c_output_file_name, id_work_queue, dt_queued,  
			      CONVERT(VARCHAR(10), DATEADD(DAY, -1, ISNULL(dt_next_run, @system_datetime)), 101) as control_file_data_date
	      INTO #QueuedReportInfo	
	      FROM t_export_workqueue A with (nolock)
	      WHERE id_work_queue = @id_work_queue

	      /* Update the EOP rows to set the proper control_file_data_date */
	      UPDATE #QueuedReportInfo
		      SET control_file_data_date = CONVERT(VARCHAR(10), DATEADD(DAY, 1, ISNULL(dt_end, @system_datetime)), 101)
	      FROM #QueuedReportInfo QRI
	      LEFT OUTER JOIN t_usage_interval UI on convert(int, substring(QRI.c_param_name_values, charindex('^^ID_INTERVAL^^', QRI.c_param_name_values, 1) + 16, 5)) = UI.id_interval
	      WHERE id_work_queue IN (SELECT id_work_queue
				      FROM #QueuedReportInfo
				      WHERE c_exec_type = 'eop'
				      AND c_param_name_values LIKE '%ID_INTERVAL%')	

        	UPDATE #QueuedReportInfo
        	SET c_param_name_values = replace(c_param_name_values,'^','%')
        	FROM #QueuedReportInfo

	      /* Now return the data to Export */
	      SELECT * 
	      FROM #QueuedReportInfo	
	      ORDER BY dt_queued	
      END
	 
	 