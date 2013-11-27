

      CREATE PROCEDURE Export_ScheduleReportInstance
      @ReportInstanceId		INT,
      @ScheduleType			VARCHAR(10),			/* POSSIBLE VALUES ARE "Daily/Weekly/Monthly" ONLY */
      @ExecuteTime			CHAR(5),				/*  format "HH:MM" in military */
      @RepeatHours			INT			= NULL,		/*  hour number between repeats */
      @ExecuteStartTime		VARCHAR(5)	= NULL, 	/*  format "HH:MM" in military (start and end time provide a pocket of execution hours) */
      @ExecuteEndTime			VARCHAR(5)	= NULL, 	/*  format "HH:MM" in military */
      @SkipFirstDayOfMonth	BIT			= NULL,
      @SkipLastDayOfMonth		BIT			= NULL,
      @DaysInterval			INT			= NULL,
      @ExecuteWeekDays		VARCHAR(27) = NULL,		/*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN */
      @SkipWeekDays			VARCHAR(27) = NULL,		/*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN */
      @ExecuteMonthDay		INT			= NULL,		/*  Day of the month when to execute */
      @ExecuteFirstDayOfMonth	BIT			= NULL,		/*  Execute on the first day of the month */
      @ExecuteLastDayOfMonth	BIT			= NULL,		/*  Execute on the last day of the month */
      @SkipTheseMonths		VARCHAR(35)	= NULL,		/*  comma seperated set of months that have to be skipped for the monthly schedule executes */
      @monthtodate			BIT 		= NULL,
      @ValidateOnly			BIT			= NULL,
      @IdRpSchedule			INT			= NULL,
      @system_datetime DATETIME,
      @ScheduleId				INT			OUTPUT
      AS
      BEGIN
	      SET NOCOUNT ON 
	
	      DECLARE @bResult BIT, @dtNext DATETIME, @dtNow DATETIME, @dtStart DATETIME
	
	      IF NOT EXISTS (SELECT * FROM t_export_report_instance WHERE id_rep_instance_id = @ReportInstanceId)
	      BEGIN
		      RAISERROR ('Report instance provided is invalid!', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END
	
	      IF @ScheduleType NOT IN ('daily', 'weekly', 'monthly')
	      BEGIN
		      RAISERROR ('Invalid Schedule Type!', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END
	      SELECT	@dtStart = ISNULL(dt_last_run, @system_datetime) FROM t_export_report_instance
	      WHERE	id_rep_instance_id = @ReportInstanceId

	      IF ISNULL(@IdRpSchedule, 0) > 0
	      BEGIN
		      /*  Remove the current schedule and add the new one (this is when a schedule is being updated) */
		      DELETE FROM t_export_schedule WHERE id_rp_schedule = @IdRpSchedule
	      END
	      EXECUTE @bResult = dbo.Export_CreateANewSchedule	@ScheduleType		= @ScheduleType,
											      @ExecuteTime			= @ExecuteTime,
											      @RepeatHours			= @RepeatHours, 
											      @ExecuteStartTime		= @ExecuteStartTime,
											      @ExecuteEndTime			= @ExecuteEndTime,
											      @SkipLastDayOfMonth		= @SkipLastDayOfMonth,
											      @SkipFirstDayOfMonth	= @SkipFirstDayOfMonth,
											      @ExecuteWeekDays		= @ExecuteWeekDays,
											      @SkipWeekDays			= @SkipWeekDays,
											      @ExecuteMonthDay		= @ExecuteMonthDay,
											      @ExecuteFirstDayOfMonth	= @ExecuteFirstDayOfMonth,
											      @ExecuteLastDayOfMonth	= @ExecuteLastDayOfMonth,
											      @DaysInterval			= @DaysInterval,
											      @SkipTheseMonths		= @SkipTheseMonths,
											      @monthtodate			= @monthtoDate, 
											      @ValidateOnly			= @ValidateOnly,
											      @ScheduleId				= @ScheduleId OUTPUT
	
	
	      IF @bResult = 1
	      BEGIN
		      IF ISNULL(@ValidateOnly, 0) = 1
		      BEGIN
			      RETURN @bResult
		      END
		      ELSE
		      BEGIN
			      SET @dtNow = DATEADD(dd, -1, @system_datetime)
			      /* Schedule has been created - insert the report_schedule */
			      INSERT INTO t_export_schedule (	id_rep_instance_id, id_schedule, c_sch_type, dt_crt)
			      VALUES					(	@ReportInstanceId, @ScheduleId, @ScheduleType, @dtNow)
			      SELECT @idRpSchedule = SCOPE_IDENTITY()
			      EXECUTE @bResult = Export_SetReprtInstNextRunDate @ReportInstanceId=@ReportInstanceId, @ScheduleId=@ScheduleId, 
							      @ScheduleType=@ScheduleType, @dtNow=@dtNow, @dtStart = @dtStart
			      RETURN @bResult
		      END
	      END
	
	      RETURN @bResult
      END
	