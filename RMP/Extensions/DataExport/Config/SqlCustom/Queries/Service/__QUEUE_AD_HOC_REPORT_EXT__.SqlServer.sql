
			Execute export_Queue_AdHocReport	@id_rep=%%ID_REP%%, 
											@outputType='%%OUTPUT_TYPE%%',
											@deliveryType='%%DELIVERY_TYPE%%',
											@destn='%%DESTINATION%%',
											@compressReport=%%COMPRESS_REPORT%%,
											@compressThreshold=%%COMPRESS_THRESHOLD%%,
											@identifier=%%IDENTIFIER%%,
											@paramNameValues=%%PARAM_NAME_VALUES%%,
											@ftpUser=%%FTP_USER%%,
											@ftpPassword=%%FTP_PASSWORD%%,
											@createControlFile=%%CREATE_CONTROL_FILE%%,
											@controlFileDestn=%%CONTROL_FILE_DESTINATION%%,
											@outputExecParamsInfo=%%OUTPUT_EXEC_PARAMS_TO_REPORT%%,
											@outputFileName=%%OUTPUT_FILE_NAME%%,
											@dsid=%%DS_ID%%,
											@usequotedidentifiers=%%USE_QUOTED_IDENTIFIERS%%
	