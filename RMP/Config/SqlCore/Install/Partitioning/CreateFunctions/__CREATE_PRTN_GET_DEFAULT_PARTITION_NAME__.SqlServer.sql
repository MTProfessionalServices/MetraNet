
				CREATE FUNCTION prtn_GetDefaultPartitionName ()
				RETURNS NVARCHAR(100)
				AS
				BEGIN
					RETURN DB_NAME() + '_Default'
				END
				