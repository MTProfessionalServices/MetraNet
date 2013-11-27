
					SELECT 
						c_rep_instance_desc as ReportInstanceDescr,
						CASE 
							WHEN c_report_online = 0 THEN 'No'
							ELSE 'Yes'
						END AS showreportonline,
						dt_activate as InstanceActivationDate,
						dt_deactivate as InstanceDeactivationDate ,
						c_rep_output_type as ReportOutputType,						
						LTRIM(RTRIM(c_rep_distrib_type)) as ReportDeliveryType,
						LTRIM(RTRIM(c_report_destn)) as ReportDestination,
						LTRIM(RTRIM(NVL(c_access_user,''))) as FTPUser, 
						LTRIM(RTRIM(NVL(c_access_pwd,''))) as FTPPassword,
						LTRIM(RTRIM(c_exec_type)) as ExecutionType,
						CASE 
							WHEN c_generate_control_file = 0 then 'No'
							ELSE 'Yes'
						END AS GenerateControlFile,
						LTRIM(RTRIM(NVL(c_control_file_delivery_locati,''))) as ControlFileLocation,
						c_ds_id as DSID,
						CASE 
							WHEN c_compressreport = 0 then 'No'
							ELSE 'Yes'
						END AS CompressReport,
						NVL(c_compressthreshold,-1) as CompressThreshold,
						
						CASE 
							WHEN c_output_execute_params_info = 0 then 'No'
							ELSE 'Yes'
						END AS OutPutExecuteParameters,
						CASE 
							WHEN c_use_quoted_identifiers = 0 then 'No'
							ELSE 'Yes'
						END AS QuotedIdentifiers,
						dt_last_run as LastRunDate,
						NVL(dt_next_run,'') as NextRunDate,
						NVL(c_output_file_name,'NA') as OutputFileName                       
					FROM t_export_report_instance
                        WHERE id_rep_instance_id = %%ID_REP_INSTANCE_ID%%
                        