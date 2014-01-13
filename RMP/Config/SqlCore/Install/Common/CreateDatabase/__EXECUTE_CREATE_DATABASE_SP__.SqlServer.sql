
		BEGIN
			DECLARE	@return_value int,
			@return_code int
			EXEC	@return_value = [dbo].[CreateReportingDB]
					@strDBName = N'%%DB_NAME%%',
					@strNetmeterDBName = N'%%NETMETER_DB_NAME%%',
					@strDataLogFilePath = N'%%DATA_LOG_PATH%%',
					@dbSize = %%DB_SIZE%%,
					@return_code = @return_code OUTPUT

			SELECT	@return_code as N'@return_code'
			SELECT	'Return Value' = @return_value
		END
	