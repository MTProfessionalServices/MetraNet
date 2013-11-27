CREATE PROCEDURE prtn_deploy_usage_table
	@table_name VARCHAR(200)
AS
BEGIN
	DECLARE @usage_partition_scheme  VARCHAR(100),
	        @error_message           VARCHAR(300)
	BEGIN TRY
		SET @usage_partition_scheme = dbo.prtn_GetUsagePartitionSchemaName()

		IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @table_name AND COLUMN_NAME = 'id_sess' )
		BEGIN
		    SET @error_message = 'Table "' + @table_name  + '" suggests to have column "id_sess" as a part of PK. This field is required for partitioning.'
		    RAISERROR (@error_message, 16, 1)
		END
		EXEC prtn_deploy_table 
		     @partition_table_name = @table_name,
		     @pk_columns = N'id_sess, id_usage_interval',
		     @partition_schema = @usage_partition_scheme,
		     @partition_column = 'id_usage_interval',
		     @apply_uk_tables = 1
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT		
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()		
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
		ROLLBACK
	END CATCH
END
