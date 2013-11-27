                                       
              CREATE OR REPLACE PROCEDURE Export_UpdateInstancSchedMonly
              (
                p_id_report_instance IN NUMBER DEFAULT NULL ,
                p_id_schedule_monthly IN NUMBER DEFAULT NULL ,
                p_c_exec_day IN NUMBER DEFAULT NULL ,
                p_c_exec_time IN VARCHAR2 DEFAULT NULL ,
                p_c_exec_first_month_day IN NUMBER DEFAULT NULL ,
                p_c_exec_last_month_day IN NUMBER DEFAULT NULL ,
                p_c_skip_months IN VARCHAR2 DEFAULT NULL,
                p_system_datetime DATE DEFAULT NULL
              )
              AS
                   v_c_skip_months VARCHAR2(100) := p_c_skip_months;
                 /* Check whether the first character or last character is comma. If so remove those without impacting the actual text */
                 p_firstchar VARCHAR2(1);
                 p_lastchar VARCHAR2(1);

               BEGIN
                 p_firstchar := SUBSTR(v_c_skip_months, 0, 1) ;
                 p_lastchar := SUBSTR(v_c_skip_months, -1, 1) ;
                 IF p_firstchar = ',' THEN
                 
                 BEGIN
                    v_c_skip_months := SUBSTR(v_c_skip_months, 2, (NVL(LENGTH(v_c_skip_months), 0) - 1)) ;
                 END;
                 END IF;
                 IF p_lastchar = ',' THEN
                 
                 BEGIN
                    v_c_skip_months := SUBSTR(v_c_skip_months, 1, (NVL(LENGTH(v_c_skip_months), 0) - 1)) ;
                 END;
                 END IF;           

                 UPDATE t_sch_monthly tschm
				 SET tschm.c_exec_day = p_c_exec_day,
					 tschm.c_exec_time = p_c_exec_time,
					   tschm.c_exec_first_month_day = p_c_exec_first_month_day,
						 tschm.c_exec_last_month_day = p_c_exec_last_month_day,
						  tschm.c_skip_months = v_c_skip_months
				 WHERE tschm.id_schedule_monthly = (SELECT tsch.id_schedule
				 FROM               t_export_schedule tsch
										   JOIN
											   t_export_report_instance trpi
										   ON tsch.id_rep_instance_id =
												  trpi.id_rep_instance_id
									   JOIN
										   t_export_reports trp
									   ON trpi.id_rep = trp.id_rep
								   JOIN
									   t_sch_monthly tschm
								   ON tsch.id_schedule = tschm.id_schedule_monthly
						   WHERE   tsch.id_schedule = p_id_schedule_monthly
						   AND LOWER(tsch.c_sch_type) = 'monthly');

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
						p_id_schedule_monthly,
						'monthly',
						p_dtNow,
						p_dtStart
					);
				END;
              END;
	 