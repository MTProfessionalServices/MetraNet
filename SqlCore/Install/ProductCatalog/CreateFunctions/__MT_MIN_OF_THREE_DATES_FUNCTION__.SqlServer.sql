CREATE FUNCTION MTMinOfThreeDates
(
	@date1  DATETIME,
	@date2  DATETIME,
	@date3  DATETIME
)
RETURNS DATETIME
BEGIN
	RETURN dbo.MTMinOfTwoDates(@date1, dbo.MTMinOfTwoDates(@date2, @date3))
END