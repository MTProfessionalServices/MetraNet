
      CREATE FUNCTION [ValidateMonths]
	      (
	      @InMonths VARCHAR(35)
	      )
      RETURNS BIT
      AS
	      BEGIN
		      DECLARE @bResult BIT
		      SELECT	@bResult	= 0
		
		      IF SUBSTRING(@InMonths, LEN(@InMonths), 1) <> ','
			      SET @InMonths = @InMonths + ','

		      DECLARE @iPos INT, @iNextPos INT, @tmp VARCHAR(50)
		      SET @iPos = 1
		      SET @iNextPos = CHARINDEX(',', @InMonths, @iPos)
		      WHILE @iNextPos > 0
		      BEGIN
			      SET @tmp = SUBSTRING(@InMonths, @iPos, (@iNextPos - @iPos))
			      SELECT @bResult = dbo.ValidateMonth(CAST(@tmp AS INT))
			      IF @bResult = 0
				      BREAK
			      ELSE
			      BEGIN
				      SET @iPos = @iNextPos + 1
				      SET @iNextPos = CHARINDEX(',', @InMonths, @iPos)
			      END
		      END		


	      RETURN @bResult
	      END
		