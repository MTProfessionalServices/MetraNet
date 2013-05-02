
CREATE FUNCTION String2Table (@array VARCHAR(MAX), @separator VARCHAR(10)) 
RETURNS @StringTable TABLE (item VARCHAR(255))
AS
BEGIN
  DECLARE @pattern VARCHAR(12)
  SET @pattern = '%' + @separator + '%'

	DECLARE @separator_position INT 
	DECLARE @array_item VARCHAR(255) 
	
	SET @array = @array + @separator
	
	WHILE PATINDEX(@pattern , @array) <> 0 
	BEGIN
	  SELECT @separator_position = PATINDEX(@pattern , @array)
	  SELECT @array_item = LEFT(@array, @separator_position - 1)
	  
	  IF LEN(@array_item) > 0
	  INSERT @StringTable VALUES (LTRIM(RTRIM(CAST(@array_item AS VARCHAR(255)))))

	  SELECT @array = STUFF(@array, 1, @separator_position + LEN(@separator) - 1, '')
	END

	RETURN
END
  