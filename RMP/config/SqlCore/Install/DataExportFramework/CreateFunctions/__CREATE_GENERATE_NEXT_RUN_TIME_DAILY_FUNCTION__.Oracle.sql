
              CREATE OR REPLACE FUNCTION GenerateNextRunTime_Daily
              (
                v_dtNow IN DATE,
                v_ExecuteTime IN CHAR
                /* format "HH:MM" in military */
                ,
                v_RepeatHours IN NUMBER DEFAULT NULL 
                /* hour number between repeats */
                ,
                v_ExecuteStartTime IN VARCHAR2 DEFAULT NULL 
                /* format "HH:MM" in military (start and end time provide a pocket of execution hours) */
                ,
                iv_ExecuteEndTime IN VARCHAR2 DEFAULT NULL 
                /* format "HH:MM" in military */
                ,
                v_SkipFirstDayOfMonth IN NUMBER DEFAULT NULL ,
                v_SkipLastDayOfMonth IN NUMBER DEFAULT NULL ,
                iv_DaysInterval IN NUMBER DEFAULT NULL 
              )
              RETURN DATE
              AS
                 v_DaysInterval NUMBER(10,0) := iv_DaysInterval;
                 v_ExecuteEndTime VARCHAR2(5) := iv_ExecuteEndTime;
                 v_dtNext DATE;
              
              BEGIN
                 v_DaysInterval := NVL(v_DaysInterval, 1) ;
                 v_ExecuteEndTime := NVL(v_ExecuteEndTime, '11:59') ;
                 IF NVL(v_RepeatHours, 0) = 0 THEN
                 DECLARE
                    v_tdt DATE;
                 
                 BEGIN
                    v_tdt := to_date(to_char(v_dtNow, 'MMDDYYYY'), 'MMDDYYYY');
                    v_dtNext := AddTimeToDate(v_tdt, v_ExecuteTime) ;
                    v_dtNext := v_dtNext + v_DaysInterval;
                 END;
                 /* RETURN @dtNext */
                 ELSE
                 DECLARE
                    v_dtExecuteStartTime DATE;
                    v_dtExecuteEndTime DATE;
                    v_tmpDate DATE;
                 
                 BEGIN
                    v_dtNext := v_dtNow ;
                    v_dtNext := v_dtNext + v_RepeatHours / 24;
                    IF LENGTH(NVL(v_ExecuteStartTime, '')) > 0 THEN
                    
                    BEGIN
                       v_tmpDate := to_date(to_char(v_dtNow, 'MMDDYYYY'), 'MMDDYYYY');
                       v_dtExecuteStartTime := AddTimeToDate(v_tmpDate, v_ExecuteStartTime) ;
                       IF LENGTH(NVL(v_ExecuteEndTime, '')) > 0 THEN
                       
                       BEGIN
                          v_dtExecuteEndTime := AddTimeToDate(v_tmpDate, v_ExecuteEndTime) ;
                          IF v_dtNext > v_dtExecuteStartTime THEN
                          
                          BEGIN
                             IF v_dtNext < v_dtExecuteEndTime THEN
                             
                             BEGIN
                                /* same day repeat run... */
                                /* SELECT 'IN HERE' */
                                /* RETURN @dtNext */
                                v_dtNext := v_dtNext ;
                             END;
                             ELSE
                             
                             BEGIN
                                /* since the new time falls outside the pocket - after end time, it will run at the next start time (pocket upper bound time) */
                                /* also the next run will be after the "daysInterval" has elapsed */
                                v_dtNext := v_dtExecuteStartTime + v_DaysInterval;
                             END;
                             END IF;
                          END;
                          /* RETURN @dtNext */
                          ELSE
                          
                          BEGIN
                             /* new time falls outside the pocket - before exec start date */
                             /* use the exec start time as next run time adding daysinterval */
                             v_dtNext := v_dtExecuteStartTime + v_DaysInterval;
                          END;
                          END IF;
                       END;
                       /* RETURN @dtNext */
                       ELSE
                       
                       BEGIN
                          /* no end time is provided - just add the repeat hours */
                          /* check if the result date is on the next day and if YES, add days interval and set next run datetime */
                          IF extract(day from v_dtNext) > extract(day from v_dtNow)
                            AND extract(month from v_dtNext) > extract(month from v_dtNow)
                            AND extract(year from v_dtNext) > extract (year from v_dtNow)
                            AND ( v_DaysInterval >= 1 ) THEN
                          
                          BEGIN
                             v_dtNext := v_dtExecuteStartTime + v_DaysInterval;
                          END;
                          /* RETURN @dtNext */
                          ELSE
                          
                          BEGIN
                             /* RETURN @dtNext */
                             v_dtNext := v_dtNext ;
                          END;
                          END IF;
                       END;
                       END IF;
                    END;
                    ELSE
                    
                    BEGIN
                       /* No pocket provided - just add hours */
                       /* check if the result date is on the next day and if YES, add days interval and set next run datetime */
                       IF extract(day from v_dtNext) > extract(day from v_dtNow)
                         AND extract(month from v_dtNext) > extract(month from v_dtNow)
                         AND extract(year from v_dtNext) > extract (year from v_dtNow)
                         AND ( v_DaysInterval >= 1 ) THEN
                       
                       BEGIN
                          v_tmpDate := to_date(to_char(v_dtNext, 'MMDDYYYY'), 'MMDDYYYY');
                          v_dtNext := AddTimeToDate(v_tmpDate, v_ExecuteTime) ;
                       END;
                       /* RETURN @dtNext */
                       ELSE
                          /* RETURN @dtNext */
                          v_dtNext := v_dtNext ;
                       END IF;
                    END;
                    END IF;
                 END;
                 END IF;
                 IF NVL(v_SkipLastDayOfMonth, 0) > 0
                   AND EXTRACT(month from (v_dtNext + 1)) > Extract(month from v_dtNext)
                   OR EXTRACT(year from (v_dtNext + 1)) > EXTRACT(year from v_dtNext) THEN
                 
                 BEGIN
                    v_dtNext := v_dtNext + 1;
                 END;
                 END IF;
                 IF ( NVL(v_SkipFirstDayOfMonth, 0) > 0
                   AND Extract(day from v_dtNext) = 1) THEN
                 
                 BEGIN
                    v_dtNext := v_dtNext + 1;
                 END;
                 END IF;
                 RETURN v_dtNext;
              END;
		