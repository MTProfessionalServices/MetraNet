
CREATE   PROCEDURE [dbo].[Export_QueueScheduledReports]
@RunId 	INT,
@system_datetime DATETIME
AS

	DECLARE @Warning_Results int

	SET NOCOUNT ON
	
	DECLARE @id_rep INT, @id_rep_instance_id INT, @id_schedule INT, @c_sch_type VARCHAR(10), @dt_queued DATETIME, @dt_next_run DATETIME, 
			@c_current_process_stage INT, @c_processing_server VARCHAR(50), @dt_last_run DATETIME,
			@c_report_title VARCHAR(50), @c_rep_type VARCHAR(10), @c_rep_def_source VARCHAR(100), 
			@c_rep_query_tag VARCHAR(50), @c_rep_output_type VARCHAR(10), 
			@c_rep_distrib_type VARCHAR(10), @c_report_destn VARCHAR(255), 
			@c_destn_direct BIT, @c_access_user VARCHAR(50), @c_access_pwd VARCHAR(2048), 
			@ds_id INT, @eopinstancename NVARCHAR(510), @outputExecuteParamInfo BIT, @outputFileName varchar(50),
			@generatecontrolfile BIT, @controlfiledeliverylocation VARCHAR(255), @compressreport BIT, 
			@compressthreshold INT, @param_name_values VARCHAR(1000), @UseQuotedIdentifiers BIT, 
			@IntervalId INT

	/* Get the interval id using the report's current start date. */
	
	CREATE TABLE #tparamInfo (id_rep INT, id_rep_instance_id INT, c_param_name_value VARCHAR(500))
	INSERT INTO #tparamInfo
	SELECT		distinct trpi.id_rep, trpi.id_rep_instance_id, tpn.c_param_name+'='+ 
				ISNULL(CASE replace(tpn.c_param_name,'%','')
					WHEN 'START_DATE' THEN ISNULL(convert(VARCHAR(19), trpi.dt_last_run, 121), tdfp.c_param_value)
					WHEN 'START_DT' THEN ISNULL(convert(VARCHAR(19), trpi.dt_last_run, 121), tdfp.c_param_value)
					WHEN 'END_DATE' THEN ISNULL(convert(VARCHAR(19), trpi.dt_next_run, 121), tdfp.c_param_value)
					WHEN 'END_DT' THEN ISNULL(convert(VARCHAR(19), trpi.dt_next_run, 121), tdfp.c_param_value)
					/* 
					WHEN 'ID_INTERVAL' THEN 
							(SELECT CAST(id_interval as varchar) from t_usage_interval 
								where MONTH(dt_start) = MONTH(ISNULL(trpi.dt_last_run, tdfp.c_param_value))
								and YEAR(dt_start) = YEAR(ISNULL(trpi.dt_last_run, tdfp.c_param_value))
								and DAY(dt_start) = 1)
					*/
					ELSE tdfp.c_param_value
				END, 'NULL') as 'c_param_value'
	FROM			t_export_param_names tpn 
	INNER JOIN		t_export_report_params trpm ON tpn.id_param_name = trpm.id_param_name 
	INNER JOIN		t_export_report_instance trpi ON trpm.id_rep = trpi.id_rep 
	LEFT OUTER JOIN	t_export_default_param_values tdfp ON trpi.id_rep_instance_id = tdfp.id_rep_instance_id 
				AND trpm.id_param_name = tdfp.id_param_name
	/* SELECT * FROM #tparamInfo */

	SET NOCOUNT OFF	
	DECLARE c_reports CURSOR FOR
	SELECT	trpi.id_rep, trps.id_rep_instance_id, trps.id_schedule, trps.c_sch_type, @system_datetime AS dt_Queued, trpi.dt_next_run, 
			trp.c_report_title, trp.c_rep_type, trp.c_rep_def_source,
			trp.c_rep_query_tag, trpi.c_rep_output_type, trpi.c_rep_distrib_type, trpi.c_report_destn, 
			trpi.c_destn_direct, trpi.c_access_user, trpi.c_access_pwd, trpi.c_ds_id, trpi.c_eop_step_instance_name, 
			trpi.c_generate_control_file, trpi.c_control_file_delivery_location, trpi.c_output_execute_params_info,
			trpi.c_use_quoted_identifiers, trpi.c_compressreport, trpi.c_compressthreshold, trpi.dt_last_run, trpi.c_output_file_name
	FROM	t_export_schedule trps 
	INNER JOIN	t_export_report_instance trpi ON trps.id_rep_instance_id = trpi.id_rep_instance_id 
	INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep
	WHERE		trpi.c_exec_type = 'Scheduled'
	AND		(trpi.dt_next_run <= @system_datetime OR trpi.dt_next_run IS NULL)
	AND		trpi.dt_activate <= @system_datetime
	AND   (trpi.dt_deactivate >= @system_datetime OR trpi.dt_deactivate IS NULL)
	
	OPEN c_reports
	FETCH NEXT FROM c_reports INTO
	@id_rep, @id_rep_instance_id, @id_schedule, @c_sch_type, @dt_queued, @dt_next_run, 
	@c_report_title, @c_rep_type, @c_rep_def_source, 
	@c_rep_query_tag, @c_rep_output_type, @c_rep_distrib_type, @c_report_destn, 
	@c_destn_direct, @c_access_user, @c_access_pwd, @ds_id, @eopinstancename, 
	@generatecontrolfile, @controlfiledeliverylocation, @outputExecuteParamInfo,
	@UseQuotedIdentifiers, @compressreport, @compressthreshold, @dt_last_run, @outputFileName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @param_name_values = COALESCE(@param_name_values + ',', '') + c_param_name_value
		FROM #tparamInfo
		WHERE id_rep = @id_rep and id_rep_instance_id = @id_rep_instance_id
		
		IF NOT EXISTS (SELECT * FROM t_export_workqueue 
			WHERE	id_rep_instance_id	= @id_rep_instance_id
			AND		id_rep					= @id_rep
			AND		c_sch_type			= @c_sch_type
			AND		c_exec_type			= 'sch'
			AND		dt_next_run			= @dt_next_run
			AND		dt_last_run			= @dt_last_run
			AND		ISNULL(c_ds_id, '')	= ISNULL(@ds_id, '')
			AND		dt_sched_run		= @dt_next_run)
		BEGIN

			/*  check if scheduled jobs can run for the next run date specified
			IF EXISTS (select * from netmeter_custom..t_process_control_detail 
									where id_control = 3 and id_control_date >= CONVERT(VARCHAR, @dt_next_run, 101))
				BEGIN				
					This checks for any extra conditions that must be met before a given scheduled report can run. */

					EXEC @Warning_Results = export_QueueReportChecks 'Scheduled', @id_rep, @id_rep_instance_id, @system_datetime
					PRINT 'WARNINGS - ' + convert(varchar, @id_rep_instance_id) + ' ' + convert(varchar, @Warning_Results)
					IF @Warning_Results = 0
						INSERT INTO t_export_workqueue(id_rep_instance_id, id_rep, id_schedule, c_sch_type, dt_queued, dt_sched_run, 
								c_rep_title, c_rep_type, c_rep_def_source, 
								c_rep_query_tag, c_rep_output_type, c_rep_distrib_type, c_rep_destn, 
								c_destn_direct, c_destn_access_user, c_destn_access_pwd, c_ds_id, c_eop_step_instance_name, 
								c_generate_control_file, c_control_file_delivery_location, c_output_execute_params_info,
								c_use_quoted_identifiers, c_compressreport, c_compressthreshold, c_exec_type, 
								dt_last_run, dt_next_run, c_current_process_stage, c_param_name_values, id_run, c_queuerow_source, c_output_file_name)
						VALUES (@id_rep_instance_id, @id_rep, @id_schedule, @c_sch_type, @dt_queued, @dt_next_run, 
								@c_report_title, @c_rep_type, @c_rep_def_source, 
								@c_rep_query_tag, @c_rep_output_type, @c_rep_distrib_type, @c_report_destn, 
								@c_destn_direct, @c_access_user, @c_access_pwd, @ds_id, @eopinstancename, 
								@generatecontrolfile, @controlfiledeliverylocation, @outputExecuteParamInfo,
								@UseQuotedIdentifiers, @compressreport, @compressthreshold, 'sch', 
								@dt_last_run, @dt_next_run, 0, @param_name_values, @RunId, CAST(@RunID AS VARCHAR), @outputFileName)
			/* END */	
		END
		SET @param_name_values = NULL
		FETCH NEXT FROM c_reports INTO
		@id_rep, @id_rep_instance_id, @id_schedule, @c_sch_type, @dt_queued, @dt_next_run, 
		@c_report_title, @c_rep_type, @c_rep_def_source,
		@c_rep_query_tag, @c_rep_output_type, @c_rep_distrib_type, @c_report_destn, 
		@c_destn_direct, @c_access_user, @c_access_pwd, @ds_id, @eopinstancename, 
		@generatecontrolfile, @controlfiledeliverylocation, @outputExecuteParamInfo,
		@UseQuotedIdentifiers, @compressreport, @compressthreshold, @dt_last_run, @outputFileName
	END

CLOSE c_reports
DEALLOCATE c_reports

DROP TABLE #tparamInfo
	 