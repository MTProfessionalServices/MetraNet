                                       
              CREATE OR REPLACE PROCEDURE Export_UpdateInstancSchedWkly
              (
                p_id_report_instance IN NUMBER DEFAULT NULL ,
                p_id_schedule_weekly IN NUMBER DEFAULT NULL ,
                p_c_exec_time IN VARCHAR2 DEFAULT NULL ,
                p_c_exec_week_days IN VARCHAR2 DEFAULT NULL ,
                p_c_skip_week_days IN VARCHAR2 DEFAULT NULL ,
                p_c_month_to_date IN NUMBER DEFAULT NULL ,
                p_system_datetime DATE DEFAULT NULL
              )
              AS
                 v_c_skip_week_days VARCHAR2(50) := p_c_skip_week_days;
                 v_c_exec_week_days VARCHAR2(50) := p_c_exec_week_days;
                 /* Check whether the first character or last character is comma. If so remove those without impacting the actual text */
                 p_firstchar VARCHAR2(1);
                 p_lastchar VARCHAR2(1);
                 /* Check whether the first character or last character of executeweekdays is comma. If so remove those without impacting the actual text */
                 p_firstchar_ew VARCHAR2(1);
                 p_lastchar_ew VARCHAR2(1);
              
              BEGIN
                 p_firstchar := SUBSTR(v_c_skip_week_days, 0, 1) ;
                 p_lastchar := SUBSTR(v_c_skip_week_days, -1, 1) ;
                 IF p_firstchar = ',' THEN
                 
                 BEGIN
                    v_c_skip_week_days := SUBSTR(v_c_skip_week_days, 2, (NVL(LENGTH(v_c_skip_week_days), 0) - 1)) ;
                 END;
                 END IF;
                 IF p_lastchar = ',' THEN
                 
                 BEGIN
                    v_c_skip_week_days := SUBSTR(v_c_skip_week_days, 1, (NVL(LENGTH(v_c_skip_week_days), 0) - 1)) ;
                 END;
                 END IF;
                 p_lastchar_ew := SUBSTR(v_c_exec_week_days, 0, 1) ;
                 p_lastchar_ew := SUBSTR(v_c_exec_week_days, -1, 1) ;
                 IF p_firstchar_ew = ',' THEN
                 
                 BEGIN
                    v_c_exec_week_days := SUBSTR(v_c_exec_week_days, 2, (NVL(LENGTH(v_c_exec_week_days), 0) - 1)) ;
                 END;
                 END IF;
                 IF p_lastchar_ew = ',' THEN
                 
                 BEGIN
                    v_c_exec_week_days := SUBSTR(v_c_exec_week_days, 1, (NVL(LENGTH(v_c_exec_week_days), 0) - 1)) ;
                 END;
                 END IF;                 

				 UPDATE t_sch_weekly tschw
				SET
				tschw.c_exec_time = p_c_exec_time,
						   tschw.c_exec_week_days = v_c_exec_week_days,
						   tschw.c_skip_week_days = v_c_skip_week_days,
						   tschw.c_month_to_date = p_c_month_to_date
				WHERE tschw.id_schedule_weekly = (SELECT tsch.id_schedule
				FROM               t_export_schedule tsch
										   JOIN
											   t_export_report_instance trpi
										   ON tsch.id_rep_instance_id =
												  trpi.id_rep_instance_id
									   JOIN
										   t_export_reports trp
									   ON trpi.id_rep = trp.id_rep
								   JOIN
									   t_sch_weekly tschw
								   ON tsch.id_schedule = tschw.id_schedule_weekly
						   WHERE   tsch.id_schedule = p_id_schedule_weekly and LOWER(tsch.c_sch_type) = 'weekly');

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
						p_id_schedule_weekly,
						'weekly',
						p_dtNow,
						p_dtStart
					);
				END;
              END;
	 