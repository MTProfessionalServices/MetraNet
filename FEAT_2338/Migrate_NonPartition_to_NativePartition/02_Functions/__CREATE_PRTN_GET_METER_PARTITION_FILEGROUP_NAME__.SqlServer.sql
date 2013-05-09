IF OBJECT_ID('prtn_GetMeterPartitionFileGroupName') IS NOT NULL 
DROP FUNCTION  prtn_GetMeterPartitionFileGroupName
GO
				CREATE FUNCTION prtn_GetMeterPartitionFileGroupName ()
				RETURNS NVARCHAR(100)
				AS
				BEGIN
					RETURN 'MeterFileGroup'
				END
				