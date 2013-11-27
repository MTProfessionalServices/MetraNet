
CREATE FUNCTION GreatestDate(@val1 datetime, @val2 datetime) RETURNS datetime
AS
BEGIN
	RETURN CASE WHEN @val1 > @val2 THEN @val1 WHEN @val2 IS NULL THEN @val1 ELSE @val2 END
END
