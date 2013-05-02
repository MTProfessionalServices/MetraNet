                                       
              CREATE OR REPLACE PROCEDURE Export_Queue_AdHocReport
              (
                p_id_rep IN NUMBER DEFAULT NULL ,
                p_outputType IN VARCHAR2 DEFAULT NULL ,
                p_deliveryType IN VARCHAR2 DEFAULT NULL ,
                p_destn IN VARCHAR2 DEFAULT NULL ,
                p_compressReport IN NUMBER DEFAULT NULL ,
                p_compressThreshold IN NUMBER DEFAULT NULL ,
                p_identifier IN VARCHAR2 DEFAULT NULL ,
                p_paramNameValues IN VARCHAR2 DEFAULT NULL ,
                p_ftpUser IN VARCHAR2 DEFAULT NULL ,
                p_ftpPassword IN NVARCHAR2 DEFAULT NULL ,
                p_createControlFile IN NUMBER DEFAULT NULL ,
                p_controlFileDestn IN VARCHAR2 DEFAULT NULL ,
                p_outputExecParamsInfo IN NUMBER DEFAULT NULL ,
                p_dsid IN VARCHAR2 DEFAULT NULL ,
                p_outputFileName IN VARCHAR2 DEFAULT NULL ,
                p_usequotedidentifiers IN NUMBER DEFAULT NULL ,
                p_system_datetime DATE DEFAULT NULL,
                cv_1 IN OUT SYS_REFCURSOR
              )
              AS
                 p_sys_error NUMBER := 0;
                 p_reptitle VARCHAR2(255);
                 p_repType VARCHAR2(10);
                 p_repQuerySource VARCHAR2(100);
                 p_repQueryTag VARCHAR2(100);
                 p_xmlConfigLoc VARCHAR2(255);
                 p_saveStatus NUMBER(10,0);
                 p_msg VARCHAR2(255);
                 p_cRepDefSource VARCHAR2(500);
              
              BEGIN
                 BEGIN
                    SELECT c_report_title ,
                           c_rep_type ,
                           c_rep_query_source ,
                           c_rep_query_tag ,
                           'DataExport\config\fieldDef' ,
                           c_rep_def_source 
              
                      INTO p_reptitle,
                           p_repType,
                           p_repQuerySource,
                           p_repQueryTag,
                           p_xmlConfigLoc,
                           p_cRepDefSource
                      FROM t_export_reports 
                     WHERE id_rep = p_id_rep;
                 EXCEPTION
                    WHEN OTHERS THEN
                       p_sys_error := SQLCODE;
                 END;
                 BEGIN
                    INSERT INTO t_export_workqueue
                      ( id_rep, dt_queued, dt_sched_run, c_use_database, c_rep_title, c_rep_type, c_rep_query_source, c_rep_def_source, dt_last_run, dt_next_run, c_use_quoted_identifiers, c_rep_query_tag, c_rep_output_type, c_xmlConfig_loc, c_rep_distrib_type, c_rep_destn, c_destn_direct, c_destn_access_user, c_destn_access_pwd, c_exec_type, c_generate_control_file, c_control_file_delivery_locati, c_compressreport, c_compressthreshold, c_output_execute_params_info, c_ds_id, c_queuerow_source, c_param_name_values, c_output_file_name )
                      VALUES ( p_id_rep, p_system_datetime, p_system_datetime, '(local)', p_reptitle, p_repType, p_repQuerySource, p_cRepDefSource, p_system_datetime - 1, p_system_datetime, NVL(p_usequotedidentifiers, 0), p_repQueryTag, p_outputType, p_xmlConfigLoc, p_deliveryType, p_destn, 0, p_ftpuser, p_ftpPassword, 'ad-hoc', p_createControlFile, p_controlFileDestn, p_compressReport, p_compressThreshold, p_outputExecParamsInfo, p_dsid, p_identifier, 
                                         REPLACE(p_paramNameValues, '^', '%'), p_outputFileName );
                 EXCEPTION
                    WHEN OTHERS THEN
                       p_sys_error := SQLCODE;
                 END;
                 IF p_sys_error <> 0 THEN
                    GOTO ERR_;
                 END IF;
                 p_saveStatus := 1 ;
                 p_msg := 'Success' ;
                 GOTO EXIT_SP_;
                 RETURN;
                 <<ERR_>>
                 p_saveStatus := -1 ;
                 p_msg := 'Queue Ad-hoc report failed' ;
                 <<EXIT_SP_>>
                 OPEN cv_1 FOR
                    SELECT p_saveStatus SaveStatus  ,
                           p_msg Message  
                      FROM DUAL ;
                 RETURN;
              END;
	 