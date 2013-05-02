

		CREATE PROCEDURE Export_UpdateInstanceSchedDly
		@id_report_instance 		INT,
		@id_schedule_daily 			INT,
		@c_exec_time         		VARCHAR(10),
		@c_repeat_hour				INT		= NULL,
		@c_exec_start_time   		VARCHAR(5),
		@c_exec_end_time   		    VARCHAR(5),
		@c_skip_last_day_month      BIT,
		@c_skip_first_day_month     BIT,
		@c_days_interval			INT,
		@c_month_to_date			INT,
		@system_datetime 			DATETIME

		AS
		BEGIN

			SET NOCOUNT ON
				
			UPDATE 	tschD SET

				tschD.c_exec_time= @c_exec_time,
				tschD.c_repeat_hour = @c_repeat_hour,
				tschD.c_exec_start_time = @c_exec_start_time,
				tschD.c_exec_end_time = @c_exec_end_time,
				tschD.c_skip_last_day_month = @c_skip_last_day_month,
				tschD.c_skip_first_day_month = @c_skip_first_day_month,
				tschD.c_days_interval = 1,
				tschD.c_month_to_date = @c_month_to_date
			FROM		t_export_schedule tsch 
			INNER JOIN	t_export_report_instance trpi ON tsch.id_rep_instance_id = trpi.id_rep_instance_id 
			INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep 
			INNER JOIN	t_sch_daily tschD ON tsch.id_schedule = tschD.id_schedule_daily 
			WHERE 	tsch.id_schedule = @id_schedule_daily
		    and tsch.c_sch_type = 'daily'

			BEGIN
				DECLARE @dtNow DATETIME, @dtStart DATETIME
				SET @dtNow = DATEADD(dd, -1, @system_datetime)				
				SELECT	@dtStart = ISNULL(dt_last_run, @system_datetime)
					FROM t_export_report_instance
					WHERE id_rep_instance_id = @id_report_instance
					
				EXECUTE Export_SetReprtInstNextRunDate
					@ReportInstanceId=@id_report_instance,
					@ScheduleId=@id_schedule_daily,
					@ScheduleType='daily',
					@dtNow=@dtNow,
					@dtStart = @dtStart
			END
		END

	 