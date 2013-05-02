
              CREATE OR REPLACE PROCEDURE Export_ScheduleReportInstance
              (
                p_ReportInstanceId IN NUMBER DEFAULT NULL ,
                p_ScheduleType IN VARCHAR2 DEFAULT NULL 
                /* POSSIBLE VALUES ARE "Daily/Weekly/Monthly" ONLY */
                ,
                p_ExecuteTime IN CHAR DEFAULT NULL 
                /*  format "HH:MM" in military */
                ,
                p_RepeatHours IN NUMBER DEFAULT NULL 
                /*  hour number between repeats */
                ,
                p_ExecuteStartTime IN VARCHAR2 DEFAULT NULL 
                /*  format "HH:MM" in military (start and end time provide a pocket of execution hours) */
                ,
                p_ExecuteEndTime IN VARCHAR2 DEFAULT NULL 
                /*  format "HH:MM" in military */
                ,
                p_SkipFirstDayOfMonth IN NUMBER DEFAULT NULL ,
                p_SkipLastDayOfMonth IN NUMBER DEFAULT NULL ,
                p_DaysInterval IN NUMBER DEFAULT NULL ,
                p_ExecuteWeekDays IN VARCHAR2 DEFAULT NULL 
                /*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN */
                ,
                p_SkipWeekDays IN VARCHAR2 DEFAULT NULL 
                /*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN */
                ,
                p_ExecuteMonthDay IN NUMBER DEFAULT NULL 
                /*  Day of the month when to execute */
                ,
                p_ExecuteFirstDayOfMonth IN NUMBER DEFAULT NULL 
                /*  Execute on the first day of the month */
                ,
                p_ExecuteLastDayOfMonth IN NUMBER DEFAULT NULL 
                /*  Execute on the last day of the month */
                ,
                p_SkipTheseMonths IN VARCHAR2 DEFAULT NULL 
                /*  comma seperated set of months that have to be skipped for the monthly schedule executes */
                ,
                p_monthtodate IN NUMBER DEFAULT NULL ,
                p_ValidateOnly IN NUMBER DEFAULT NULL ,
                p_IdRpSchedule IN NUMBER DEFAULT NULL ,
                p_system_datetime DATE DEFAULT NULL,
                p_ScheduleId OUT NUMBER
              )             
              AS
                 v_IdRpSchedule NUMBER(10,0) := p_IdRpSchedule;
                 p_bResult NUMBER(1,0) := 0;
                 p_dtNext DATE;
                 p_dtNow DATE;
                 p_dtStart DATE;
                 p_temp NUMBER(1, 0) := 0;
		 		 v_ScheduleType varchar(10) := LOWER(p_ScheduleType);
              
              BEGIN
                 BEGIN
                    SELECT 1 INTO p_temp
                      FROM DUAL
                     WHERE NOT EXISTS ( SELECT * 
                                        FROM t_export_report_instance 
                                         WHERE id_rep_instance_id = p_ReportInstanceId );
                 EXCEPTION
                    WHEN OTHERS THEN
                       NULL;
                 END;
                    
                 IF p_temp = 1 THEN                 
                 BEGIN
                    raise_application_error( -20002, 'Report instance provided is invalid!' );
                    RETURN;
                 END;
                 END IF;
				 
                 IF v_ScheduleType NOT IN ( 'daily','weekly','monthly' )
                  THEN
                 BEGIN
                    raise_application_error( -20002, 'Invalid Schedule Type!' );
                    RETURN;
                 END;
                 END IF;
                 
                 SELECT NVL(dt_last_run, p_system_datetime) 
                   INTO p_dtStart
                   FROM t_export_report_instance 
                  WHERE id_rep_instance_id = p_ReportInstanceId;
                  
                 IF NVL(v_IdRpSchedule, 0) > 0 THEN                 
                 BEGIN
                    /*  Remove the current schedule and add the new one (this is when a schedule is being updated) */
                    DELETE t_export_schedule
              
                     WHERE id_rp_schedule = v_IdRpSchedule;
                 END;
                 END IF;
                                                               
				 p_bresult := export_createanewschedule(v_scheduletype,
															p_executetime,
															p_repeathours,
															p_executestarttime,
															p_executeendtime,
															p_skipfirstdayofmonth,
															p_skiplastdayofmonth,
															p_daysinterval,
															p_executeweekdays,
															p_skipweekdays,
															p_executemonthday,
															p_executefirstdayofmonth,
															p_executelastdayofmonth,
															p_skipthesemonths,
															p_monthtodate,
															p_validateonly,
															p_scheduleid);
                 IF p_bResult = 1
					AND NVL(p_ValidateOnly, 0) <> 1 THEN
                 BEGIN
                       p_dtNow := p_system_datetime - 1;
                       /* Schedule has been created - insert the report_schedule */
                       INSERT INTO t_export_schedule
                         ( id_rep_instance_id, id_schedule, c_sch_type, dt_crt )
                         VALUES ( p_ReportInstanceId, p_ScheduleId, p_ScheduleType, p_dtNow )
                         RETURNING id_rp_schedule INTO v_idRpSchedule;
                          COMMIT;
                       p_bResult :=Export_SetReprtInstNextRunDate(p_ReportInstanceId,
                                                                  p_ScheduleId,
                                                                  p_ScheduleType,
                                                                  p_dtNow,
                                                                  p_dtStart);
                   END;                                                       
                 END IF;                
              END;
              	