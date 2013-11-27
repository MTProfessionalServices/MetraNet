

      CREATE PROCEDURE Export_CreateANewSchedule
      @ScheduleType			VARCHAR(10),			/*  POSSIBLE VALUES ARE "Daily/Weekly/Monthly" ONLY */
      @ExecuteTime			CHAR(5),				/* format "HH:MM" in military */
      @RepeatHours			INT			= NULL,		/* hour number between repeats */
      @ExecuteStartTime		VARCHAR(5)	= NULL, 	/* format "HH:MM" in military (start and end time provide a pocket of execution hours) */
      @ExecuteEndTime			VARCHAR(5)	= NULL, 	/* format "HH:MM" in military */
      @SkipFirstDayOfMonth	BIT			= NULL,
      @SkipLastDayOfMonth		BIT			= NULL,
      @DaysInterval			INT			= NULL,
      @ExecuteWeekDays		VARCHAR(27) = NULL,		/*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN */
      @SkipWeekDays			VARCHAR(27) = NULL,		/*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN */
      @ExecuteMonthDay		INT			= NULL,		/*  Day of the month when to execute */
      @ExecuteFirstDayOfMonth	BIT			= NULL,		/*  Execute on the first day of the month */
      @ExecuteLastDayOfMonth	BIT			= NULL,		/*  Execute on the last day of the month */
      @SkipTheseMonths		VARCHAR(35)	= NULL,		/*  comma seperated set of months that have to be skipped for the monthly schedule executes */
      @monthtoDate			BIT		= NULL,
      @ValidateOnly			BIT			= NULL,
      @ScheduleId				INT			= NULL	OUTPUT	
      AS
      BEGIN
	      SET NOCOUNT ON

	      DECLARE @bResult BIT
	
	      SET @bResult = 0
	
	      IF ISNUMERIC(LEFT(@ExecuteTime, 2)) = 0
	      BEGIN
		      RAISERROR ('Invalid Execute Time Format - use HH:MM. Only Numeric values are allowed for HH and MM', 16, 1)
		      SET @bResult = 0
		      Return @bResult
	      END
	      ELSE
	      BEGIN
		      IF CAST(LEFT(@ExecuteTime, 2) AS INTEGER) > 24 OR CAST(LEFT(@ExecuteTime, 2) AS INTEGER) < 0
		      BEGIN
			      RAISERROR ('Invalid Execute Time Format - Value for HH cannot be greater than 24 or less than 0', 16, 1)
			      SET @bResult = 0
			      Return @bResult
		      END
	      END
	
	      IF ISNUMERIC(RIGHT(@ExecuteTime, 2)) = 0
	      BEGIN
		      RAISERROR ('Invalid Execute Time Format - use HH:MM. Only Numeric values are allowed for HH and MM', 16, 1)
		      SET @bResult = 0
		      Return @bResult
	      END
	      ELSE
	      BEGIN
		      IF CAST(RIGHT(@ExecuteTime, 2) AS INTEGER) > 60 OR CAST(RIGHT(@ExecuteTime, 2) AS INTEGER) < 0
		      BEGIN
			      RAISERROR ('Invalid Execute Time Format - Value for MM cannot be greater than 60 or less than 0', 16, 1)
			      SET @bResult = 0
			      Return @bResult
		      END
	      END

	      BEGIN TRANSACTION
	
	      SET @ValidateOnly = ISNULL(@ValidateOnly, 0)
	
	      IF @ScheduleType = 'daily'
	      BEGIN
		      IF EXISTS (	SELECT * FROM t_sch_daily 
					      WHERE	c_exec_time						= @ExecuteTime
					      AND		ISNULL(c_repeat_hour, 0)		= ISNULL(@RepeatHours, 0)
					      AND		ISNULL(c_exec_start_time, '')	= ISNULL(@ExecuteStartTime, '')
					      AND		ISNULL(c_exec_end_time, '')		= ISNULL(@ExecuteEndTime, '')
					      AND		c_skip_last_day_month			= ISNULL(@SkipLastDayOfMonth, 0)
					      AND		c_skip_first_day_month			= ISNULL(@SkipFirstDayOfMonth, 0)
					      AND		c_days_interval					= ISNULL(@DaysInterval, 1)
					      AND		c_month_to_date				= ISNULL(@monthtoDate, 0)
					      )
		      BEGIN
			      SELECT	@ScheduleId = id_schedule_daily
			      FROM	t_sch_daily
			      WHERE	c_exec_time						= @ExecuteTime
			      AND		ISNULL(c_repeat_hour, 0)		= ISNULL(@RepeatHours, 0)
			      AND		ISNULL(c_exec_start_time, '')	= ISNULL(@ExecuteStartTime, '')
			      AND		ISNULL(c_exec_end_time, '')		= ISNULL(@ExecuteEndTime, '')
			      AND		c_skip_last_day_month			= ISNULL(@SkipLastDayOfMonth, 0)
			      AND		c_skip_first_day_month			= ISNULL(@SkipFirstDayOfMonth, 0)
			      AND		c_days_interval					= ISNULL(@DaysInterval, 1)
			      AND		c_month_to_date				= ISNULL(@monthtoDate, 0)
			      SET @bResult = 1
		      END
		      ELSE
		      BEGIN
			      Execute @bResult = dbo.Export_CreateDailySchedule @ExecuteTime			= @ExecuteTime,
													      @RepeatHours			= @RepeatHours,
													      @ExecuteStartTime		= @ExecuteStartTime,
													      @ExecuteEndTime			= @ExecuteEndTime,
													      @SkipFirstDayOfMonth	= @SkipFirstDayOfMonth,
													      @SkipLastDayOfMonth		= @SkipLastDayOfMonth,
													      @DaysInterval			= @DaysInterval,
													      @monthtoDate			= @monthtoDate,
													      @ValidateOnly			= @ValidateOnly,
													      @ScheduleId				= @ScheduleId OUTPUT
		      END
	      END
	      ELSE IF @ScheduleType = 'weekly'
	      BEGIN
		      IF EXISTS (	SELECT * FROM t_sch_weekly
					      WHERE	c_exec_time						= @ExecuteTime
					      AND		ISNULL(c_exec_week_days, '')	= ISNULL(@ExecuteWeekDays, '')
					      AND		ISNULL(c_skip_week_days, '')	= ISNULL(@SkipWeekDays, '')
					      AND		c_month_to_date				= ISNULL(@monthtoDate, 0)
					      )
		      BEGIN	
			      SELECT	@ScheduleId = id_schedule_weekly
			      FROM	t_sch_weekly
			      WHERE	c_exec_time						= @ExecuteTime
			      AND		ISNULL(c_exec_week_days, '')	= ISNULL(@ExecuteWeekDays, '')
			      AND		ISNULL(c_skip_week_days, '')	= ISNULL(@SkipWeekDays, '')
			      AND		c_month_to_date				= ISNULL(@monthtoDate, 0)
			      SET @bResult = 1
		      END
		      ELSE
		      BEGIN
			      Execute @bResult = dbo.Export_CreateWeeklySchedule @ExecuteTime		= @ExecuteTime,
													      @ExecuteWeekDays		= @ExecuteWeekDays,
													      @SkipWeekDays			= @SkipWeekDays,
													      @monthtoDate			= @monthtoDate,
													      @ValidateOnly			= @ValidateOnly,
													      @ScheduleId				= @ScheduleId OUTPUT
		      END
	      END

	      ELSE IF @ScheduleType = 'monthly'
	      BEGIN
		      IF EXISTS (	SELECT * FROM t_sch_monthly
					      WHERE	c_exec_time					= @ExecuteTime
					      AND		ISNULL(c_exec_day, 0)		= ISNULL(@ExecuteMonthDay, 0)
					      AND		c_exec_first_month_day		= ISNULL(@ExecuteFirstDayOfMonth, 0)
					      AND		c_exec_last_month_day		= ISNULL(@ExecuteLastDayOfMonth, 0)
					      AND		ISNULL(c_skip_months, '')	= ISNULL(@SkipTheseMonths, '')
					      )
		      BEGIN
			      SELECT	@ScheduleId = id_schedule_monthly
			      FROM	t_sch_monthly
					      WHERE	c_exec_time					= @ExecuteTime
					      AND		ISNULL(c_exec_day, 0)		= ISNULL(@ExecuteMonthDay, 0)
					      AND		c_exec_first_month_day		= ISNULL(@ExecuteFirstDayOfMonth, 0)
					      AND		c_exec_last_month_day		= ISNULL(@ExecuteLastDayOfMonth, 0)
					      AND		ISNULL(c_skip_months, '')	= ISNULL(@SkipTheseMonths, '')			
			      SET @bResult = 1
		      END
		      ELSE
		      BEGIN
			      Execute @bResult = dbo.Export_CreateMonthlySchedule @ExecuteTime		= @ExecuteTime,
													      @ExecuteMonthDay		= @ExecuteMonthDay,
													      @ExecuteFirstDayOfMonth	= @ExecuteFirstDayOfMonth,
													      @ExecuteLastDayOfMonth	= @ExecuteLastDayOfMonth,
													      @SkipTheseMonths		= @SkipTheseMonths,
													      @ValidateOnly			= @ValidateOnly,
													      @ScheduleId				= @ScheduleId OUTPUT
		      END
	      END
	      IF @bResult = 0
		      ROLLBACK TRANSACTION
	      ELSE
		      COMMIT TRANSACTION
		
	      RETURN @bResult
      END
	 