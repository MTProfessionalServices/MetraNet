
				CREATE FUNCTION prtn_GetMeterPartitionFileGroupName ()
				RETURNS NVARCHAR(100)
				AS
				BEGIN
					RETURN DB_NAME() + '_MeterFileGroup'
				END
				