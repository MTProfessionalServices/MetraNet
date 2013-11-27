
      CREATE OR REPLACE FUNCTION GenerateNextRunTime_Weekly
      (
        iv_dtNow IN DATE,
        v_ExecuteTime IN CHAR
        /* format "HH:MM" in military */
        ,
        iv_ExecWeekDays IN VARCHAR2 DEFAULT NULL ,
        iv_SkipWeekDays IN VARCHAR2 DEFAULT NULL 
      )
      RETURN DATE
      AS
          v_ExecWeekDays VARCHAR2(30) := iv_ExecWeekDays;
          v_SkipWeekDays VARCHAR2(30) := iv_SkipWeekDays;
          v_dtNow DATE := iv_dtNow;
          v_dtNext DATE;
          v_bValid NUMBER(1,0);
          v_iDay NUMBER(10,0);
          v_bResult NUMBER(1,0);
          v_iPos NUMBER(10,0);
          v_iNextPos NUMBER(10,0);
          v_tmp VARCHAR2(50);
          v_tdt DATE;
          v_iPosSkip NUMBER(10,0);
          v_iNextPosSkip NUMBER(10,0);
          v_tmpSkip VARCHAR2(50);
              
      BEGIN
          v_bValid := 0 ;
          IF SUBSTR(v_ExecWeekDays, NVL(LENGTH(v_ExecWeekDays), 0), 1) <> ',' THEN
            v_ExecWeekDays := v_ExecWeekDays || ',' ;
          END IF;
          IF SUBSTR(v_SkipWeekDays, NVL(LENGTH(v_SkipWeekDays), 0), 1) <> ',' THEN
            v_SkipWeekDays := v_SkipWeekDays || ',' ;
          END IF;
          v_tdt := to_date(to_char(v_dtNow, 'DDMMYYYY'), 'DDMMYYYY');
          v_dtNow := AddTimeToDate(v_tdt, v_ExecuteTime) ;
          v_dtNext := v_dtNow ;
          IF LENGTH(NVL(v_ExecWeekDays, '')) > 0 THEN
                 
          BEGIN
            v_iDay := 1 ;
            WHILE v_iDay <= 7 
            LOOP 
                       
                BEGIN
                  v_tdt := v_dtNow + v_iDay;
                  v_iPos := 1 ;
                  v_iNextPos := INSTR(v_ExecWeekDays, ',', v_iPos) ;
                  WHILE v_iNextPos > 0 
                  LOOP 
                             
                      BEGIN
                        v_tmp := SUBSTR(v_ExecWeekDays, v_iPos, (v_iNextPos - v_iPos)) ;
                        v_bResult := ValidateWeekDay(v_tmp) ;
                        IF v_bResult = 0 THEN
                                
                        BEGIN
                            v_bValid := -1 ;
                            v_dtNext := NULL ;
                            EXIT;
                        END;
                        ELSE
                                
                        BEGIN
                            IF SUBSTR(to_char(v_tdt, 'DAY'), 0, 3) = v_tmp THEN
                                   
                            BEGIN
                              v_dtNext := v_tdt ;
                              v_bValid := 1 ;
                              EXIT;
                            END;
                            END IF;
                            v_iPos := v_iNextPos + 1 ;
                            v_iNextPos := INSTR(v_ExecWeekDays, ',', v_iPos) ;
                        END;
                        END IF;
                      END;
                  END LOOP;
                  IF v_bValid < 0 THEN
                          
                  BEGIN
                      v_dtNext := NULL ;
                  END;
                  /* RAISERROR ('Invalid Execute week days', 16, 1) */
                  ELSE
                          
                  BEGIN
                      v_iPosSkip := 1 ;
                      v_iNextPosSkip := INSTR(v_SkipWeekDays, ',', v_iPosSkip) ;
                      WHILE v_iNextPosSkip > 0 
                      LOOP 
                                
                        BEGIN
                            v_tmpSkip := SUBSTR(v_SkipWeekDays, v_iPosSkip, (v_iNextPosSkip - v_iPosSkip)) ;
                            v_bResult := ValidateWeekDay(v_tmpSkip) ;
                            IF v_bResult = 0 THEN
                                   
                            BEGIN
                              v_bValid := -1 ;
                              v_dtNext := NULL ;
                              EXIT;
                            END;
                            ELSE
                                   
                            BEGIN
                              IF SUBSTR(to_char(v_dtNext, 'DAY'), 0, 3) = v_tmpSkip THEN
                                      
                              BEGIN
                                  v_bValid := 0 ;
                                  EXIT;
                              END;
                              END IF;
                              v_iPosSkip := v_iNextPosSkip + 1 ;
                              v_iNextPosSkip := INSTR(v_SkipWeekDays, ',', v_iPosSkip) ;
                            END;
                            END IF;
                        END;
                      END LOOP;
                      IF v_bValid > 0 THEN
                        EXIT;
                      END IF;
                  END;
                  END IF;
                  v_iDay := v_iDay + 1 ;
                END;
            END LOOP;
          END;
          ELSE
            v_dtNext := v_dtNow + 7;
          END IF;
          RETURN v_dtNext;
      END;
		