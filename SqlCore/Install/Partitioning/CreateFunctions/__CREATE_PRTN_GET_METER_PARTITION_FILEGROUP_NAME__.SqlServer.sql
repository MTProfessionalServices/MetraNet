CREATE FUNCTION prtn_GetMeterPartitionFileGroupName ()
/* Short prtn_GetMeterPartFileGroupName function name uses in Oracle */
RETURNS NVARCHAR(100)
AS
BEGIN
	RETURN DB_NAME() + '_MeterFileGroup'
END
