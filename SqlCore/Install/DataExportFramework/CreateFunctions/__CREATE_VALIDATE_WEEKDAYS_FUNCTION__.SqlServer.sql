
      CREATE FUNCTION [ValidateWeekDays]
	      (
	      @InwkDays VARCHAR(28)
	      )
      RETURNS BIT
      AS
	      BEGIN
		      DECLARE @bResult BIT
		      SELECT	@bResult	= 0
		
		      IF SUBSTRING(@InwkDays, LEN(@InwkDays), 1) <> ','
			      SET @InwkDays = @InwkDays + ','

		      DECLARE @iPos INT, @iNextPos INT, @tmp VARCHAR(50)
		      SET @iPos = 1
		      SET @iNextPos = CHARINDEX(',', @InwkDays, @iPos)
		      WHILE @iNextPos > 0
		      BEGIN
			      SET @tmp = SUBSTRING(@InwkDays, @iPos, (@iNextPos - @iPos))
			      SELECT @bResult = dbo.ValidateWeekDay(@tmp)
			      IF @bResult = 0
				      BREAK
			      ELSE
			      BEGIN
				      SET @iPos = @iNextPos + 1
				      SET @iNextPos = CHARINDEX(',', @InwkDays, @iPos)
			      END
		      END


	      RETURN @bResult
	      END
		