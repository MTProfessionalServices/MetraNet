
				CREATE FUNCTION prtn_GetMeterPartitionFunctionName ()
				RETURNS varchar(50)
				AS
				BEGIN
					RETURN 'MeterPartitionFunction'
				END
				