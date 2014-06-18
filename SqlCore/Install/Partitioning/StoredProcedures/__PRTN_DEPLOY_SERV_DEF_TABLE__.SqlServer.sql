CREATE PROCEDURE prtn_deploy_serv_def_table
		@svc_table_name 		VARCHAR(200)
AS
DECLARE @meter_partition_schema	NVARCHAR(50),
		@error_message			NVARCHAR(4000)

BEGIN TRY
	IF dbo.IsSystemPartitioned() = 0
		RETURN

	SET @meter_partition_schema = dbo.prtn_GetMeterPartitionSchemaName()

	IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @svc_table_name AND COLUMN_NAME = 'id_source_sess' )
	BEGIN
		SET @error_message = 'Table "' + @svc_table_name  + '" suggests to have column "id_source_sess" as a part of PK. This field is required for partitioning.'
		RAISERROR (@error_message, 16, 1)
	END

	IF EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = @meter_partition_schema)
	BEGIN	
	IF OBJECT_ID(@svc_table_name) IS NOT NULL 
		EXEC prtn_deploy_table 
				@svc_table_name, 
				N'id_source_sess ASC, id_partition ASC',
				@meter_partition_schema,
				N'id_partition' 
	END   
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT		
	SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()		
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
	ROLLBACK
END CATCH
