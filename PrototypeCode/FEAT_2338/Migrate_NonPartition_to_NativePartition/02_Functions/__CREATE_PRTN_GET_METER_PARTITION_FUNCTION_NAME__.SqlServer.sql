IF OBJECT_ID('prtn_GetMeterPartitionFunctionName') IS NOT NULL 
DROP FUNCTION  prtn_GetMeterPartitionFunctionName
GO
				CREATE FUNCTION prtn_GetMeterPartitionFunctionName ()
				RETURNS varchar(50)
				AS
				BEGIN
					RETURN 'MeterPartitionFunction'
				END
				