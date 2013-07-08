IF OBJECT_ID('prtn_GetUsagePartitionFunctionName') IS NOT NULL 
DROP FUNCTION prtn_GetUsagePartitionFunctionName
GO
				CREATE FUNCTION prtn_GetUsagePartitionFunctionName ()
				RETURNS varchar(50)
				AS
				BEGIN
					RETURN 'UsagePartitionFunction'
				END
				