
      CREATE FUNCTION [GenerateNextRunTime_Daily]
	      (
		      @dtNow					DATETIME,
		      @ExecuteTime			CHAR(5),				/* format "HH:MM" in military */
		      @RepeatHours			INT			= NULL,		/* hour number between repeats */
		      @ExecuteStartTime		VARCHAR(5)	= NULL, 	/* format "HH:MM" in military (start and end time provide a pocket of execution hours) */
		      @ExecuteEndTime			VARCHAR(5)	= NULL, 	/* format "HH:MM" in military */
		      @SkipFirstDayOfMonth	BIT			= NULL,
		      @SkipLastDayOfMonth		BIT			= NULL,
		      @DaysInterval			INT			= NULL
	      )
      RETURNS DATETIME
      AS
	      BEGIN
		      DECLARE @dtNext DATETIME
		
	      SELECT	@DaysInterval	= ISNULL(@DaysInterval, 1),
			      @ExecuteEndTime = ISNULL(@ExecuteEndTime, '11:59')
	
	
	      IF ISNULL(@RepeatHours, 0) = 0
	      BEGIN
		      DECLARE @tdt DATETIME
		      SET @tdt =	CAST(CAST(DATEPART(mm, @dtNow) AS VARCHAR) 
					      + '/' + CAST(DATEPART(dd, @dtNow) AS VARCHAR)
					      + '/' + CAST(DATEPART(yy, @dtNow) AS VARCHAR) AS DATETIME)
		      SET @dtNext = dbo.AddTimeToDate(@tdt, @ExecuteTime)
		      SET @dtNext = DATEADD(dd, @DaysInterval, @dtNext)
		      /* RETURN @dtNext */
	      END
	      ELSE
	      BEGIN
		      SET @dtNext = @dtNow
		      SET @dtNext = DATEADD(hh, @RepeatHours, @dtNext)
		      DECLARE @dtExecuteStartTime DATETIME, @dtExecuteEndTime DATETIME
		      DECLARE @tmpDate DATETIME
		      IF LEN(ISNULL(@ExecuteStartTime, '')) > 0
		      BEGIN
			      SET @tmpDate = CAST(CAST(DATEPART(m, @dtNow) AS VARCHAR) 
							      + '/'+ CAST(DATEPART(d, @dtNow) AS VARCHAR)
							      + '/'+ CAST(DATEPART(yy, @dtNow) AS VARCHAR) AS DATETIME)
			
			      SELECT @dtExecuteStartTime = dbo.AddTimeToDate(@tmpDate, @ExecuteStartTime)
			
			      IF LEN(ISNULL(@ExecuteEndTime, '')) > 0
			      BEGIN
				      SELECT @dtExecuteEndTime = dbo.AddTimeToDate(@tmpDate, @ExecuteEndTime)
				      /* SELECT @dtExecuteEndTime, @dtExecuteStartTime, @dtNext */
				
				      IF DATEDIFF(ss, @dtExecuteStartTime, @dtNext) > 0
				      BEGIN
					      IF DATEDIFF(ss, @dtExecuteEndTime, @dtNext) < 0
					      BEGIN
						      /* same day repeat run... */ 
						      /* SELECT 'IN HERE' */
						      /* RETURN @dtNext */
						      SET @dtNext = @dtNext
					      END
					      ELSE
					      BEGIN
						      /* since the new time falls outside the pocket - after end time, it will run at the next start time (pocket upper bound time) */
						      /* also the next run will be after the "daysInterval" has elapsed */
						      SET @dtNext = DATEADD(dd, @DaysInterval, @dtExecuteStartTime) 
						      /* RETURN @dtNext */
					      END
				      END
				      ELSE
				      BEGIN
					      /* new time falls outside the pocket - before exec start date */ 
					      /* use the exec start time as next run time adding daysinterval */
					      SET @dtNext = DATEADD(dd, @DaysInterval, @dtExecuteStartTime)
					      /* RETURN @dtNext */
				      END
			      END
			      ELSE
			      BEGIN
				      /* no end time is provided - just add the repeat hours */ 
				      /* check if the result date is on the next day and if YES, add days interval and set next run datetime */
				      IF (DAY(@dtNext) > DAY(@dtNow) OR MONTH(@dtNext) > MONTH(@dtNow) OR YEAR(@dtNext) > YEAR(@dtNow)) AND (@DaysInterval >= 1)
				      BEGIN
					      SET @dtNext = DATEADD(dd, @DaysInterval, @dtExecuteStartTime)
					      /* RETURN @dtNext */
				      END
				      ELSE
				      BEGIN
					      /* RETURN @dtNext */
					      SET @dtNext = @dtNext
				      END
			      END
		      END
		      ELSE
		      BEGIN
			      /* No pocket provided - just add hours */
			      /* check if the result date is on the next day and if YES, add days interval and set next run datetime */
			      IF (DAY(@dtNext) > DAY(@dtNow) OR MONTH(@dtNext) > MONTH(@dtNow) OR YEAR(@dtNext) > YEAR(@dtNow)) AND (@DaysInterval >= 1)
			      BEGIN
				      SET @tmpDate = CAST(CAST(DATEPART(m, @dtNext) AS VARCHAR) 
						      + '/'+ CAST(DATEPART(d, @dtNext) AS VARCHAR)
						      + '/'+ CAST(DATEPART(yy, @dtNext) AS VARCHAR) AS DATETIME)

				      SELECT @dtNext = dbo.AddTimeToDate(@tmpDate, @ExecuteTime)
				      /* RETURN @dtNext */
			      END
			      ELSE
				      /* RETURN @dtNext */
				      SET @dtNext = @dtNext
		      END
	      END
	
	      IF ISNULL(@SkipLastDayOfMonth, 0) > 0 AND (MONTH(DATEADD(dd, 1, @dtNext)) > MONTH(@dtNext) OR YEAR(DATEADD(dd, 1, @dtNext)) > YEAR(@dtNext))
	      BEGIN
		      SET @dtNext = DATEADD(dd, 1, @dtNext)
	      END


	      IF (ISNULL(@SkipFirstDayOfMonth, 0) > 0 AND DAY(@dtNext) = 1) 
	      BEGIN
		      SET @dtNext = DATEADD(dd, 1, @dtNext)
	      END

	      RETURN @dtNext
	      END
		