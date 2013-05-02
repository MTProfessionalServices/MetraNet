                                    
              CREATE OR REPLACE PROCEDURE Export_UpdateReportInstance
              (
                p_id_rep IN NUMBER DEFAULT NULL ,
                p_ReportInstanceId IN NUMBER DEFAULT NULL ,
                p_desc IN VARCHAR2 DEFAULT NULL ,
                p_outputType IN VARCHAR2 DEFAULT NULL ,
                p_distributionType IN VARCHAR2 DEFAULT NULL ,
                p_destination IN VARCHAR2 DEFAULT NULL ,
                p_ReportExecutionType IN CHAR DEFAULT NULL ,
                p_xmlConfigLocation IN VARCHAR2 DEFAULT NULL ,
                p_dtActivate IN DATE DEFAULT NULL ,
                p_dtDeActivate IN DATE DEFAULT NULL ,
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
                p_outputFileName IN VARCHAR2 DEFAULT NULL ,
                p_paramDefaultNameValues IN VARCHAR2 DEFAULT NULL 
              )             
              AS
                 v_xmlConfigLocation VARCHAR2(255) := p_xmlConfigLocation;
                 p_ErrorMessage VARCHAR2(100);
              
              BEGIN
                 v_xmlConfigLocation := '\DataExport\Config\fieldDef' ;
                 UPDATE t_export_report_instance
                    SET c_rep_instance_desc = p_desc,
                        dt_activate = p_dtActivate,
                        dt_deactivate = p_dtDeactivate,
                        c_rep_output_type = p_outputType,
                        c_xmlConfig_loc = v_xmlConfigLocation,
                        c_rep_distrib_type = p_distributionType,
                        c_report_destn = p_destination,
                        c_access_user = p_destnAccessUser,
                        c_access_pwd = p_destnAccessPwd,
                        c_generate_control_file = p_createcontrolfile,
                        c_control_file_delivery_locati = p_controlfiledelivery,
                        c_output_execute_params_info = p_outputExecuteParams,
                        c_use_quoted_identifiers = p_UseQuotedIdentifiers,
                        c_exec_type = p_ReportExecutionType,
                        c_compressreport = p_compressreport,
                        c_compressthreshold = p_compressthreshold,
                        c_ds_id = p_ds_id,
                        c_eop_step_instance_name = p_eopinstancename,
                        dt_last_run = p_dtLastRunDateTime,
                        dt_next_run = p_dtNextRunDateTime,
                        c_output_file_name = p_outputFileName
                    WHERE id_rep_instance_id = p_ReportInstanceId;
                    
                 /* Clean up parameter default values... */
                 /*DELETE t_export_default_param_values              
                  WHERE id_rep_instance_id = p_ReportInstanceId;*/
                  
                 /* Insert parameter default values... */
                 
                 /* DONT know why we have tio update the assigned parameters?
                  *INSERT INTO t_export_default_param_values( id_rep_instance_id,  id_param_name, c_param_value)
                   ( SELECT p_ReportInstanceId ,
                            erp.id_param_name,
                            'UNDEFINED'  
                     FROM t_export_report_params erp
                      WHERE erp.id_rep = p_id_rep 
                                      and erp.id_param_name not in 
                                     (select id_param_name 
                                        from t_export_default_param_values 
                                        where id_rep_instance_id = p_ReportInstanceId));*/
                 GOTO EXIT_SUCCESS_;
                 <<ERROR_>>
                 ROLLBACK;
                 raise_application_error( -20002, p_ErrorMessage );
                 RETURN;
                 <<EXIT_SUCCESS_>>
                 COMMIT;
                 RETURN;
              END;
	 