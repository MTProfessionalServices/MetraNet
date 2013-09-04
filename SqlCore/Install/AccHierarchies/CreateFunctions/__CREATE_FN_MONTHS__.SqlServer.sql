CREATE FUNCTION fn_months
(	
)
RETURNS 
@res TABLE (
	num INTEGER NOT NULL,
	name NVARCHAR(50) NOT NULL PRIMARY KEY
)
AS
BEGIN 
	INSERT INTO @res(num, name)
		SELECT 1  as num, 'January'   as name UNION ALL
		SELECT 2  as num, 'February'  as name UNION ALL
		SELECT 3  as num, 'March'     as name UNION ALL
		SELECT 4  as num, 'April'     as name UNION ALL
		SELECT 5  as num, 'May'       as name UNION ALL
		SELECT 6  as num, 'June'      as name UNION ALL
		SELECT 7  as num, 'July'      as name UNION ALL
		SELECT 8  as num, 'August'    as name UNION ALL
		SELECT 9  as num, 'September' as name UNION ALL
		SELECT 10 as num, 'October'   as name UNION ALL
		SELECT 11 as num, 'November'  as name UNION ALL
		SELECT 12 as num, 'December'  as name

	RETURN
END
