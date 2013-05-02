
      CREATE FUNCTION [AddTimeToDate]
	      (
	      @dt		DATETIME,
	      @time	CHAR(5)
	      )
      RETURNS DATETIME
      AS
	      BEGIN
		      DECLARE @tdt DATETIME, @hours INT, @minutes INT, @ipos INT, @inextpos INT
		      SELECT @ipos = 0, @inextpos = 0
		      SELECT @inextpos = CHARINDEX(':', @time, @ipos)
		      SELECT @hours = SUBSTRING(@time, @ipos, @inextpos - @ipos)
		      SELECT @minutes = SUBSTRING(@time, @inextpos+1, len(@time))


		
		      SET @tdt = CAST(CAST(DATEPART(mm, @dt) AS VARCHAR) 
			      + '/' + CAST(DATEPART(dd, @dt) AS VARCHAR)
			      + '/' + CAST(DATEPART(yy, @dt) AS VARCHAR)
			      + ' ' 
			      +  CAST(@hours AS VARCHAR) + ':'
			      +  CAST(@minutes AS VARCHAR) AS DATETIME)
		
	      RETURN @tdt
	      END
		