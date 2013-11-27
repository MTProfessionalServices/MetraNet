IF OBJECT_ID('prtn_GetDefaultPartitionName') IS NOT NULL 
DROP FUNCTION  prtn_GetDefaultPartitionName
GO
				CREATE FUNCTION prtn_GetDefaultPartitionName ()
				RETURNS NVARCHAR(100)
				AS
				BEGIN
					RETURN DB_NAME() + '_Default'
				END
				