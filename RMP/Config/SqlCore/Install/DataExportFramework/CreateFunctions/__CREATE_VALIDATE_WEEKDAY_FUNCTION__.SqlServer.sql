
      CREATE FUNCTION [ValidateWeekDay]
	      (
	      @InwkDay VARCHAR(3)	
	      )
      RETURNS BIT
      AS
	      BEGIN
		      DECLARE @bResult BIT, @wkDays VARCHAR(28)
		
		      SELECT	@bResult	= 0, 
				      @wkDays		= 'MON,TUE,WED,THU,FRI,SAT,SUN,'
		
		
		      DECLARE @iPos INT, @iNextPos INT, @tmp VARCHAR(50)
		
		      SET @iPos = 1
		      SET @iNextPos = CHARINDEX(',', @wkDays, @iPos)
		      WHILE @iNextPos > 0
		      BEGIN
			      SET @tmp = SUBSTRING(@wkDays, @iPos, (@iNextPos - @iPos))
			      /* SELECT @tmp */
			      IF @tmp = @InwkDay
			      BEGIN
				      SET @bResult = 1
				      BREAK
			      END
			      ELSE
			      BEGIN
				      SET @iPos = @iNextPos + 1
				      SET @iNextPos = CHARINDEX(',', @wkDays, @iPos)
			      END
		      END

	      RETURN @bResult
	      END
		