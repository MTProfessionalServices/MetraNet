
      CREATE PROCEDURE Export_CreateDailySchedule
      @ExecuteTime			CHAR(5),				/* format "HH:MM" in military */
      @RepeatHours			INT = NULL,				/*  hour number between repeats */
      @ExecuteStartTime		VARCHAR(5)	= NULL, 	/*  format "HH:MM" in military (start and end time provide a pocket of execution hours) */
      @ExecuteEndTime			VARCHAR(5)	= NULL, 	/*  format "HH:MM" in military */
      @SkipFirstDayOfMonth	BIT			= NULL,
      @SkipLastDayOfMonth		BIT			= NULL,
      @DaysInterval			INT			= NULL,
      @monthtoDate			BIT			= NULL,
      @ValidateOnly			BIT			= NULL,
      @ScheduleId				INT			= NULL	OUTPUT	
      AS
      BEGIN
	      SET NOCOUNT ON 
	
	      DECLARE @bResult BIT
	
	      SELECT @bResult = 1, @ScheduleId = 0
	
	      SET @ValidateOnly = ISNULL(@ValidateOnly, 0)
	      
	      /*IF LEN(ISNULL(@ExecuteStartTime, '')) > 0 AND LEN(ISNULL(@ExecuteEndTime, '')) = 0
	      BEGIN
		      RAISERROR ('No Corresponding Execute End Time provided for the Execute Start Time', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END
	      */
	
	      IF LEN(ISNULL(@ExecuteStartTime, '')) = 0 AND LEN(ISNULL(@ExecuteEndTime, '')) > 0
	      BEGIN
		      RAISERROR ('No Corresponding Execute Start Time provided for the Execute End Time', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END

	      IF LEN(ISNULL(@ExecuteStartTime, '')) = 0 AND LEN(ISNULL(@ExecuteTime, '')) = 0
	      BEGIN
		      RAISERROR ('Invalid Schedule! No Execute Time provided.', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END

	      IF LEN(ISNULL(@ExecuteStartTime, '')) > 0
	      BEGIN
		      /* Validate execute time value */
		      IF DATEDIFF(s, CONVERT(smalldatetime, @ExecuteStartTime), CONVERT(smalldatetime, @ExecuteTime)) < 0
		      BEGIN
			      RAISERROR ('Execute Time should be equal to or greater than Execute Start Time', 16, 1)
			      SET @bResult = 0
			      RETURN @bResult
		      END
	      END
	
	      IF ISNULL(@DaysInterval, 0) > 0
	      BEGIN
		      IF @DaysInterval >= 7
		      BEGIN
			      RAISERROR ('Execute Days Interval is >= 7. Setup a Weekly Schedule for this', 16, 1)
			      SET @bResult = 0
			      RETURN @bResult
		      END
	      END
	
	      IF ISNULL(@RepeatHours, 0) > 24
	      BEGIN
		      RAISERROR ('Cannot have repeat hours greater than 24, use DaysInterval instead.', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END
	

	      IF (@ValidateOnly = 0)
	      BEGIN
		      INSERT INTO t_sch_daily (	c_exec_time, c_repeat_hour, c_exec_start_time,
									      c_exec_end_time, c_skip_last_day_month, c_skip_first_day_month,
									      c_days_interval, c_month_to_date)
		      VALUES					(@ExecuteTime, ISNULL(@RepeatHours, 0), @ExecuteStartTime,
									      @ExecuteEndTime, ISNULL(@SkipFirstDayOfMonth, 0), ISNULL(@SkipLastDayOfMonth, 0),
									      ISNULL(@DaysInterval, 1), ISNULL(@monthtoDate, 0))
		      SELECT @ScheduleId = SCOPE_IDENTITY()
	      END
	
	      RETURN (@bResult)
      END
	 