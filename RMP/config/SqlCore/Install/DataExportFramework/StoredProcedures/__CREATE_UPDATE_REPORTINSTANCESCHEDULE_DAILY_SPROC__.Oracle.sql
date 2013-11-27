                             
              CREATE OR REPLACE PROCEDURE Export_UpdateInstanceSchedDly
              (
                p_id_report_instance IN NUMBER DEFAULT NULL ,
                p_id_schedule_daily IN NUMBER DEFAULT NULL ,
                p_c_exec_time IN VARCHAR2 DEFAULT NULL ,
                p_c_repeat_hour IN NUMBER DEFAULT NULL ,
                p_c_exec_start_time IN VARCHAR2 DEFAULT NULL ,
                p_c_exec_end_time IN VARCHAR2 DEFAULT NULL ,
                p_c_skip_last_day_month IN NUMBER DEFAULT NULL ,
                p_c_skip_first_day_month IN NUMBER DEFAULT NULL ,
                p_c_days_interval IN NUMBER DEFAULT NULL ,
                p_c_month_to_date IN NUMBER DEFAULT NULL ,
                p_system_datetime DATE DEFAULT NULL
              )
              AS
				BEGIN
					UPDATE   t_sch_daily tschd
					   SET   tschd.c_exec_time = p_c_exec_time,
							 tschd.c_repeat_hour = p_c_repeat_hour,
							 tschd.c_exec_start_time = p_c_exec_start_time,
							 tschd.c_exec_end_time = p_c_exec_end_time,
							 tschd.c_skip_last_day_month = p_c_skip_last_day_month,
							 tschd.c_skip_first_day_month = p_c_skip_first_day_month,
							 tschd.c_days_interval = 1,
							 tschd.c_month_to_date = p_c_month_to_date
					 WHERE   tschd.id_schedule_daily =
								 (SELECT   tsch.id_schedule
									FROM               t_export_schedule tsch
												   JOIN
													   t_export_report_instance trpi
												   ON tsch.id_rep_instance_id =
														  trpi.id_rep_instance_id
											   JOIN
												   t_export_reports trp
											   ON trpi.id_rep = trp.id_rep
										   JOIN
											   t_sch_daily tschd
										   ON tsch.id_schedule = tschd.id_schedule_daily
								   WHERE   tsch.id_schedule = p_id_schedule_daily
										   AND LOWER (tsch.c_sch_type) = 'daily');

				DECLARE
					p_dtNow DATE;
					p_dtStart DATE;
					p_bResult NUMBER(1,0) := 0;
					
				BEGIN
					p_dtNow := p_system_datetime - 1;
					SELECT NVL(dt_last_run, p_system_datetime) 
						INTO p_dtStart
						FROM t_export_report_instance 
						WHERE id_rep_instance_id = p_id_report_instance;

					p_bResult := Export_SetReprtInstNextRunDate(
						p_id_report_instance,
						p_id_schedule_daily,
						'daily',
						p_dtNow,
						p_dtStart
					);
				END;
              END;
	 