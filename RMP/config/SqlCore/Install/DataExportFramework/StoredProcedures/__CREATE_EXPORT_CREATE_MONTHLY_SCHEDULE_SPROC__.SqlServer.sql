

      CREATE PROCEDURE [dbo].[Export_CreateMonthlySchedule]
      @ExecuteTime			CHAR(5),				/*  format "HH:MM" in military */
      @ExecuteMonthDay		INT			= NULL,		/*  Day of the month when to execute */
      @ExecuteFirstDayOfMonth	BIT			= NULL,		/*  Execute on the first day of the month */
      @ExecuteLastDayOfMonth	BIT			= NULL,		/*  Execute on the last day of the month */
      @SkipTheseMonths		VARCHAR(35)	= NULL,		        /*  comma seperated set of months that have to be skipped for the monthly schedule executes */
      @ValidateOnly			BIT			= NULL,
      @ScheduleId				INT			= NULL	OUTPUT	
      AS
      BEGIN
	      SET NOCOUNT ON
	
	      DECLARE @bResult BIT
	
	      SELECT @bResult = 1
	
	      IF ISNULL(@ExecuteMonthDay, 0) = 0 AND ISNULL(@ExecuteFirstDayOfMonth, 0) = 0 AND ISNULL(@ExecuteLastDayOfMonth, 0) = 0
	      BEGIN
		      RAISERROR ('An Execution Day is required for Monthly Schedule', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END
	
	      IF ISNULL(@ExecuteMonthDay, 0) > 0 AND ISNULL(@ExecuteFirstDayOfMonth, 0) = 1
	      BEGIN
		      RAISERROR ('ExecuteMonthDay and ExecuteFirstDayOfMonth are Mutually Exclusive!', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END
	
	      IF ISNULL(@ExecuteMonthDay, 0) > 0 AND ISNULL(@ExecuteLastDayOfMonth, 0) = 1
	      BEGIN
		      RAISERROR ('ExecuteMonthDay and ExecuteLastDayOfMonth are Mutually Exclusive!', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END

	      IF ISNULL(@ExecuteFirstDayOfMonth, 0) = 1 AND ISNULL(@ExecuteLastDayOfMonth, 0) = 1
	      BEGIN
		      RAISERROR ('ExecuteFirstDayOfMonth and ExecuteLastDayOfMonth are Mutually Exclusive!', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END
	
	      IF LEN(ISNULL(@SkipTheseMonths, '')) > 0
	      BEGIN
		      SELECT @bResult = dbo.ValidateMonths(@SkipTheseMonths)
		      IF @bResult = 0
		      BEGIN
			      RAISERROR ('Invalid SkipMonths Parameter!', 16, 1)
			      RETURN @bResult
		      END
	      END
	
	      IF @ExecuteMonthDay > 31 OR @ExecuteMonthDay < 0
	      BEGIN
		      RAISERROR ('Invalid Execute Day. Valid values are between 0 and 31!', 16, 1)
		      SET @bResult = 0
		      RETURN @bResult
	      END
	
		  /* Check whether the first character or last character is comma. If so remove those without impacting the actual text */    
		  DECLARE @firstchar VARCHAR(1)
		  DECLARE @lastchar VARCHAR(1)
		  SET @firstchar =  LEFT(@SkipTheseMonths,1)
		  SET @lastchar = RIGHT(@SkipTheseMonths,1)
		  IF @firstchar = ','
		  BEGIN 
				SET @SkipTheseMonths = SUBSTRING(@SkipTheseMonths,2,(len(@SkipTheseMonths)-1))
		  END

	      IF @lastchar = ','
		  
		  BEGIN 
				SET @SkipTheseMonths = SUBSTRING(@SkipTheseMonths,1,(len(@SkipTheseMonths)-1))
		  END

	
	      IF @ValidateOnly = 0
	      BEGIN
		      INSERT INTO t_sch_monthly (	c_exec_time, c_exec_day, c_exec_first_month_day,
									      c_exec_last_month_day, c_skip_months)
		      VALUES					(	@ExecuteTime, @ExecuteMonthDay, @ExecuteFirstDayOfMonth,
									      @ExecuteLastDayOfMonth, @SkipTheseMonths)
		      SELECT @ScheduleId = SCOPE_IDENTITY()
	      END
	
	      RETURN (@bResult)
      END
	 