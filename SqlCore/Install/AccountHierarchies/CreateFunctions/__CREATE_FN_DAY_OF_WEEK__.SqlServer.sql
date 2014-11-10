CREATE FUNCTION fn_day_of_week
(	
)
RETURNS @res TABLE
(
	num INTEGER NOT NULL
	,name NVARCHAR(50) NOT NULL PRIMARY KEY
)
AS
BEGIN 
	INSERT INTO @res (num, name)
		SELECT 1  as NUM, 'Sunday'    as NAME UNION ALL
		SELECT 2  as NUM, 'Monday'    as NAME UNION ALL
		SELECT 3  as NUM, 'Tuesday'   as NAME UNION ALL
		SELECT 4  as NUM, 'Wednesday' as NAME UNION ALL
		SELECT 5  as NUM, 'Thursday'  as NAME UNION ALL
		SELECT 6  as NUM, 'Friday'    as NAME UNION ALL
		SELECT 7  as NUM, 'Saturday'  as NAME
	RETURN
END
