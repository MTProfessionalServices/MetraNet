
CREATE FUNCTION SplitStringByChar(@Str nvarchar(256), @Delimiter char(1))

RETURNS @Results TABLE (Items nvarchar(256))
AS BEGIN
	DECLARE @start int
	SET @start = 0
	DECLARE @end int
	SET @end = -1

	DECLARE @Slice nvarchar(256)
	WHILE @end <> len(@Str) + 1
		BEGIN
			IF(@end < 0)
			begin
				SET @end = @start
			end
			
			SET @start = @end + 1
			
			SET @end = charindex(@Delimiter, @Str, @start)
			IF(@end = 0)
				SET @end = len(@Str) + 1
			
			SET @Slice = substring(@Str, @start, @end - @start)
			INSERT INTO @Results(Items) VALUES(@Slice)
		END
	RETURN
END