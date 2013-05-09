IF OBJECT_ID('prtn_GetUsagePartitionSchemaName') IS NOT NULL 
DROP FUNCTION prtn_GetUsagePartitionSchemaName
GO
		
				CREATE FUNCTION prtn_GetUsagePartitionSchemaName ()
				RETURNS varchar(50)
				AS
				BEGIN
					RETURN 'UsagePartitionSchema'
				END
				