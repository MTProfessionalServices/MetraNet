

      CREATE PROCEDURE Export_SetReprtInstNextRunDate
      @ReportInstanceId	INT,
      @ScheduleId			INT,
      @ScheduleType		VARCHAR(10),
      @dtNow				DATETIME,
      @dtstart			DATETIME
      AS
      BEGIN
	      SET NOCOUNT ON

	      DECLARE @bResult INT, @monthtoDate BIT
	
	      /* IF @dtNow < GETDATE()
	      	SET @dtNow = DATEADD(dd, -1, GETDATE()) */

	      IF @ScheduleType NOT IN ('daily', 'weekly', 'monthly')
	      BEGIN
		      RAISERROR ('Invalid Schedule Type!', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END
		
	      DECLARE @ExecuteTime			CHAR(5),		/*  format "HH:MM" in military */
			      @RepeatHours			INT			,	/*  hour number between repeats */
			      @ExecuteStartTime		VARCHAR(5)	, 	/*  format "HH:MM" in military (start and end time provide a pocket of execution hours) */
			      @ExecuteEndTime			VARCHAR(5)	, 	/*  format "HH:MM" in military */
			      @SkipFirstDayOfMonth	BIT			,
			      @SkipLastDayOfMonth		BIT			,
			      @DaysInterval			INT			,
			      @ExecWeekDays			VARCHAR(27) ,
			      @SkipWeekDays			VARCHAR(27)	,
			      @ExecuteMonthDay		INT			,	/*  Day of the month when to execute */
			      @ExecuteFirstDayOfMonth	BIT			,	/*  Execute on the first day of the month */
			      @ExecuteLastDayOfMonth	BIT			,	/*  Execute on the last day of the month */
			      @SkipTheseMonths		VARCHAR(35),
			      @dtNext			DATETIME

	
	
	      IF @ScheduleType = 'daily'
	      BEGIN
		      SELECT		@ExecuteTime = sd.c_exec_time, @RepeatHours = sd.c_repeat_hour, 
					      @ExecuteStartTime = sd.c_exec_start_time, @ExecuteEndTime = sd.c_exec_end_time, 
					      @SkipLastDayOfMonth = sd.c_skip_last_day_month, @SkipFirstDayOfMonth = sd.c_skip_first_day_month, 
					      @DaysInterval = sd.c_days_interval, @monthtoDate = c_month_to_date
		      FROM		t_export_schedule s 
		      INNER JOIN	t_sch_daily sd ON s.id_schedule = sd.id_schedule_daily
		      WHERE		s.id_rep_instance_id	= @ReportInstanceId
		      AND			s.id_schedule			= @ScheduleId
		      AND			s.c_sch_type			= @ScheduleType
		
		      SELECT @dtNext = dbo.GenerateNextRunTime_Daily (@dtStart, @ExecuteTime, @RepeatHours, @ExecuteStartTime, @ExecuteEndTime, @SkipFirstDayOfMonth, @SkipLastDayOfMonth, @DaysInterval)
	      END
	      ELSE IF @ScheduleType = 'weekly'
	      BEGIN
		      SELECT		@ExecuteTime = sw.c_exec_time, @ExecWeekDays = sw.c_exec_week_days, 
					      @SkipWeekDays = sw.c_skip_week_days, @monthtoDate = c_month_to_date
		      FROM		t_export_schedule s 
		      INNER JOIN	t_sch_weekly sw ON s.id_schedule = sw.id_schedule_weekly
		      WHERE		s.id_rep_instance_id	= @ReportInstanceId
		      AND			s.id_schedule			= @ScheduleId
		      AND			s.c_sch_type			= @ScheduleType
		
		      IF LEN(@SkipWeekDays) = 0
			      SET @SkipWeekDays = NULL
		      SELECT @dtNext = dbo.GenerateNextRunTime_Weekly(@dtStart, @ExecuteTime,  @ExecWeekDays, @SkipWeekDays)
	      END
	      ELSE IF @ScheduleType = 'monthly'
	      BEGIN
		      SELECT		@ExecuteMonthDay = sm.c_exec_day, @ExecuteTime = sm.c_exec_time, 
					      @ExecuteFirstDayOfMonth = sm.c_exec_first_month_day, 
					      @ExecuteLastDayOfMonth = sm.c_exec_last_month_day, 
					      @SkipTheseMonths = sm.c_skip_months
		      FROM		t_export_schedule s 
		      INNER JOIN	t_sch_monthly sm ON s.id_schedule = sm.id_schedule_monthly
		      WHERE		s.id_rep_instance_id	= @ReportInstanceId
		      AND			s.id_schedule			= @ScheduleId
		      AND			s.c_sch_type			= @ScheduleType

		      IF LEN(@SkipTheseMonths) = 0
			      SET @SkipTheseMonths = NULL
		      SELECT @dtNext = dbo.GenerateNextRunTime_Monthly(@dtStart, @ExecuteTime,  @ExecuteMonthDay, @ExecuteFirstDayOfMonth, @ExecuteLastDayOfMonth, @SkipTheseMonths)
	      END

	      IF isnull(@monthtoDate, 0) = 1
		      SET @dtStart = CAST(CAST(MONTH(@dtNext) AS VARCHAR)+'/01/'+CAST(YEAR(@dtNext) AS VARCHAR) AS DATETIME)

	      UPDATE 	t_export_report_instance 
		      SET 	dt_Next_run = @dtNext,
			      dt_last_run = @dtstart
	      WHERE 	id_rep_instance_id = @ReportInstanceId 
	
	      RETURN 0
      END
	