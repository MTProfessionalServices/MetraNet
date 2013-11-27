                                      
              CREATE OR REPLACE FUNCTION Export_SetReprtInstNextRunDate
              (
                v_ReportInstanceId IN NUMBER DEFAULT NULL ,
                v_ScheduleId IN NUMBER DEFAULT NULL ,
                iv_ScheduleType IN VARCHAR2 DEFAULT NULL ,
                v_dtNow IN DATE DEFAULT NULL ,
                iv_dtstart IN DATE DEFAULT NULL 
              )
              RETURN NUMBER
              AS
                 v_ScheduleType VARCHAR2(10) := LOWER(iv_ScheduleType);
                 v_dtstart DATE := iv_dtstart;
                 v_bResult NUMBER(10,0);
                 v_monthtoDate NUMBER(1,0);
                 v_ExecuteTime CHAR(5);
                 /*  format "HH:MM" in military */
                 v_RepeatHours NUMBER(10,0);
                 /*  hour number between repeats */
                 v_ExecuteStartTime VARCHAR2(5);
                 /*  format "HH:MM" in military (start and end time provide a pocket of execution hours) */
                 v_ExecuteEndTime VARCHAR2(5);
                 /*  format "HH:MM" in military */
                 v_SkipFirstDayOfMonth NUMBER(1,0);
                 v_SkipLastDayOfMonth NUMBER(1,0);
                 v_DaysInterval NUMBER(10,0);
                 v_ExecWeekDays VARCHAR2(27);
                 v_SkipWeekDays VARCHAR2(27);
                 v_ExecuteMonthDay NUMBER(10,0);
                 /*  Day of the month when to execute */
                 v_ExecuteFirstDayOfMonth NUMBER(1,0);
                 /*  Execute on the first day of the month */
                 v_ExecuteLastDayOfMonth NUMBER(1,0);
                 /*  Execute on the last day of the month */
                 v_SkipTheseMonths VARCHAR2(35);
                 v_dtNext DATE;
              
              BEGIN
                 IF v_ScheduleType NOT IN ( 'daily','weekly','monthly' )
                  THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'Invalid Schedule Type!' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 END IF;
                 IF v_ScheduleType = 'daily' THEN
                 
                 BEGIN
                    SELECT sd.c_exec_time ,
                           sd.c_repeat_hour ,
                           sd.c_exec_start_time ,
                           sd.c_exec_end_time ,
                           sd.c_skip_last_day_month ,
                           sd.c_skip_first_day_month ,
                           sd.c_days_interval ,
                           sd.c_month_to_date 
              
                      INTO v_ExecuteTime,
                           v_RepeatHours,
                           v_ExecuteStartTime,
                           v_ExecuteEndTime,
                           v_SkipLastDayOfMonth,
                           v_SkipFirstDayOfMonth,
                           v_DaysInterval,
                           v_monthtoDate
                      FROM t_export_schedule S
                             JOIN t_sch_daily sd
                              ON S.id_schedule = sd.id_schedule_daily
                     WHERE S.id_rep_instance_id = v_ReportInstanceId
                             AND S.id_schedule = v_ScheduleId
                             AND LOWER(S.c_sch_type) = v_ScheduleType;
                    v_dtNext := GenerateNextRunTime_Daily(v_dtStart, v_ExecuteTime, v_RepeatHours, v_ExecuteStartTime, v_ExecuteEndTime, v_SkipFirstDayOfMonth, v_SkipLastDayOfMonth, v_DaysInterval) ;
                 END;
                 ELSE
                    IF v_ScheduleType = 'weekly' THEN
                    
                    BEGIN
                       SELECT sw.c_exec_time ,
                              sw.c_exec_week_days ,
                              sw.c_skip_week_days ,
                              sw.c_month_to_date 
              
                         INTO v_ExecuteTime,
                              v_ExecWeekDays,
                              v_SkipWeekDays,
                              v_monthtoDate
                         FROM t_export_schedule S
                                JOIN t_sch_weekly sw
                                 ON S.id_schedule = sw.id_schedule_weekly
                        WHERE S.id_rep_instance_id = v_ReportInstanceId
                                AND S.id_schedule = v_ScheduleId
                                AND LOWER(S.c_sch_type) = v_ScheduleType;
                       IF NVL(LENGTH(v_SkipWeekDays), 0) = 0 THEN
                          v_SkipWeekDays := NULL ;
                       END IF;
                       v_dtNext := GenerateNextRunTime_Weekly(v_dtStart, v_ExecuteTime, v_ExecWeekDays, v_SkipWeekDays) ;
                    END;
                    ELSE
                       IF v_ScheduleType = 'monthly' THEN
                       
                       BEGIN
                          SELECT sm.c_exec_day ,
                                 sm.c_exec_time ,
                                 sm.c_exec_first_month_day ,
                                 sm.c_exec_last_month_day ,
                                 sm.c_skip_months 
              
                            INTO v_ExecuteMonthDay,
                                 v_ExecuteTime,
                                 v_ExecuteFirstDayOfMonth,
                                 v_ExecuteLastDayOfMonth,
                                 v_SkipTheseMonths
                            FROM t_export_schedule S
                                   JOIN t_sch_monthly sm
                                    ON S.id_schedule = sm.id_schedule_monthly
                           WHERE S.id_rep_instance_id = v_ReportInstanceId
                                   AND S.id_schedule = v_ScheduleId
                                   AND LOWER(S.c_sch_type) = v_ScheduleType;
                          IF NVL(LENGTH(v_SkipTheseMonths), 0) = 0 THEN
                             v_SkipTheseMonths := NULL ;
                          END IF;
                          v_dtNext := GenerateNextRunTime_Monthly(v_dtStart, v_ExecuteTime, v_ExecuteMonthDay, v_ExecuteFirstDayOfMonth, v_ExecuteLastDayOfMonth, v_SkipTheseMonths) ;
                       END;
                       END IF;
                    END IF;
                 END IF;
                 IF NVL(v_monthtoDate, 0) = 1 THEN
                   v_dtStart := to_date(to_char(v_dtNext, 'YYYYMM') || '01', 'YYYYMMDD');
                   END IF;
                 UPDATE t_export_report_instance
                    SET dt_Next_run = v_dtNext,
                        dt_last_run = v_dtstart
                    WHERE id_rep_instance_id = v_ReportInstanceId;
                 RETURN 0;
              END;
	