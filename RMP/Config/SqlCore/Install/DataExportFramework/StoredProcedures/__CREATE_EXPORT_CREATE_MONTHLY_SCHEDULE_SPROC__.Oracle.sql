
                                       
              CREATE OR REPLACE FUNCTION Export_CreateMonthlySchedule
              (
                v_ExecuteTime IN CHAR DEFAULT NULL 
                /*  format "HH:MM" in military */
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
                iv_SkipTheseMonths IN VARCHAR2 DEFAULT NULL 
                /*  comma seperated set of months that have to be skipped for the monthly schedule executes */
                ,
                v_ValidateOnly IN NUMBER DEFAULT NULL ,
                v_ScheduleId OUT NUMBER/* DEFAULT NULL*/
              )
              RETURN NUMBER
              AS
                  v_SkipTheseMonths VARCHAR2(35) := iv_SkipTheseMonths;
                  v_bResult NUMBER(1,0);
                  v_firstchar VARCHAR2(1);
                  v_lastchar VARCHAR2(1);
             
              BEGIN
                 v_bResult := 1 ;
                 IF NVL(v_ExecuteMonthDay, 0) = 0
                   AND NVL(v_ExecuteFirstDayOfMonth, 0) = 0
                   AND NVL(v_ExecuteLastDayOfMonth, 0) = 0 THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'An Execution Day is required for Monthly Schedule' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 END IF;
                 IF NVL(v_ExecuteMonthDay, 0) > 0
                   AND NVL(v_ExecuteFirstDayOfMonth, 0) = 1 THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'ExecuteMonthDay and ExecuteFirstDayOfMonth are Mutually Exclusive!' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 END IF;
                 IF NVL(v_ExecuteMonthDay, 0) > 0
                   AND NVL(v_ExecuteLastDayOfMonth, 0) = 1 THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'ExecuteMonthDay and ExecuteLastDayOfMonth are Mutually Exclusive!' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 END IF;
                 IF NVL(v_ExecuteFirstDayOfMonth, 0) = 1
                   AND NVL(v_ExecuteLastDayOfMonth, 0) = 1 THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'ExecuteFirstDayOfMonth and ExecuteLastDayOfMonth are Mutually Exclusive!' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 END IF;
				IF NVL (LENGTH(v_skipthesemonths), 0) > 0
					THEN
						BEGIN
							v_bresult := validatemonths (v_skipthesemonths);
							IF v_bresult = 0
							THEN
								BEGIN
									raise_application_error (-20002, 'Invalid SkipMonths Parameter!');
									RETURN v_bresult;
								END;
							ELSE
								BEGIN
								v_firstchar := SUBSTR (v_skipthesemonths, 0, 1);
								v_lastchar := SUBSTR (v_skipthesemonths, -1, 1);

								 IF v_firstchar = ','
								 THEN
									 BEGIN
										 v_skipthesemonths :=
											 SUBSTR (v_skipthesemonths,
													 2,
													 (NVL (LENGTH (v_skipthesemonths), 0) - 1));
									 END;
								 END IF;

								 IF v_lastchar = ','
								 THEN
									 BEGIN
										 v_skipthesemonths :=
											 SUBSTR (v_skipthesemonths,
													 1,
													 (NVL (LENGTH (v_skipthesemonths), 0) - 1));
									 END;
								 END IF;
								END;
							END IF;
						END;
					END IF;
                 IF v_ExecuteMonthDay > 31
                   OR v_ExecuteMonthDay < 0 THEN
                 
                 BEGIN
                    raise_application_error( -20002, 'Invalid Execute Day. Valid values are between 0 and 31!' );
                    v_bResult := 0 ;
                    RETURN v_bResult;
                 END;
                 END IF;
                 
                 IF v_ValidateOnly = 0 THEN
                 
                 BEGIN
                    INSERT INTO t_sch_monthly
                      ( c_exec_time, c_exec_day, c_exec_first_month_day, c_exec_last_month_day, c_skip_months )
                      VALUES ( v_ExecuteTime, v_ExecuteMonthDay, v_ExecuteFirstDayOfMonth, v_ExecuteLastDayOfMonth, v_SkipTheseMonths )
                      RETURNING id_schedule_monthly INTO v_ScheduleId;
                 END;
                 END IF;
                 RETURN v_bResult;
              END;
     