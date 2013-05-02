                                     
              CREATE OR REPLACE PROCEDURE Export_QueueScheduledReports
              (
                v_RunId IN NUMBER DEFAULT NULL,
                v_system_datetime DATE DEFAULT NULL
              )
              AS
                 v_Warning_Results NUMBER(10,0);
                 v_id_rep NUMBER(10,0);
                 v_id_rep_instance_id NUMBER(10,0);
                 v_id_schedule NUMBER(10,0);
                 v_c_sch_type VARCHAR2(10);
                 v_dt_queued DATE;
                 v_dt_next_run DATE;
                 v_c_current_process_stage NUMBER(10,0);
                 v_c_processing_server VARCHAR2(50);
                 v_dt_last_run DATE;
                 v_c_report_title VARCHAR2(50);
                 v_c_rep_type VARCHAR2(10);
                 v_c_rep_def_source VARCHAR2(100);
                 v_c_rep_query_source VARCHAR2(100);
                 v_c_rep_query_tag VARCHAR2(50);
                 v_c_rep_output_type VARCHAR2(10);
                 v_c_xmlConfig_loc VARCHAR2(255);
                 v_c_rep_distrib_type VARCHAR2(10);
                 v_c_report_destn VARCHAR2(255);
                 v_c_destn_direct NUMBER(1,0);
                 v_c_access_user VARCHAR2(50);
                 v_c_access_pwd VARCHAR2(2048);
                 v_ds_id NUMBER(10,0);
                 v_eopinstancename NVARCHAR2(510);
                 v_outputExecuteParamInfo NUMBER(1,0);
                 v_outputFileName VARCHAR2(50);
                 v_generatecontrolfile NUMBER(1,0);
                 v_controlfiledeliverylocation VARCHAR2(255);
                 v_compressreport NUMBER(1,0);
                 v_compressthreshold NUMBER(10,0);
                 v_param_name_values VARCHAR2(1000);
                 v_UseQuotedIdentifiers NUMBER(1,0);
                 v_IntervalId NUMBER(10,0);
                 
                 /* SELECT * FROM #tparamInfo */
                 CURSOR c_reports
                   IS SELECT trpi.id_rep ,
                 trps.id_rep_instance_id ,
                 trps.id_schedule ,
                 trps.c_sch_type ,
                 v_system_datetime dt_Queued  ,
                 trpi.dt_next_run ,
                 trp.c_report_title ,
                 trp.c_rep_type ,
                 trp.c_rep_def_source ,
                 trp.c_rep_query_source ,
                 trp.c_rep_query_tag ,
                 trpi.c_rep_output_type ,
                 trpi.c_xmlConfig_loc ,
                 trpi.c_rep_distrib_type ,
                 trpi.c_report_destn ,
                 trpi.c_destn_direct ,
                 trpi.c_access_user ,
                 trpi.c_access_pwd ,
                 trpi.c_ds_id ,
                 trpi.c_eop_step_instance_name ,
                 trpi.c_generate_control_file ,
                 trpi.c_control_file_delivery_locati ,
                 trpi.c_output_execute_params_info ,
                 trpi.c_use_quoted_identifiers ,
                 trpi.c_compressreport ,
                 trpi.c_compressthreshold ,
                 trpi.dt_last_run ,
                 trpi.c_output_file_name 
                   FROM t_export_schedule trps
                   JOIN t_export_report_instance trpi
                    ON trps.id_rep_instance_id = trpi.id_rep_instance_id
                   JOIN t_export_reports trp
                    ON trpi.id_rep = trp.id_rep
                  WHERE trpi.c_exec_type = 'Scheduled'
                   AND ( trpi.dt_next_run <= v_system_datetime
                   OR trpi.dt_next_run IS NULL )
                   AND trpi.dt_activate <= v_system_datetime
                   AND ( trpi.dt_deactivate >= v_system_datetime
                   OR trpi.dt_deactivate IS NULL );
              
              BEGIN
                 /* Get the interval id using the report's current start date. */
                 INSERT INTO tt_DEF_tparamInfo
                   ( SELECT DISTINCT trpi.id_rep ,
                                     trpi.id_rep_instance_id ,
                                     tpn.c_param_name || '=' || NVL(CASE REPLACE(tpn.c_param_name, '%', '')
                                                                                                           WHEN 'START_DATE' THEN NVL(TO_CHAR(TO_TIMESTAMP(trpi.dt_last_run, 'YYYY-MM-DD HH24:MI:SS.FF3')), tdfp.c_param_value)
                                                                                                           WHEN 'START_DT' THEN NVL(TO_CHAR(TO_TIMESTAMP(trpi.dt_last_run, 'YYYY-MM-DD HH24:MI:SS.FF3')), tdfp.c_param_value)
                                                                                                           WHEN 'END_DATE' THEN NVL(TO_CHAR(TO_TIMESTAMP(trpi.dt_next_run, 'YYYY-MM-DD HH24:MI:SS.FF3')), tdfp.c_param_value)
                                                                                                           WHEN 'END_DT' THEN NVL(TO_CHAR(TO_TIMESTAMP(trpi.dt_next_run, 'YYYY-MM-DD HH24:MI:SS.FF3')), tdfp.c_param_value)
                                                                                                           WHEN 'ID_INTERVAL' THEN ( SELECT CAST(id_interval AS VARCHAR2(4000)) 
                                                                                                                                     FROM t_usage_interval 
                                                                                                                                      WHERE Extract(month from dt_start) = Extract(month from NVL(trpi.dt_last_run, tdfp.c_param_value))
                                                                                                                                              AND Extract(year from dt_start) = Extract(year from NVL(trpi.dt_last_run, tdfp.c_param_value))
                                                                                                                                              AND Extract(day from dt_start) = 1 )
                                                                    ELSE tdfp.c_param_value
                                                                       END, 'NULL') c_param_value  
                     FROM t_export_param_names tpn
                            JOIN t_export_report_params trpm
                             ON tpn.id_param_name = trpm.id_param_name
                            JOIN t_export_report_instance trpi
                             ON trpm.id_rep = trpi.id_rep
                            LEFT JOIN t_export_default_param_values tdfp
                             ON trpi.id_rep_instance_id = tdfp.id_rep_instance_id
                            AND trpm.id_param_name = tdfp.id_param_name );
                 OPEN c_reports;
                 FETCH c_reports INTO v_id_rep,v_id_rep_instance_id,v_id_schedule,v_c_sch_type,v_dt_queued,v_dt_next_run,v_c_report_title,v_c_rep_type,v_c_rep_def_source,v_c_rep_query_source,v_c_rep_query_tag,v_c_rep_output_type,v_c_xmlConfig_loc,v_c_rep_distrib_type,v_c_report_destn,v_c_destn_direct,v_c_access_user,v_c_access_pwd,v_ds_id,v_eopinstancename,v_generatecontrolfile,v_controlfiledeliverylocation,v_outputExecuteParamInfo,v_UseQuotedIdentifiers,v_compressreport,v_compressthreshold,v_dt_last_run,v_outputFileName;
                 WHILE c_reports%FOUND
                 LOOP 
                    DECLARE
                       v_temp NUMBER(1, 0) := 0;
                    
                    BEGIN
						FOR cur_param IN (SELECT c_param_name_value FROM tt_def_tparaminfo WHERE id_rep = v_id_rep and id_rep_instance_id = v_id_rep_instance_id)
						LOOP
						 v_param_name_values:= v_param_name_values ||','|| cur_param.c_param_name_value;
						END LOOP;
						v_param_name_values:= LTRIM(v_param_name_values, ',');
                       BEGIN
                          SELECT 1 INTO v_temp
                            FROM DUAL
                           WHERE NOT EXISTS ( SELECT * 
                                              FROM t_export_workqueue 
                                               WHERE id_rep_instance_id = v_id_rep_instance_id
                                                       AND id_rep = v_id_rep
                                                       AND c_sch_type = v_c_sch_type
                                                       AND c_exec_type = 'sch'
                                                       AND dt_next_run = v_dt_next_run
                                                       AND dt_last_run = v_dt_last_run
                                                       AND NVL(c_ds_id, '') = NVL(v_ds_id, '')
                                                       AND dt_sched_run = v_dt_next_run );
                       EXCEPTION
                          WHEN OTHERS THEN
                             NULL;
                       END;
                          
                       IF v_temp = 1 THEN
                       
                       BEGIN
                          /*  check if scheduled jobs can run for the next run date specified
                                      IF EXISTS (select * from netmeter_custom..t_process_control_detail 
                                                              where id_control = 3 and id_control_date >= CONVERT(VARCHAR, @dt_next_run, 101))
                                          BEGIN                
                                              This checks for any extra conditions that must be met before a given scheduled report can run. */
                          v_Warning_Results :=export_QueueReportChecks('Scheduled',
                                                                       v_id_rep,
                                                                       v_id_rep_instance_id,
                                                                       v_system_datetime);
                          DBMS_OUTPUT.PUT_LINE('WARNINGS - ' || CAST(v_id_rep_instance_id AS VARCHAR2) || ' ' || CAST(v_Warning_Results AS VARCHAR2));
                          IF v_Warning_Results = 0 THEN
                             INSERT INTO t_export_workqueue
                               ( id_rep_instance_id, id_rep, id_schedule, c_sch_type, dt_queued, dt_sched_run, c_rep_title, c_rep_type, c_rep_def_source, c_rep_query_source, c_rep_query_tag, c_rep_output_type, c_xmlConfig_loc, c_rep_distrib_type, c_rep_destn, c_destn_direct, c_destn_access_user, c_destn_access_pwd, c_ds_id, c_eop_step_instance_name, c_generate_control_file, c_control_file_delivery_locati, c_output_execute_params_info, c_use_quoted_identifiers, c_compressreport, c_compressthreshold, c_exec_type, dt_last_run, dt_next_run, c_current_process_stage, c_param_name_values, id_run, c_queuerow_source, c_output_file_name )
                               VALUES ( v_id_rep_instance_id, v_id_rep, v_id_schedule, v_c_sch_type, v_dt_queued, v_dt_next_run, v_c_report_title, v_c_rep_type, v_c_rep_def_source, v_c_rep_query_source, v_c_rep_query_tag, v_c_rep_output_type, v_c_xmlConfig_loc, v_c_rep_distrib_type, v_c_report_destn, v_c_destn_direct, v_c_access_user, v_c_access_pwd, v_ds_id, v_eopinstancename, v_generatecontrolfile, v_controlfiledeliverylocation, v_outputExecuteParamInfo, v_UseQuotedIdentifiers, v_compressreport, v_compressthreshold, 'sch', v_dt_last_run, v_dt_next_run, 0, v_param_name_values, v_RunId, CAST(v_RunID AS VARCHAR2(4000)), v_outputFileName );
                          END IF;
                       END;
                       END IF;
                       /* END */
                       v_param_name_values := NULL ;
                       FETCH c_reports INTO v_id_rep,v_id_rep_instance_id,v_id_schedule,v_c_sch_type,v_dt_queued,v_dt_next_run,v_c_report_title,v_c_rep_type,v_c_rep_def_source,v_c_rep_query_source,v_c_rep_query_tag,v_c_rep_output_type,v_c_xmlConfig_loc,v_c_rep_distrib_type,v_c_report_destn,v_c_destn_direct,v_c_access_user,v_c_access_pwd,v_ds_id,v_eopinstancename,v_generatecontrolfile,v_controlfiledeliverylocation,v_outputExecuteParamInfo,v_UseQuotedIdentifiers,v_compressreport,v_compressthreshold,v_dt_last_run,v_outputFileName;
                    END;
                 END LOOP;
                 CLOSE c_reports;
              END;
	 