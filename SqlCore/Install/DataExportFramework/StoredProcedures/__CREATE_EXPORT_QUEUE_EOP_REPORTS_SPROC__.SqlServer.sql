
      CREATE PROCEDURE Export_QueueEOPReports
      @eopInstanceName	NVARCHAR(510),
      @intervalId			INT,
      @id_billgroup		INT,  /* Added the billgroup, but we have to agree on how this will be used..... */
      @runId				INT,
	  @system_datetime DATETIME
      AS
      BEGIN
      SET NOCOUNT ON
	      DECLARE @param_name_values VARCHAR(1000), @wkId UNIQUEIDENTIFIER, 
			      @prmval VARCHAR(500), @id_rep INT, @id_rep_inst INT, @old_id_rep INT, 
			      @old_id_rep_inst INT, @prm_stor varchar(1000)
	
	      DECLARE @idQs TABLE (idq UNIQUEIDENTIFIER)

	      DECLARE @tprmVals TABLE (id_rep INT, id_report_instance_id INT, c_param_name_values VARCHAR(1000))
	      INSERT INTO @tprmVals
		  SELECT   trp.id_rep, trpi.id_rep_instance_id, tpn.c_param_name+'='+ 
				      ISNULL(CASE replace(tpn.c_param_name,'%','')
					      WHEN 'ID_INTERVAL' THEN +ISNULL(CAST(@intervalId AS VARCHAR), '')
					      WHEN 'ID_BILLGROUP' THEN +ISNULL(CAST(@id_billgroup AS VARCHAR), '')
					      ELSE tdfp.c_param_value
				      END, '') 
	      FROM	t_export_reports trp
	      LEFT  JOIN t_export_report_instance trpi ON trp.id_rep = trpi.id_rep
	      LEFT JOIN t_export_default_param_values tdfp 
	      INNER JOIN t_export_param_names tpn ON tdfp.id_param_name = tpn.id_param_name
	      INNER JOIN t_export_report_params trpm ON tpn.id_param_name = trpm.id_param_name ON  trpi.id_rep_instance_id = tdfp.id_rep_instance_id
	      WHERE trpi.c_eop_step_instance_name = @eopInstanceName 

	      SET @prm_stor = ''
	
	      DECLARE cr_prms CURSOR FOR 
	      SELECT	c_param_name_values, id_rep, id_report_instance_id 
	      FROM	@tprmVals 
	      GROUP BY id_rep, id_report_instance_id, c_param_name_values 
	      ORDER BY id_report_instance_id
	      /* The GROUP BY and ORDER BY above are important - thats how we can get the parameter list in the correct
	      order and this create the parameter name-value list when this gets dropped on the queue */

	      OPEN cr_prms
	      FETCH NEXT FROM cr_prms INTO @prmval, @id_rep, @id_rep_inst
	      SELECT	@old_id_rep			= @id_rep, 
			      @old_id_rep_inst	= @id_rep_inst, 
			      @prm_stor			= ''
	      WHILE @@fetch_status = 0
	      BEGIN 
		      IF @old_id_rep <> @id_rep OR @old_id_rep_inst <> @id_rep_inst
		      BEGIN
			      /* do an insert into the queue here - one set of param-name values has been generated for this
			      reportid/reportinstanceid combination
			      Remove the last "," from the value of @prm_stor */
			      SET @wkid = NEWID()
			      INSERT INTO t_export_workqueue(id_work_queue, id_rep, id_rep_instance_id, id_schedule, c_sch_type, dt_queued, dt_sched_run, 
					      c_rep_title, c_rep_type, c_rep_def_source, 
					      c_rep_query_tag, c_rep_output_type, c_rep_distrib_type, c_rep_destn, 
					      c_destn_direct, c_destn_access_user, c_destn_access_pwd, c_ds_id, c_eop_step_instance_name, 
					      c_generate_control_file, c_control_file_delivery_location, c_output_execute_params_info,
					      c_compressreport, c_compressthreshold, c_exec_type, c_use_quoted_identifiers, 
					      dt_last_run, dt_next_run, c_current_process_stage, c_param_name_values, id_run, c_queuerow_source, c_output_file_name)
			      SELECT	@wkid, trpi.id_rep, trpi.id_rep_instance_id, NULL as 'id_schedule', NULL as 'c_sch_type', @system_datetime AS dt_Queued, @system_datetime AS dt_sched_run, 
					      trp.c_report_title, trp.c_rep_type,trp.c_rep_def_source,
					      trp.c_rep_query_tag, trpi.c_rep_output_type, trpi.c_rep_distrib_type, trpi.c_report_destn, 
					      trpi.c_destn_direct, trpi.c_access_user, trpi.c_access_pwd, trpi.c_ds_id, trpi.c_eop_step_instance_name, 
					      trpi.c_generate_control_file, trpi.c_control_file_delivery_location, trpi.c_output_execute_params_info,
					      trpi.c_compressreport, trpi.c_compressthreshold, 'eop', trpi.c_use_quoted_identifiers, 
					      trpi.dt_last_run, @system_datetime, 0, SUBSTRING(@prm_stor, 1, LEN(@prm_stor) - 1), @runid, 'EOP ADAPTER', trpi.c_output_file_name
			      FROM		t_export_report_instance trpi 
			      INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep
			      WHERE		trpi.c_exec_type = 'eop'
			      AND			trpi.id_rep_instance_id = @old_id_rep_inst
			      AND			trp.id_rep = @old_id_rep
			      AND			trpi.dt_activate <= @system_datetime
			      AND			(trpi.dt_deactivate is null or trpi.dt_deactivate > @system_datetime)

			      INSERT INTO @idQs (idq) VALUES (@wkId)

			      SELECT @old_id_rep = @id_rep, @old_id_rep_inst = @id_rep_inst, @prm_stor = ''
			      SELECT	@prm_stor = @prm_stor + @prmval+ ',' 
		      END
		      ELSE
		      BEGIN
			      SELECT	@prm_stor = @prm_stor + @prmval+ ',' 
		      END
		      FETCH NEXT FROM cr_prms INTO @prmval, @id_rep, @id_rep_inst
	      END

	      SET @wkid = NEWID()
	      INSERT INTO t_export_workqueue(id_work_queue, id_rep, id_rep_instance_id, id_schedule, c_sch_type, dt_queued, dt_sched_run, 
			      c_rep_title, c_rep_type, c_rep_def_source, 
			      c_rep_query_tag, c_rep_output_type, c_rep_distrib_type, c_rep_destn, 
			      c_destn_direct, c_destn_access_user, c_destn_access_pwd, c_ds_id, c_eop_step_instance_name, 
			      c_generate_control_file, c_control_file_delivery_location, c_output_execute_params_info,
			      c_compressreport, c_compressthreshold, c_exec_type, c_use_quoted_identifiers, 
			      dt_last_run, dt_next_run, c_current_process_stage, c_param_name_values, id_run, c_queuerow_source, c_output_file_name)
	      SELECT	@wkid, trpi.id_rep, trpi.id_rep_instance_id, NULL as 'id_schedule', NULL as 'c_sch_type', @system_datetime AS dt_Queued, @system_datetime AS dt_sched_run, 
			      trp.c_report_title, trp.c_rep_type,trp.c_rep_def_source,  
			      trp.c_rep_query_tag, trpi.c_rep_output_type, trpi.c_rep_distrib_type, trpi.c_report_destn, 
			      trpi.c_destn_direct, trpi.c_access_user, trpi.c_access_pwd, trpi.c_ds_id, trpi.c_eop_step_instance_name, 
			      trpi.c_generate_control_file, trpi.c_control_file_delivery_location, trpi.c_output_execute_params_info,
			      trpi.c_compressreport, trpi.c_compressthreshold, 'eop', trpi.c_use_quoted_identifiers, 
			      trpi.dt_last_run, @system_datetime, 0, SUBSTRING(@prm_stor, 1, LEN(@prm_stor) - 1), @runid, 'EOP ADAPTER', trpi.c_output_file_name
	      FROM		t_export_report_instance trpi 
	      INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep
	      WHERE		trpi.c_exec_type = 'eop'
	      AND			trpi.id_rep_instance_id = @old_id_rep_inst
	      AND			trp.id_rep = @old_id_rep
	      AND			trpi.dt_activate <= @system_datetime
	      AND			(trpi.dt_deactivate is null or trpi.dt_deactivate > @system_datetime)
	
	      INSERT INTO @idQs (idq) VALUES (@wkId)

	      close cr_prms
	      deallocate cr_prms	

	      SELECT	*
	      FROM	t_export_workqueue 
	      WHERE	id_work_queue IN (SELECT idq FROM @idQs)
	

      RETURN
      END
	 