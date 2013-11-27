CREATE OR REPLACE FUNCTION Export_CreateWeeklySchedule
(
v_ExecuteTime IN CHAR DEFAULT NULL 
/*  format "HH:MM" in military */
,
iv_ExecuteWeekDays IN VARCHAR2 DEFAULT NULL 
/*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN" */
,
iv_SkipWeekDays IN VARCHAR2 DEFAULT NULL 
/*  Weekdays passed in as "MON,TUE,WED,THU,FRI,SAT,SUN" */
,
v_monthtoDate IN NUMBER DEFAULT NULL ,
v_ValidateOnly IN NUMBER DEFAULT NULL ,
v_ScheduleId OUT NUMBER/* DEFAULT NULL*/
)
RETURN NUMBER
AS
v_SkipWeekDays VARCHAR2(30) := iv_SkipWeekDays;
v_ExecuteWeekDays VARCHAR2(30) := iv_ExecuteWeekDays;
v_bResult NUMBER(1,0);

v_firstchar VARCHAR2(1);
v_lastchar VARCHAR2(1);
v_firstchar_ew VARCHAR2(1);
v_lastchar_ew VARCHAR2(1);

BEGIN
 v_bResult := 1 ;
 IF NVL (LENGTH (v_executeweekdays), 0) = 0
	THEN
		raise_application_error (-20002, 'ExecuteWeekDays Parameter is Required for Weekly Schedule');
	ELSE

	v_lastchar_ew := SUBSTR (v_executeweekdays, 0, 1);
	v_lastchar_ew := SUBSTR (v_executeweekdays, -1, 1);

	IF v_firstchar_ew = ','
	THEN
		BEGIN
			v_executeweekdays :=
				SUBSTR (v_executeweekdays,
						2,
						(NVL (LENGTH (v_executeweekdays), 0) - 1));
		END;
	END IF;

	IF v_lastchar_ew = ','
	THEN
		BEGIN
			v_executeweekdays :=
				SUBSTR (v_executeweekdays,
						1,
						(NVL (LENGTH (v_executeweekdays), 0) - 1));
		END;
	END IF;

	v_bresult := validateweekdays (v_executeweekdays);

	IF v_bresult = 0
	THEN
		BEGIN
			raise_application_error (-20002,
									 'ExecuteWeekDays Parameter is Invalid');
			v_bresult := 0;
			RETURN v_bresult;
		END;
	END IF;
END IF;

  IF NVL(LENGTH(v_skipweekdays),0)> 0
	THEN
		BEGIN
			v_bresult := validateweekdays (v_skipweekdays);
			IF v_bresult = 0
			THEN
				BEGIN
					raise_application_error (-20002, 'SkipWeekDays Parameter is Invalid');
					v_bresult := 0;
					RETURN v_bresult;
				END;
			ELSE
				BEGIN
				v_firstchar := SUBSTR (v_skipweekdays, 0, 1);
				v_lastchar := SUBSTR (v_skipweekdays, -1, 1);

				IF v_firstchar = ','
				THEN
				  BEGIN
					  v_skipweekdays :=
						  SUBSTR (v_skipweekdays,
								  2,
								  (NVL (LENGTH (v_skipweekdays), 0) - 1));
				  END;
				END IF;

				 IF v_lastchar = ','
				 THEN
					BEGIN
						v_skipweekdays :=
							SUBSTR (v_skipweekdays,
									1,
									(NVL (LENGTH (v_skipweekdays), 0) - 1));
					END;
				 END IF;
				END;
		   END IF;
		END;
	END IF;
 IF v_ValidateOnly = 0 THEN
 
 BEGIN
	INSERT INTO t_sch_weekly
	  ( c_exec_time, c_exec_week_days, c_skip_week_days, c_month_to_date )
	  VALUES ( v_ExecuteTime, v_ExecuteWeekDays, v_SkipWeekDays, NVL(v_monthtoDate, 0) )
	  RETURNING id_schedule_weekly INTO v_ScheduleId;
 END;
 END IF;
 RETURN v_bResult;
END;
			  