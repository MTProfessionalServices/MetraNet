CREATE FUNCTION MTMaxOfThreeDates
(
	@date1  DATETIME,
	@date2  DATETIME,
	@date3  DATETIME
)
RETURNS DATETIME
BEGIN
	RETURN dbo.MTMaxOfTwoDates(@date1, dbo.MTMaxOfTwoDates(@date2, @date3))
END