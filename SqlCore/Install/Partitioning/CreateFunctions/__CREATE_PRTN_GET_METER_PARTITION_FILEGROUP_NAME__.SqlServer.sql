
				CREATE FUNCTION prtn_GetMeterPartitionFileGroupName ()
				RETURNS NVARCHAR(100)
				AS
				BEGIN
					RETURN 'MeterFileGroup'
				END
				