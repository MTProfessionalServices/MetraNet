
		CREATE PROCEDURE [dbo].[Export_UpdateInstancSchedWkly]
		@id_report_instance 		INT,
		@id_schedule_weekly  		INT,
		@c_exec_time         		VARCHAR(10),
		@c_exec_week_days			VARCHAR(50)	= NULL,
		@c_skip_week_days			VARCHAR(50)	= NULL,
		@c_month_to_date			INT,
		@system_datetime 			DATETIME

		AS
		BEGIN
		
				  /* Check whether the first character or last character is comma. If so remove those without impacting the actual text */    
		  DECLARE @firstchar VARCHAR(1)
		  DECLARE @lastchar VARCHAR(1)
		  SET @firstchar =  LEFT(@c_skip_week_days,1)
		  SET @lastchar = RIGHT(@c_skip_week_days,1)
		  IF @firstchar = ','
		  BEGIN 
				SET @c_skip_week_days = SUBSTRING(@c_skip_week_days,2,(len(@c_skip_week_days)-1))
		  END

	      IF @lastchar = ','
		  
		  BEGIN 
				SET @c_skip_week_days = SUBSTRING(@c_skip_week_days,1,(len(@c_skip_week_days)-1))
		  END

		  /* Check whether the first character or last character of executeweekdays is comma. If so remove those without impacting the actual text */    
		  DECLARE @firstchar_ew VARCHAR(1)
		  DECLARE @lastchar_ew VARCHAR(1)
		  SET @lastchar_ew =  LEFT(@c_exec_week_days,1)
		  SET @lastchar_ew = RIGHT(@c_exec_week_days,1)

		  IF @firstchar_ew = ','
		  BEGIN 
				SET @c_exec_week_days = SUBSTRING(@c_exec_week_days,2,(len(@c_exec_week_days)-1))
		  END

	      IF @lastchar_ew = ','
		  BEGIN 
				SET @c_exec_week_days = SUBSTRING(@c_exec_week_days,1,(len(@c_exec_week_days)-1))
		  END

		  SET NOCOUNT ON

			UPDATE 	tschW SET

				tschW.c_exec_time= @c_exec_time,
				tschW.c_exec_week_days = @c_exec_week_days,
				tschW.c_skip_week_days = @c_skip_week_days,
				tschW.c_month_to_date = @c_month_to_date
			FROM		t_export_schedule tsch 
			INNER JOIN	t_export_report_instance trpi ON tsch.id_rep_instance_id = trpi.id_rep_instance_id 
			INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep 
			INNER JOIN	t_sch_weekly tschW ON tsch.id_schedule = tschW.id_schedule_weekly 
			/* WHERE 	tsch.id_rp_schedule = @id_schedule_weekly */
		    WHERE 	tsch.id_schedule = @id_schedule_weekly
		    and tsch.c_sch_type = 'weekly'
			
			BEGIN
				DECLARE @dtNow DATETIME, @dtStart DATETIME
				SET @dtNow = DATEADD(dd, -1, @system_datetime)				
				SELECT	@dtStart = ISNULL(dt_last_run, @system_datetime)
					FROM t_export_report_instance
					WHERE id_rep_instance_id = @id_report_instance
					
				EXECUTE Export_SetReprtInstNextRunDate
					@ReportInstanceId=@id_report_instance,
					@ScheduleId=@id_schedule_weekly,
					@ScheduleType='weekly',
					@dtNow=@dtNow,
					@dtStart = @dtStart
			END
		END

	 