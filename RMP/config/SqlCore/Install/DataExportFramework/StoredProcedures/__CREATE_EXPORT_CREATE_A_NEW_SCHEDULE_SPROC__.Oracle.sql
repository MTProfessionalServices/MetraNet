
              CREATE OR REPLACE FUNCTION Export_CreateANewSchedule
              (
                p_ScheduleType IN VARCHAR2 DEFAULT NULL 
                /*  POSSIBLE VALUES ARE "Daily/Weekly/Monthly" ONLY */
                ,
                v_ExecuteTime IN CHAR DEFAULT NULL 
                /* format "HH:MM" in military */
                ,
                v_RepeatHours IN NUMBER DEFAULT NULL 
                /* hour number between repeats */
                ,
                v_ExecuteStartTime IN VARCHAR2 DEFAULT NULL 
                /* format "HH:MM" in military (start and end time provide a pocket of execution hours) */
                ,
                v_ExecuteEndTime IN VARCHAR2 DEFAULT NULL 
                /* format "HH:MM" in military */
                ,
                v_SkipFirstDayOfMonth IN NUMBER DEFAULT NULL ,
                v_SkipLastDayOfMonth IN NUMBER DEFAULT NULL ,
                v_DaysInterval IN NUMBER DEFAULT NULL ,
                v_ExecuteWeekDays IN VARCHAR2 DEFAULT NULL 
                /*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN */
                ,
                v_SkipWeekDays IN VARCHAR2 DEFAULT NULL 
                /*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN */
                ,
                v_ExecuteMonthDay IN NUMBER DEFAULT NULL 
                /*  Day of the month when to execute */
                ,
                v_ExecuteFirstDayOfMonth IN NUMBER DEFAULT NULL 
                /*  Execute on the first day of the month */
                ,
                v_ExecuteLastDayOfMonth IN NUMBER DEFAULT NULL 
                /*  Execute on the last day of the month */
                ,
                v_SkipTheseMonths IN VARCHAR2 DEFAULT NULL 
                /*  comma seperated set of months that have to be skipped for the monthly schedule executes */
                ,
                v_monthtoDate IN NUMBER DEFAULT NULL ,
                iv_ValidateOnly IN NUMBER DEFAULT NULL ,
                v_ScheduleId OUT NUMBER/* DEFAULT NULL*/
              )
              RETURN NUMBER
              AS
                 v_ValidateOnly NUMBER(1,0) := iv_ValidateOnly;
                 v_bResult NUMBER(1,0);
		 		 v_ScheduleType varchar(10) := LOWER(p_ScheduleType);
              
              BEGIN
                 v_bResult := 0 ;
                 IF IsNumeric(SUBSTR(v_ExecuteTime, 0, 2)) = 0 THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'Invalid Execute Time Format - use HH:MM. Only Numeric values are allowed for HH and MM' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 ELSE
                 
                 BEGIN
                    IF CAST(SUBSTR(v_ExecuteTime, 0, 2) AS NUMBER) > 24
                      OR CAST(SUBSTR(v_ExecuteTime, 0, 2) AS NUMBER) < 0 THEN
                    
                    BEGIN
                       raise_application_error( -20002, 'Invalid Execute Time Format - Value for HH cannot be greater than 24 or less than 0' );
                       v_bResult := 0 ;
                       RETURN v_bResult;
                    END;
                    END IF;
                 END;
                 END IF;
                 IF IsNumeric(SUBSTR(v_ExecuteTime, -1, 2)) = 0 THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'Invalid Execute Time Format - use HH:MM. Only Numeric values are allowed for HH and MM' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 ELSE
                 
                 BEGIN
                    IF CAST(SUBSTR(v_ExecuteTime, -1, 2) AS NUMBER) > 60
                      OR CAST(SUBSTR(v_ExecuteTime, -1, 2) AS NUMBER) < 0 THEN
                    
                    BEGIN
                       raise_application_error( -20002, 'Invalid Execute Time Format - Value for MM cannot be greater than 60 or less than 0' );
                       v_bResult := 0 ;
                       RETURN v_bResult;
                    END;
                    END IF;
                 END;
                 END IF;
				 
                 /* SQL Server BEGIN TRANSACTION */
                 v_ValidateOnly := NVL(v_ValidateOnly, 0) ;
                 IF v_ScheduleType = 'daily' THEN
                 DECLARE
                    v_temp NUMBER(1, 0) := 0;
                 
                 BEGIN
                    BEGIN
                       SELECT 1 INTO v_temp
                         FROM DUAL
                        WHERE EXISTS ( SELECT * 
                                       FROM t_sch_daily 
                                        WHERE c_exec_time = v_ExecuteTime
                                                AND NVL(c_repeat_hour, 0) = NVL(v_RepeatHours, 0)
                                                AND NVL(c_exec_start_time, '') = NVL(v_ExecuteStartTime, '')
                                                AND NVL(c_exec_end_time, '') = NVL(v_ExecuteEndTime, '')
                                                AND c_skip_last_day_month = NVL(v_SkipLastDayOfMonth, 0)
                                                AND c_skip_first_day_month = NVL(v_SkipFirstDayOfMonth, 0)
                                                AND c_days_interval = NVL(v_DaysInterval, 1)
                                                AND c_month_to_date = NVL(v_monthtoDate, 0) );
                    EXCEPTION
                       WHEN OTHERS THEN
                          NULL;
                    END;
                       
                    IF v_temp = 1 THEN
                    
                    BEGIN
                       SELECT id_schedule_daily 
              
                         INTO v_ScheduleId
                         FROM t_sch_daily 
                        WHERE c_exec_time = v_ExecuteTime
                                AND NVL(c_repeat_hour, 0) = NVL(v_RepeatHours, 0)
                                AND NVL(c_exec_start_time, '') = NVL(v_ExecuteStartTime, '')
                                AND NVL(c_exec_end_time, '') = NVL(v_ExecuteEndTime, '')
                                AND c_skip_last_day_month = NVL(v_SkipLastDayOfMonth, 0)
                                AND c_skip_first_day_month = NVL(v_SkipFirstDayOfMonth, 0)
                                AND c_days_interval = NVL(v_DaysInterval, 1)
                                AND c_month_to_date = NVL(v_monthtoDate, 0);
                       v_bResult := 1 ;
                    END;
                    ELSE
                    
                    BEGIN
                       v_bResult :=/*dbo.*/Export_CreateDailySchedule(v_ExecuteTime,
                                                                      v_RepeatHours,
                                                                      v_ExecuteStartTime,
                                                                      v_ExecuteEndTime,
                                                                      v_SkipFirstDayOfMonth,
                                                                      v_SkipLastDayOfMonth,
                                                                      v_DaysInterval,
                                                                      v_monthtoDate,
                                                                      v_ValidateOnly,
                                                                      v_ScheduleId);
                    END;
                    END IF;
                 END;
                 ELSE
                    IF v_ScheduleType = 'weekly' THEN
                    DECLARE
                       v_temp NUMBER(1, 0) := 0;
                    
                    BEGIN
                       BEGIN
                          SELECT 1 INTO v_temp
                            FROM DUAL
                           WHERE EXISTS ( SELECT * 
                                          FROM t_sch_weekly 
                                           WHERE c_exec_time = v_ExecuteTime
                                                   AND NVL(c_exec_week_days, '') = NVL(v_ExecuteWeekDays, '')
                                                   AND NVL(c_skip_week_days, '') = NVL(v_SkipWeekDays, '')
                                                   AND c_month_to_date = NVL(v_monthtoDate, 0) );
                       EXCEPTION
                          WHEN OTHERS THEN
                             NULL;
                       END;
                          
                       IF v_temp = 1 THEN
                       
                       BEGIN
                          SELECT id_schedule_weekly 
              
                            INTO v_ScheduleId
                            FROM t_sch_weekly 
                           WHERE c_exec_time = v_ExecuteTime
                                   AND NVL(c_exec_week_days, '') = NVL(v_ExecuteWeekDays, '')
                                   AND NVL(c_skip_week_days, '') = NVL(v_SkipWeekDays, '')
                                   AND c_month_to_date = NVL(v_monthtoDate, 0);
                          v_bResult := 1 ;
                       END;
                       ELSE
                       
                       BEGIN
                          v_bResult :=/*dbo.*/Export_CreateWeeklySchedule(v_ExecuteTime,
                                                                          v_ExecuteWeekDays,
                                                                          v_SkipWeekDays,
                                                                          v_monthtoDate,
                                                                          v_ValidateOnly,
                                                                          v_ScheduleId);
                       END;
                       END IF;
                    END;
                    ELSE
                       IF v_ScheduleType = 'monthly' THEN
                       DECLARE
                          v_temp NUMBER(1, 0) := 0;
                       
                       BEGIN
                          BEGIN
                             SELECT 1 INTO v_temp
                               FROM DUAL
                              WHERE EXISTS ( SELECT * 
                                             FROM t_sch_monthly 
                                              WHERE c_exec_time = v_ExecuteTime
                                                      AND NVL(c_exec_day, 0) = NVL(v_ExecuteMonthDay, 0)
                                                      AND c_exec_first_month_day = NVL(v_ExecuteFirstDayOfMonth, 0)
                                                      AND c_exec_last_month_day = NVL(v_ExecuteLastDayOfMonth, 0)
                                                      AND NVL(c_skip_months, '') = NVL(v_SkipTheseMonths, '') );
                          EXCEPTION
                             WHEN OTHERS THEN
                                NULL;
                          END;
                             
                          IF v_temp = 1 THEN
                          
                          BEGIN
                             SELECT id_schedule_monthly 
              
                               INTO v_ScheduleId
                               FROM t_sch_monthly 
                              WHERE c_exec_time = v_ExecuteTime
                                      AND NVL(c_exec_day, 0) = NVL(v_ExecuteMonthDay, 0)
                                      AND c_exec_first_month_day = NVL(v_ExecuteFirstDayOfMonth, 0)
                                      AND c_exec_last_month_day = NVL(v_ExecuteLastDayOfMonth, 0)
                                      AND NVL(c_skip_months, '') = NVL(v_SkipTheseMonths, '');
                             v_bResult := 1 ;
                          END;
                          ELSE
                          
                          BEGIN
                             v_bResult :=/*dbo.*/Export_CreateMonthlySchedule(v_ExecuteTime,
                                                                              v_ExecuteMonthDay,
                                                                              v_ExecuteFirstDayOfMonth,
                                                                              v_ExecuteLastDayOfMonth,
                                                                              v_SkipTheseMonths,
                                                                              v_ValidateOnly,
                                                                              v_ScheduleId);
                          END;
                          END IF;
                       END;
                       END IF;
                    END IF;
                 END IF;
                 IF v_bResult = 0 THEN
                    ROLLBACK;
                 ELSE
                    COMMIT;
                 END IF;
                 RETURN v_bResult;
              END;
               	 