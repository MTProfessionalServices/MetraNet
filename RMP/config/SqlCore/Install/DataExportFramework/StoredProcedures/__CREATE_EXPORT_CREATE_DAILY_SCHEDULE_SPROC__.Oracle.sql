                                       
              CREATE OR REPLACE FUNCTION Export_CreateDailySchedule
              (
                v_ExecuteTime IN CHAR DEFAULT NULL 
                /* format "HH:MM" in military */
                ,
                v_RepeatHours IN NUMBER DEFAULT NULL 
                /*  hour number between repeats */
                ,
                v_ExecuteStartTime IN VARCHAR2 DEFAULT NULL 
                /*  format "HH:MM" in military (start and end time provide a pocket of execution hours) */
                ,
                v_ExecuteEndTime IN VARCHAR2 DEFAULT NULL 
                /*  format "HH:MM" in military */
                ,
                v_SkipFirstDayOfMonth IN NUMBER DEFAULT NULL ,
                v_SkipLastDayOfMonth IN NUMBER DEFAULT NULL ,
                v_DaysInterval IN NUMBER DEFAULT NULL ,
                v_monthtoDate IN NUMBER DEFAULT NULL ,
                iv_ValidateOnly IN NUMBER DEFAULT NULL ,
                v_ScheduleId OUT NUMBER/* DEFAULT NULL*/
              )
              RETURN NUMBER
              AS
                 v_ValidateOnly NUMBER(1,0) := iv_ValidateOnly;
                 v_bResult NUMBER(1,0);
              
              BEGIN
                 v_bResult := 1 ;
                 v_ScheduleId := 0 ;
                 v_ValidateOnly := NVL(v_ValidateOnly, 0);

                 IF NVL(LENGTH(v_ExecuteStartTime), 0) = 0
                   AND LENGTH(NVL(v_ExecuteEndTime, '')) > 0 THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'No Corresponding Execute Start Time provided for the Execute End Time' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 END IF;
                 IF NVL(LENGTH(v_ExecuteStartTime), 0) = 0
                   AND NVL(LENGTH(v_ExecuteTime), 0) = 0 THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'Invalid Schedule! No Execute Time provided.' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 END IF;
                 IF LENGTH(NVL(v_ExecuteStartTime, '')) > 0 THEN
                 
                 BEGIN
                    /* Validate execute time value */
                    IF (TO_TIMESTAMP (v_executestarttime,'HH24:MI') > TO_TIMESTAMP(v_executetime,'HH24:MI')) THEN
                    BEGIN
                       raise_application_error( -20002, 'Execute Time should be equal to or greater than Execute Start Time' );
                       v_bResult := 0 ;
                       RETURN v_bResult;
                    END;
                    END IF;
                 END;
                 END IF;
                 IF NVL(v_DaysInterval, 0) > 0 THEN
                 
                 BEGIN
                    IF v_DaysInterval >= 7 THEN
                    
                    BEGIN
                       raise_application_error( -20002, 'Execute Days Interval is >= 7. Setup a Weekly Schedule for this' );
                       v_bResult := 0 ;
                       RETURN v_bResult;
                    END;
                    END IF;
                 END;
                 END IF;
                 IF NVL(v_RepeatHours, 0) > 24 THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'Cannot have repeat hours greater than 24, use DaysInterval instead.' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 END IF;
                 IF ( v_ValidateOnly = 0 ) THEN
                 
                 BEGIN
                    INSERT INTO t_sch_daily
                      ( c_exec_time, c_repeat_hour, c_exec_start_time, c_exec_end_time, c_skip_last_day_month, c_skip_first_day_month, c_days_interval, c_month_to_date )
                      VALUES ( v_ExecuteTime, NVL(v_RepeatHours, 0), v_ExecuteStartTime, v_ExecuteEndTime, NVL(v_SkipFirstDayOfMonth, 0), NVL(v_SkipLastDayOfMonth, 0), NVL(v_DaysInterval, 1), NVL(v_monthtoDate, 0) )
                      RETURNING id_schedule_daily INTO v_ScheduleId;
                 END;
                 END IF;
                 RETURN v_bResult;
              END;
	 