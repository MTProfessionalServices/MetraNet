
        CREATE OR REPLACE PROCEDURE Export_QueueEOPReports
		(
			p_eopInstanceName in VARCHAR2,
			p_intervalId      in NUMBER DEFAULT NULL,
			p_id_billgroup    in NUMBER DEFAULT NULL,  /* Added the billgroup, but we have to agree on how this will be used..... */
			p_runId           in NUMBER DEFAULT NULL,
			p_system_datetime in DATE DEFAULT NULL
		)
		AS
			param_name_values VARCHAR2(1000);
			wkId RAW(16);
			prmval VARCHAR2(1000);
			id_rep NUMBER;
			id_rep_inst NUMBER;
			old_id_rep NUMBER;
			old_id_rep_inst NUMBER;
			prm_stor VARCHAR2(1000);

			CURSOR cr_prms IS SELECT c_param_name_value,
									 id_rep,
									 id_rep_instance_id
			FROM  tt_DEF_tparamInfo
			GROUP BY id_rep, id_rep_instance_id, c_param_name_value
			ORDER BY id_rep_instance_id;

		BEGIN
			 INSERT INTO tt_DEF_tparamInfo
				  SELECT   trp.id_rep, trpi.id_rep_instance_id,  decode(tpn.c_param_name, null, tpn.c_param_name, tpn.c_param_name || '=' ) ||
							  NVL(CASE replace(tpn.c_param_name,'%','')
								  WHEN 'ID_INTERVAL' THEN + NVL(CAST(p_intervalId AS VARCHAR2(100)), '')
								  WHEN 'ID_BILLGROUP' THEN + NVL(CAST(p_id_billgroup AS VARCHAR2(100)), '')
								  ELSE tdfp.c_param_value
							  END, '')
				  FROM  t_export_reports trp
				  LEFT  JOIN t_export_report_instance trpi ON trp.id_rep = trpi.id_rep
				  LEFT JOIN t_export_default_param_values tdfp
				  INNER JOIN t_export_param_names tpn ON tdfp.id_param_name = tpn.id_param_name
				  INNER JOIN t_export_report_params trpm ON tpn.id_param_name = trpm.id_param_name ON  trpi.id_rep_instance_id = tdfp.id_rep_instance_id
				  WHERE trpi.c_eop_step_instance_name = p_eopInstanceName;

				  prm_stor := '';

			OPEN cr_prms;
			FETCH cr_prms INTO prmval, id_rep, id_rep_inst;
			  old_id_rep       := id_rep;
			  old_id_rep_inst  := id_rep_inst;
			  prm_stor         := '';

			WHILE cr_prms%FOUND
			LOOP
			BEGIN
				IF old_id_rep <> id_rep OR old_id_rep_inst <> id_rep_inst THEN
					BEGIN
						wkid := SYS_GUID();
						INSERT INTO t_export_workqueue(id_work_queue, id_rep, id_rep_instance_id, id_schedule, c_sch_type, dt_queued, dt_sched_run,
								  c_rep_title, c_rep_type, c_rep_def_source,
								  c_rep_query_tag, c_rep_output_type, c_rep_distrib_type, c_rep_destn,
								  c_destn_direct, c_destn_access_user, c_destn_access_pwd, c_ds_id, c_eop_step_instance_name,
								  c_generate_control_file, c_control_file_delivery_locati, c_output_execute_params_info,
								  c_compressreport, c_compressthreshold, c_exec_type, c_use_quoted_identifiers,
								  dt_last_run, dt_next_run, c_current_process_stage, c_param_name_values, id_run, c_queuerow_source, c_output_file_name)
						SELECT    wkid, trpi.id_rep, trpi.id_rep_instance_id, NULL, NULL, p_system_datetime, p_system_datetime,
								  trp.c_report_title, trp.c_rep_type,trp.c_rep_def_source,
								  trp.c_rep_query_tag, trpi.c_rep_output_type, trpi.c_rep_distrib_type, trpi.c_report_destn,
								  trpi.c_destn_direct, trpi.c_access_user, trpi.c_access_pwd, trpi.c_ds_id, trpi.c_eop_step_instance_name,
								  trpi.c_generate_control_file, trpi.c_control_file_delivery_locati, trpi.c_output_execute_params_info,
								  trpi.c_compressreport, trpi.c_compressthreshold, 'eop', trpi.c_use_quoted_identifiers,
								  trpi.dt_last_run, p_system_datetime, 0, substr(prm_stor, 1, NVL(LENGTH(prm_stor),0) - 1), p_runid, 'EOP ADAPTER', trpi.c_output_file_name
						FROM      t_export_report_instance trpi
						INNER JOIN    t_export_reports trp ON trpi.id_rep = trp.id_rep
						WHERE     LOWER(trpi.c_exec_type) = 'eop'
						AND           trpi.id_rep_instance_id = old_id_rep_inst
						AND           trp.id_rep = old_id_rep
						AND           trpi.dt_activate <= p_system_datetime
						AND           (trpi.dt_deactivate is null or trpi.dt_deactivate > p_system_datetime);

						INSERT INTO tt_DEF_queue_ids (idq) VALUES (wkId);

						old_id_rep       := id_rep;
						old_id_rep_inst  := id_rep_inst;
						prm_stor         := '';

						prm_stor := prm_stor || prmval || ',';                
					END;
					ELSE
					BEGIN
						prm_stor := prm_stor || prmval || ',';                
					END;
				END IF;

				FETCH cr_prms INTO prmval, id_rep, id_rep_inst;
			END;
			END LOOP;
			CLOSE cr_prms;

			wkid := SYS_GUID();
			INSERT INTO t_export_workqueue(id_work_queue, id_rep, id_rep_instance_id, id_schedule, c_sch_type, dt_queued, dt_sched_run,
					   c_rep_title, c_rep_type, c_rep_def_source,
					   c_rep_query_tag, c_rep_output_type, c_rep_distrib_type, c_rep_destn,
					   c_destn_direct, c_destn_access_user, c_destn_access_pwd, c_ds_id, c_eop_step_instance_name,
					   c_generate_control_file, c_control_file_delivery_locati, c_output_execute_params_info,
					   c_compressreport, c_compressthreshold, c_exec_type, c_use_quoted_identifiers,
					   dt_last_run, dt_next_run, c_current_process_stage, c_param_name_values, id_run, c_queuerow_source, c_output_file_name)
			SELECT    wkid, trpi.id_rep, trpi.id_rep_instance_id, NULL, NULL , p_system_datetime , p_system_datetime ,
					   trp.c_report_title, trp.c_rep_type,trp.c_rep_def_source,
					   trp.c_rep_query_tag, trpi.c_rep_output_type, trpi.c_rep_distrib_type, trpi.c_report_destn,
					   trpi.c_destn_direct, trpi.c_access_user, trpi.c_access_pwd, trpi.c_ds_id, trpi.c_eop_step_instance_name,
					   trpi.c_generate_control_file, trpi.c_control_file_delivery_locati, trpi.c_output_execute_params_info,
					   trpi.c_compressreport, trpi.c_compressthreshold, 'eop', trpi.c_use_quoted_identifiers,
					   trpi.dt_last_run, p_system_datetime, 0, substr(prm_stor, 1, NVL(LENGTH(prm_stor),0) - 1), p_runid, 'EOP ADAPTER', trpi.c_output_file_name
			FROM      t_export_report_instance trpi
			INNER JOIN    t_export_reports trp ON trpi.id_rep = trp.id_rep
			WHERE     LOWER(trpi.c_exec_type) = 'eop'
			AND           trpi.id_rep_instance_id = old_id_rep_inst
			AND           trp.id_rep = old_id_rep
			AND           trpi.dt_activate <= p_system_datetime
			AND           (trpi.dt_deactivate is null or trpi.dt_deactivate > p_system_datetime);
			
			INSERT INTO tt_DEF_queue_ids (idq) VALUES (wkId);
		END;
	 