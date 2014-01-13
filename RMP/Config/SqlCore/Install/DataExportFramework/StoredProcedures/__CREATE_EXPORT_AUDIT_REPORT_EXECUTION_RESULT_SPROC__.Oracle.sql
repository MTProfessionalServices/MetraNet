                                       
              CREATE OR REPLACE PROCEDURE Export_AuditReportExecutResult
              (
                p_WorkQId IN CHAR DEFAULT NULL ,
                p_ExecuteStatus IN VARCHAR2 DEFAULT NULL ,
                p_ExecuteStartDateTime IN DATE DEFAULT NULL ,
                p_ExecuteCompleteDateTime IN DATE DEFAULT NULL ,
                p_Descr IN VARCHAR2 DEFAULT NULL ,
                p_executionParamValues IN VARCHAR2 DEFAULT NULL
              )
              AS
              v_rawWorkQId RAW(16) := NULL;
              BEGIN
				 v_rawWorkQId := HEXTORAW(TRANSLATE(p_WorkQId, '0{-}','0'));
                 INSERT INTO t_export_execute_audit
                   ( id_work_queue, id_rep, id_rep_instance_id, id_schedule, c_sch_type, dt_queued, dt_sched_run, c_use_database, c_rep_title, c_rep_type, c_rep_def_source, c_rep_query_tag, c_rep_output_type, c_rep_distrib_type, c_rep_destn, c_destn_access_user, c_use_quoted_identifiers, c_generate_control_file, c_control_file_delivery_locati, c_output_execute_params_info, c_exec_type, c_compressreport, c_compressthreshold, c_ds_id, c_eop_step_instance_name, c_processed_server, id_run, run_start_dt, run_end_dt, c_run_result_status, c_run_result_descr, c_execute_paraminfo, c_queuerow_source, c_output_file_name )
                   ( SELECT id_work_queue ,
                            id_rep ,
                            id_rep_instance_id ,
                            id_schedule ,
                            c_sch_type ,
                            dt_queued ,
                            dt_sched_run ,
                            NVL(c_use_database, '(local)') ,
                            c_rep_title ,
                            c_rep_type ,
                            c_rep_def_source ,                            
                            c_rep_query_tag ,
                            c_rep_output_type ,                            
                            c_rep_distrib_type ,
                            c_rep_destn ,
                            c_destn_access_user ,
                            c_use_quoted_identifiers ,
                            c_generate_control_file ,
                            c_control_file_delivery_locati ,
                            c_output_execute_params_info ,
                            c_exec_type ,
                            c_compressreport ,
                            c_compressthreshold ,
                            c_ds_id ,
                            c_eop_step_instance_name ,
                            c_processing_server ,
                            id_run ,
                            p_ExecuteStartDateTime ,
                            p_ExecuteCompleteDateTime ,
                            p_ExecuteStatus ,
                            p_Descr ,
                            CASE 
                                 WHEN p_executionParamValues = 'Bad Parms passed - see MTLOG: ' THEN p_executionParamValues || ': ' || NVL(REPLACE(c_param_name_values, '%', ''), 'N/A')
                            ELSE NVL(p_executionparamvalues,'N/A')
                               END col  ,
                            c_queuerow_source ,
                            c_output_file_name 
                     FROM t_export_workqueue 
                      WHERE id_work_queue = v_rawWorkQId );
                 DELETE t_export_workqueue
              
                  WHERE id_work_queue = v_rawworkqid;
              END;
	 