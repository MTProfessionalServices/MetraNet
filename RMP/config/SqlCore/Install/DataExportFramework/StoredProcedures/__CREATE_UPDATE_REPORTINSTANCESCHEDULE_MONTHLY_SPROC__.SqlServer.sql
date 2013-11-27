
		CREATE PROCEDURE [dbo].[Export_UpdateInstancSchedMonly]
		@id_report_instance 		INT,
		@id_schedule_monthly     	INT,
		@c_exec_day					INT,
		@c_exec_time         		VARCHAR(10),
		@c_exec_first_month_day	    BIT, 
		@c_exec_last_month_day	    BIT,
		@c_skip_months				VARCHAR(100)	= NULL,
		@system_datetime 			DATETIME

		AS
		BEGIN

		  /* Check whether the first character or last character is comma. If so remove those without impacting the actual text */    
		  DECLARE @firstchar VARCHAR(1)
		  DECLARE @lastchar VARCHAR(1)
		  SET @firstchar =  LEFT(@c_skip_months,1)
		  SET @lastchar = RIGHT(@c_skip_months,1)
		  IF @firstchar = ','
		  BEGIN 
				SET @c_skip_months = SUBSTRING(@c_skip_months,2,(len(@c_skip_months)-1))
		  END

	      IF @lastchar = ','
		  
		  BEGIN 
				SET @c_skip_months = SUBSTRING(@c_skip_months,1,(len(@c_skip_months)-1))
		  END

			SET NOCOUNT ON

			UPDATE 	tschM SET

				tschM.c_exec_day = @c_exec_day,
				tschM.c_exec_time= @c_exec_time,
				tschM.c_exec_first_month_day = @c_exec_first_month_day,
				tschM.c_exec_last_month_day = @c_exec_last_month_day,
				tschM.c_skip_months = @c_skip_months
			FROM		t_export_schedule tsch 
			INNER JOIN	t_export_report_instance trpi ON tsch.id_rep_instance_id = trpi.id_rep_instance_id 
			INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep 
			INNER JOIN	t_sch_monthly tschM ON tsch.id_schedule = tschM.id_schedule_monthly 
			WHERE 	tsch.id_schedule = @id_schedule_monthly
		    and tsch.c_sch_type = 'monthly'
			
			BEGIN
				DECLARE @dtNow DATETIME, @dtStart DATETIME
				SET @dtNow = DATEADD(dd, -1, @system_datetime)				
				SELECT	@dtStart = ISNULL(dt_last_run, @system_datetime)
					FROM t_export_report_instance
					WHERE id_rep_instance_id = @id_report_instance
					
				EXECUTE Export_SetReprtInstNextRunDate
					@ReportInstanceId=@id_report_instance,
					@ScheduleId=@id_schedule_monthly,
					@ScheduleType='monthly',
					@dtNow=@dtNow,
					@dtStart = @dtStart
			END
		END
		