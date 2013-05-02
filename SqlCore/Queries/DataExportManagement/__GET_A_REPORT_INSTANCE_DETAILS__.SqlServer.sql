

			SELECT 
			c_rep_instance_desc as ReportInstanceDescr,
			case 
				when c_report_online = 0 then 'No'
				else 'Yes'
			end as showreportonline,
			dt_activate as InstanceActivationDate,
			dt_deactivate as InstanceDeactivationDate ,
			c_rep_output_type as ReportOutputType,
			c_xmlConfig_loc as XMLConfig,
			ltrim(rtrim(c_rep_distrib_type)) as ReportDeliveryType,
			ltrim(rtrim(c_report_destn)) as ReportDestination,
			ltrim(rtrim(isnull(c_access_user,''))) as FTPUser, 
			ltrim(rtrim(isnull(c_access_pwd,''))) as FTPPassword,
			ltrim(rtrim(c_exec_type)) as ExecutionType,
			case 
				when c_generate_control_file = 0 then 'No'
				else 'Yes'
			end as GenerateControlFile,
			ltrim(rtrim(isnull(c_control_file_delivery_location,''))) as ControlFileLocation,
          		c_ds_id as DSID,
			case 
				when c_compressreport = 0 then 'No'
				else 'Yes'
			end as CompressReport,
			isnull(c_compressthreshold,-1) as CompressThreshold,
			
			case 
				when c_output_execute_params_info = 0 then 'No'
				else 'Yes'
			end as OutPutExecuteParameters,

			case 
				when c_use_quoted_identifiers = 0 then 'No'
				else 'Yes'
			end as QuotedIdentifiers,
			dt_last_run as LastRunDate,
			isnull(dt_next_run,'') as NextRunDate,
			isnull(c_output_file_name,'NA') as OutputFileName                       
			FROM t_export_report_instance
                        WHERE id_rep_instance_id = %%ID_REP_INSTANCE_ID%%

	