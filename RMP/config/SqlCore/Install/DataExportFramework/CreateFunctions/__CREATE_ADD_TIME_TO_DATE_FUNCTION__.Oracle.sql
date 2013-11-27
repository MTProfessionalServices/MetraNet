
            CREATE OR REPLACE FUNCTION AddTimeToDate
            (
              v_dt IN DATE,
              v_time IN CHAR
            )
            RETURN DATE
            AS
               v_tdt DATE;
               v_hours NUMBER(10,0);
               v_minutes NUMBER(10,0);
               v_ipos NUMBER(10,0);
               v_inextpos NUMBER(10,0);

            BEGIN
               v_ipos := 1 ;
               v_inextpos := 0 ;
               v_inextpos := INSTR(v_time, ':', v_ipos) ;
               v_hours := SUBSTR(v_time, v_ipos, v_inextpos - v_ipos) ;
               v_minutes := SUBSTR(v_time, v_inextpos + 1, NVL(LENGTH(v_time), 0)) ;
               v_tdt := v_dt + 1/24 * v_hours;
               v_tdt := v_tdt +1/1440 * v_minutes;
               RETURN v_tdt;
            END;
		