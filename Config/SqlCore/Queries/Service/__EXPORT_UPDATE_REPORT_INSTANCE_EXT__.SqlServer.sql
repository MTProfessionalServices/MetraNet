
				exec export_UpdateReportInstance 	
						@id_rep					=%%ID_REP%%,
						@ReportInstanceId		=%%ID_REP_INSTANCE%%,
						@desc					=%%DESC%%,
						@outputType				=%%OUTPUT_TYPE%%,
						@distributionType		=%%DELIVERY_TYPE%%,
						@destination			=%%DESTINATION%%,
						@ReportExecutionType	=%%EXEC_TYPE%%,
						@xmlConfigLocation		=%%CONFIG_FILE_LOC%%,
						@dtActivate				=%%DT_ACTIVATE%%,
						@dtDeActivate			=%%DT_DEACTIVATE%%,
						@destnAccessUser		=%%FTP_USER%%,
						@destnAccessPwd			=%%FTP_PASSWORD%%,
						@compressreport			=%%COMPRESS_REPORT%%,
						@compressthreshold		=%%COMPRESS_THRESHOLD%%,
						@eopinstancename		=%%EOP_INSTANCE_NAME%%,
						@ds_id					=%%DS_ID%%,
						@createcontrolfile		=%%CREATE_CONTROL_FILE%%,
						@controlfiledelivery	=%%CONTROL_FILE_DESTINATION%%,
						@outputExecuteParams	=%%OUTPUT_EXEC_PARAMS_TO_REPORT%%,
						@UseQuotedIdentifiers	=%%USE_QUOTED_IDENTIFIERS%%,
						@dtLastRunDateTime		=%%DT_LAST_RUN%%,
						@dtNextRunDateTime		=%%DT_NEXT_RUN%%,
						@outputFileName			=%%OUTPUT_FILE_NAME%%,
						@paramDefaultNameValues	=%%PARAM_NAME_VALUES%%
			