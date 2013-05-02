
            CREATE OR REPLACE FUNCTION GenerateNextRunTime_Monthly
            (
               iv_dtnow                   IN DATE,
    v_executetime              IN CHAR/*  format "HH:MM" in military */
    ,
    iv_executemonthday         IN NUMBER DEFAULT NULL/*  Day of the month when to execute */
    ,
    v_executefirstdayofmonth   IN NUMBER DEFAULT NULL/*  Execute on the first day of the month */
    ,
    v_executelastdayofmonth    IN NUMBER DEFAULT NULL/*  Execute on the last day of the month */
    ,
    iv_skipthesemonths         IN VARCHAR2 DEFAULT NULL)
    RETURN DATE
AS
    v_skipthesemonths   VARCHAR2 (35) := iv_skipthesemonths;
    v_dtnow             DATE := iv_dtnow;
    v_executemonthday   NUMBER (10, 0) := iv_executemonthday;
    v_dtnext            DATE;
    v_bvalid            NUMBER (1, 0);
    v_iposskip          NUMBER (10, 0);
    v_inextposskip      NUMBER (10, 0);
    v_tmpskip           NUMBER (10, 0);
    v_skipdtnext        DATE;
/*  comma seperated set of months that have to be skipped for the monthly schedule executes */
BEGIN
     v_bvalid := 0;

		IF NVL(LENGTH(v_skipthesemonths),0) <> 0
		THEN
			BEGIN
				IF SUBSTR (v_skipthesemonths, NVL (LENGTH (v_skipthesemonths), 0), 1) <> ','
			   THEN
				  v_skipthesemonths := v_skipthesemonths || ',';
			   END IF;
				  v_iposskip := 1;
				  v_inextposskip := INSTR (v_skipthesemonths, ',', v_iposskip);
				  v_skipdtnext:= v_dtnow;

					WHILE v_inextposskip > 0
					LOOP
						BEGIN
							v_tmpskip := CAST (SUBSTR (v_skipthesemonths, v_iposskip,(v_inextposskip - v_iposskip)) AS NUMBER);

								IF EXTRACT (MONTH FROM v_skipdtnext) = v_tmpskip
								THEN
									v_skipdtnext := ADD_MONTHS (v_skipdtnext, 1);
								 END IF;
							   IF EXTRACT (MONTH FROM v_skipdtnext) = EXTRACT (MONTH FROM v_dtnow) AND EXTRACT (MONTH FROM ADD_MONTHS (v_skipdtnext,1)) = v_tmpskip AND EXTRACT(DAY FROM v_dtnow) >=  v_executemonthday
							   THEN
								v_skipdtnext := ADD_MONTHS (v_skipdtnext, 2);
							   END IF;
							v_iposskip := v_inextposskip + 1;
							v_inextposskip := INSTR (v_skipthesemonths, ',', v_iposskip);
						END;
					END LOOP;
				   IF MONTHS_BETWEEN(v_skipdtnext, v_dtnow) <> 0
				   THEN
						IF NVL(v_executefirstdayofmonth,0) = 1
						THEN
						v_skipdtnext:= TO_DATE (TO_CHAR (v_skipdtnext, 'YYYYMM') || '01', 'YYYYMMDD');
						ELSE
						IF NVL(v_executelastdayofmonth,0) = 1
						THEN
							v_skipdtnext:= LAST_DAY(v_skipdtnext);
						ELSE
							v_skipdtnext:= TO_DATE (TO_CHAR (v_skipdtnext, 'YYYYMM')|| CAST (v_executemonthday AS VARCHAR2),'YYYYMMDD');
						END IF;
						END IF;
				   v_skipdtnext := addtimetodate (v_dtnext, v_executetime);
				   RETURN v_skipdtnext;
				   END IF;
			END;
		END IF;

		IF NVL(v_executefirstdayofmonth,0) = 1 THEN
			v_dtnext := ADD_MONTHS(TO_DATE (TO_CHAR (v_dtnow, 'YYYYMM') || '01', 'YYYYMMDD'), 1);
		ELSE
			IF NVL(v_executelastdayofmonth,0) = 1 THEN
				IF EXTRACT(DAY FROM v_dtnow) < EXTRACT(DAY FROM LAST_DAY(v_dtnow)) THEN
					v_dtnext := LAST_DAY(v_dtnow);
				ELSE
					v_dtnext := ADD_MONTHS(LAST_DAY(v_dtnow), 1);
				END IF;
			ELSE				
				IF EXTRACT(DAY FROM v_dtnow) <  v_executemonthday THEN
					v_dtnext:= TO_DATE (TO_CHAR (v_dtnow, 'YYYYMM')|| CAST (v_executemonthday AS VARCHAR2),'YYYYMMDD');
				ELSE
					 v_dtnext:= ADD_MONTHS(TO_DATE (TO_CHAR (v_dtnow, 'YYYYMM')|| CAST (v_executemonthday AS VARCHAR2),'YYYYMMDD'),1);
				END IF;
			END IF;
		END IF;

		v_dtnext := addtimetodate (v_dtnext, v_executetime);

		IF EXTRACT(DAY FROM v_dtnow) = EXTRACT(DAY FROM v_dtnext)
		AND TO_CHAR(v_dtnow,'HH24:MI')< TO_CHAR(v_dtnext,'HH24:MI')
		THEN
			v_dtnext := TO_DATE (TO_CHAR (v_dtnow, 'YYYYMM')|| CAST(EXTRACT(DAY FROM v_dtnext) AS VARCHAR2),'YYYYMMDD');
		END IF;
	   RETURN v_dtnext;	
	 END;
		