
      CREATE FUNCTION [GenerateNextRunTime_Weekly]
	      (
		      @dtNow					DATETIME,
		      @ExecuteTime			CHAR(5),				/* format "HH:MM" in military */
		      @ExecWeekDays			VARCHAR(27) = NULL,
		      @SkipWeekDays			VARCHAR(27) = NULL
	      )
      RETURNS DATETIME
      AS
	      BEGIN
		      DECLARE @dtNext DATETIME, @bValid BIT, @iDay INT, @bResult BIT, 
				      @iPos INT, @iNextPos INT, @tmp VARCHAR(50), @tdt DATETIME,
				      @iPosSkip INT, @iNextPosSkip INT, @tmpSkip VARCHAR(50)
		
		      SELECT @bValid = 0
		
		      IF SUBSTRING(@ExecWeekDays, LEN(@ExecWeekDays), 1) <> ','
			      SET @ExecWeekDays = @ExecWeekDays + ','

		      IF SUBSTRING(@SkipWeekDays, LEN(@SkipWeekDays), 1) <> ','
			      SET @SkipWeekDays = @SkipWeekDays + ','

		      SET @tdt =	CAST(CAST(DATEPART(mm, @dtNow) AS VARCHAR) 
			      + '/' + CAST(DATEPART(dd, @dtNow) AS VARCHAR)
			      + '/' + CAST(DATEPART(yy, @dtNow) AS VARCHAR) AS DATETIME)
		      SET @dtNow = dbo.AddTimeToDate(@tdt, @ExecuteTime)
		      SELECT @dtNext = @dtNow
		      IF LEN(ISNULL(@ExecWeekDays, '')) > 0
		      BEGIN
			      SET @iDay = 1
			      WHILE @iDay <= 7
			      BEGIN
				      SET @tdt = DATEADD(dd, @iDay, @dtNow)
				      SET @iPos = 1
				      SET @iNextPos = CHARINDEX(',', @ExecWeekDays, @iPos)
				      WHILE @iNextPos > 0
				      BEGIN
					      SET @tmp = SUBSTRING(@ExecWeekDays, @iPos, (@iNextPos - @iPos))
					      SELECT @bResult = dbo.ValidateWeekDay(@tmp)
					      IF @bResult = 0
					      BEGIN
						      SET @bValid = -1
						      SET @dtNext = NULL
						      BREAK
					      END
					      ELSE
					      BEGIN
						      IF LEFT(DATENAME(dw, @tdt), 3) = @tmp
						      BEGIN
							      SELECT @dtNext = @tdt, @bValid = 1
							      BREAK
						      END
						      SET @iPos = @iNextPos + 1
						      SET @iNextPos = CHARINDEX(',', @ExecWeekDays, @iPos)
					      END
				      END
				      IF @bValid < 0 
					      BEGIN
						      SET @dtNext = NULL
					      END
					      /* RAISERROR ('Invalid Execute week days', 16, 1) */
				      ELSE
				      BEGIN
					      SET @iPosSkip = 1
					      SET @iNextPosSkip = CHARINDEX(',', @SkipWeekDays, @iPosSkip)
					      WHILE @iNextPosSkip > 0
					      BEGIN
						      SET @tmpSkip = SUBSTRING(@SkipWeekDays, @iPosSkip, (@iNextPosSkip - @iPosSkip))
						      SELECT @bResult = dbo.ValidateWeekDay(@tmpSkip)
						      IF @bResult = 0
						      BEGIN
							      SET @bValid = -1
							      SET @dtNext = NULL
							      BREAK
						      END
						      ELSE
						      BEGIN
							      IF LEFT(DATENAME(dw, @dtNext), 3) = @tmpSkip
							      BEGIN
								      SET @bValid = 0
								      BREAK
							      END
							      SET @iPosSkip = @iNextPosSkip + 1
							      SET @iNextPosSkip = CHARINDEX(',', @SkipWeekDays, @iPosSkip)
						      END
					      END
				      IF @bValid > 0
					      BREAK
				      END
				      SET @iDay = @iDay + 1
			      END
		      END
		      ELSE
			      SET @dtNext = DATEADD(dd, 7, @dtNow)

		      RETURN @dtNext


	      END
		