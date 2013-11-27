
      CREATE FUNCTION [ValidateMonth]
	      (
		      @InMonth INT
	      )
      RETURNS BIT
      AS
	      BEGIN
		      DECLARE @bResult BIT, @months VARCHAR(36)
		
		      SELECT	@bResult	= 0, 
				      @months		= '01,02,03,04,05,06,07,08,09,10,11,12,'
		
		
		      DECLARE @iPos INT, @iNextPos INT, @tmp VARCHAR(50)
		
		      SET @iPos = 1
		      SET @iNextPos = CHARINDEX(',', @months, @iPos)
		      WHILE @iNextPos > 0
		      BEGIN
			      SET @tmp = SUBSTRING(@months, @iPos, (@iNextPos - @iPos))
			      /* SELECT @tmp */
			      IF CAST(@tmp AS INT) = @InMonth
			      BEGIN
				      SET @bResult = 1
				      BREAK
			      END
			      ELSE
			      BEGIN
				      SET @iPos = @iNextPos + 1
				      SET @iNextPos = CHARINDEX(',', @months, @iPos)
			      END
		      END

	      RETURN @bResult
	      END
		