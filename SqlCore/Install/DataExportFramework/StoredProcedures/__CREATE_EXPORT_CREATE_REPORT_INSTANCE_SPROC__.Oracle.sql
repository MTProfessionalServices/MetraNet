                                       
              CREATE OR REPLACE PROCEDURE Export_CreateReportInstance
              (
                p_id_rep IN NUMBER DEFAULT NULL ,
                p_desc IN VARCHAR2 DEFAULT NULL ,
                p_outputType IN VARCHAR2 DEFAULT NULL ,
                p_distributionType IN VARCHAR2 DEFAULT NULL ,
                p_destination IN VARCHAR2 DEFAULT NULL ,
                p_ReportExecutionType IN CHAR DEFAULT NULL ,
                p_xmlConfigLocation IN VARCHAR2 DEFAULT NULL ,
                p_c_report_online IN NUMBER DEFAULT NULL ,
                p_dtActivate IN DATE DEFAULT NULL ,
                p_dtDeActivate IN DATE DEFAULT NULL ,
                p_directMoveToDestn IN NUMBER DEFAULT NULL ,
                p_destnAccessUser IN VARCHAR2 DEFAULT NULL ,
                p_destnAccessPwd IN NVARCHAR2 DEFAULT NULL ,
                p_compressreport IN NUMBER DEFAULT NULL ,
                p_compressthreshold IN NUMBER DEFAULT NULL ,
                p_ds_id IN NUMBER DEFAULT NULL ,
                p_eopinstancename IN NVARCHAR2 DEFAULT NULL ,
                p_createcontrolfile IN NUMBER DEFAULT NULL ,
                p_controlfiledelivery IN VARCHAR2 DEFAULT NULL ,
                p_outputExecuteParams IN NUMBER DEFAULT NULL ,
                p_UseQuotedIdentifiers IN NUMBER DEFAULT NULL ,
                p_dtLastRunDateTime IN DATE DEFAULT NULL ,
                p_dtNextRunDateTime IN DATE DEFAULT NULL ,
                p_paramDefaultNameValues IN VARCHAR2 DEFAULT NULL ,
                p_outputFileName IN VARCHAR2 DEFAULT NULL ,
                p_system_datetime DATE DEFAULT NULL,
                p_ReportInstanceId OUT NUMBER
              )              
              AS
                 v_xmlConfigLocation VARCHAR2(255) := p_xmlConfigLocation;
                 p_ErrorMessage VARCHAR2(100);
              
              BEGIN
                 v_xmlConfigLocation := 'DataExport\Config\fieldDef' ;
                 INSERT INTO t_export_report_instance
                   ( c_rep_instance_desc, 
				     id_rep, 
					 c_report_online, 
					 dt_activate, 
					 dt_deactivate, 
					 c_rep_output_type, 
					 c_xmlConfig_loc, 
					 c_rep_distrib_type, 
					 c_report_destn, 
					 c_destn_direct, 
					 c_access_user, 
					 c_access_pwd, 
					 c_generate_control_file, 
					 c_control_file_delivery_locati, 
					 c_output_execute_params_info, 
					 c_use_quoted_identifiers, 
					 c_exec_type, 
					 c_compressreport, 
					 c_compressthreshold, 
					 c_ds_id, 
					 c_eop_step_instance_name, 
					 dt_last_run, 
					 dt_next_run, 
					 c_output_file_name )
                   VALUES ( p_desc, 
							p_id_rep, 
							NVL(p_c_report_online, 0), 
							NVL(p_dtActivate, p_system_datetime), 
							p_dtDeActivate, 
							p_outputType, 
							v_xmlConfigLocation, 
							p_distributionType, 
							p_destination, 
							NVL(p_directMoveToDestn, 1), 
							p_destnAccessUser, 
							p_destnAccessPwd, 
							p_createcontrolfile, 
							p_controlfiledelivery, 
							NVL(p_outputExecuteParams, 0), 
							p_UseQuotedIdentifiers, 
							p_ReportExecutionType, 
							NVL(p_compressreport, 0), 
							NVL(p_compressthreshold, -1), 
							p_ds_id, 
							p_eopinstancename, 
							p_dtLastRunDateTime, 
							p_dtNextRunDateTime, 
							p_outputFileName )
                   RETURNING id_rep_instance_id INTO p_ReportInstanceId;
                 /* Insert Blank Values for all Parameters associated with the report */
                 INSERT INTO t_export_default_param_values
                   (id_rep_instance_id,
                    id_param_name,
                    c_param_value)
                   ( SELECT p_ReportInstanceId  ,
                            erp.id_param_name   ,
                            'UNDEFINED'   
                     FROM t_export_report_params erp
                      WHERE erp.id_rep = p_id_rep 
                              AND NOT EXISTS ( SELECT id_param_name 
                                               FROM t_export_default_param_values 
                                                WHERE id_rep_instance_id = p_ReportInstanceId ) );
                 GOTO EXIT_SUCCESS_;
                 <<ERROR_>>
                 ROLLBACK;
                 raise_application_error( -20002, p_ErrorMessage );
                 RETURN;
                 <<EXIT_SUCCESS_>>
                 COMMIT;
                 RETURN;
              END;
	 