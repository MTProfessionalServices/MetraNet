
      CREATE PROCEDURE [dbo].[Export_CreateWeeklySchedule]
      @ExecuteTime			CHAR(5),				/*  format "HH:MM" in military */
      @ExecuteWeekDays		VARCHAR(27),			/*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN" */
      @SkipWeekDays			VARCHAR(27) 	= NULL,		/*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN" */
      @monthtoDate			BIT 		= NULL,
      @ValidateOnly			BIT		= NULL,
      @ScheduleId			INT		= NULL	OUTPUT	
      AS
      BEGIN	
	      SET NOCOUNT ON
	
	      /* DECLARE @wkDays VARCHAR(27) */
	      /* SET @wkDays = 'MON,TUE,WED,THU,FRI,SAT,SUN' */
	      DECLARE @bResult BIT
	      SET @bResult = 1
	
	      IF LEN(ISNULL(@ExecuteWeekDays, '')) = 0
		      RAISERROR ('ExecuteWeekDays Parameter is Required for Weekly Schedule', 16, 1)
		  
		  /* Check whether the first character or last character of skipweekdays is comma. If so remove those without impacting the actual text */    
		  DECLARE @firstchar VARCHAR(1)
		  DECLARE @lastchar VARCHAR(1)
		  SET @firstchar =  LEFT(@skipweekdays,1)
		  SET @lastchar = RIGHT(@skipweekdays,1)
		  IF @firstchar = ','
		  BEGIN 
				SET @skipweekdays = SUBSTRING(@skipweekdays,2,(len(@skipweekdays)-1))
		  END

	      IF @lastchar = ','
		  
		  BEGIN 
				SET @skipweekdays = SUBSTRING(@skipweekdays,1,(len(@skipweekdays)-1))
		  END

		  /* Check whether the first character or last character of executeweekdays is comma. If so remove those without impacting the actual text */    
		  DECLARE @firstchar_ew VARCHAR(1)
		  DECLARE @lastchar_ew VARCHAR(1)
		  SET @lastchar_ew =  LEFT(@ExecuteWeekDays,1)
		  SET @lastchar_ew = RIGHT(@ExecuteWeekDays,1)

		  IF @firstchar_ew = ','
		  BEGIN 
				SET @ExecuteWeekDays = SUBSTRING(@ExecuteWeekDays,2,(len(@ExecuteWeekDays)-1))
		  END

	      IF @lastchar_ew = ','
		  BEGIN 
				SET @ExecuteWeekDays = SUBSTRING(@ExecuteWeekDays,1,(len(@ExecuteWeekDays)-1))
		  END


	      SELECT @bResult = dbo.ValidateWeekDays(@ExecuteWeekDays)
	      IF @bResult = 0
	      BEGIN
		      RAISERROR ('ExecuteWeekDays Parameter is Invalid', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END
	      IF LEN(ISNULL(@SkipWeekDays, '')) > 0
	      BEGIN
		      SELECT @bResult = dbo.ValidateWeekDays(@SkipWeekDays)
		      IF @bResult = 0
		      BEGIN
			      RAISERROR ('SkipWeekDays Parameter is Invalid', 16, 1)
			      SET @bResult = 0
			      RETURN @bResult
		      END
	      END

	      IF @ValidateOnly = 0
	      BEGIN
		      INSERT INTO t_sch_weekly (	c_exec_time, c_exec_week_days, 
									      c_skip_week_days, c_month_to_date)
		      VALUES					(	@ExecuteTime, @ExecuteWeekDays, 
									      @SkipWeekDays, ISNULL(@monthtoDate, 0))
		      SELECT @ScheduleId = SCOPE_IDENTITY()
	      END
	
	      RETURN @bResult
      END
	 