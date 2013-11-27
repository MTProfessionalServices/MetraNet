IF OBJECT_ID('prtn_GetMeterPartitionSchemaName') IS NOT NULL 
DROP FUNCTION prtn_GetMeterPartitionSchemaName
GO
				CREATE FUNCTION prtn_GetMeterPartitionSchemaName ()
				RETURNS varchar(50)
				AS
				BEGIN
					RETURN 'MeterPartitionSchema'
				END