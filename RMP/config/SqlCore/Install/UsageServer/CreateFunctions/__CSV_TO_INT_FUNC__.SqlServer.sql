
CREATE FUNCTION CSVToInt (@array VARCHAR(4000)) 
RETURNS @IntTable TABLE (value INT)
AS
BEGIN
  DECLARE @separator CHAR(1)
  SET @separator = ','

	DECLARE @separator_position INT 
	DECLARE @array_value VARCHAR(100) 
	
	SET @array = @array + ','
	
	WHILE PATINDEX('%,%' , @array) <> 0 
	BEGIN
	  SELECT @separator_position = PATINDEX('%,%' , @array)
	  SELECT @array_value = LEFT(@array, @separator_position - 1)
	
		INSERT @IntTable
		VALUES (CAST(@array_value AS INT))

	  SELECT @array = STUFF(@array, 1, @separator_position, '')
	END

	RETURN
END
  