if not exists(select 1 from sys.tables where name = 'mvm_server_params')
BEGIN
  PRINT N'CREATING TABLE MVM_SERVER_PARAMS'
  BEGIN TRY
    CREATE TABLE [dbo].[mvm_server_params](
	[server_id] [int] NOT NULL,
  [parameter_name] [varchar](400) NOT NULL,
	[parameter_value] [varchar](400) NOT NULL
    ) ON [PRIMARY] 
	END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage
END CATCH;
END
ELSE
  PRINT N'MVM_SEVER_PARAMS table exists'
