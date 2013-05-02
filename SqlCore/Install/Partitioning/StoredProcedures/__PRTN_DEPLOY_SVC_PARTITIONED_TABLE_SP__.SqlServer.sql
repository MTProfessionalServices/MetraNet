CREATE PROCEDURE prtn_DeployServiceDefinitionPartitionedTable
		@svc_table_name VARCHAR(32)
AS
BEGIN
    DECLARE @meter_partition_schema NVARCHAR(50)
	BEGIN TRY
		IF dbo.IsSystemPartitioned() = 0
			RETURN
			
		SET @meter_partition_schema = dbo.prtn_GetMeterPartitionSchemaName()
		
		IF EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = @meter_partition_schema)
		BEGIN	
		IF OBJECT_ID(@svc_table_name) IS NOT NULL 
			EXEC prtn_CreatePartitionedTable 
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
END