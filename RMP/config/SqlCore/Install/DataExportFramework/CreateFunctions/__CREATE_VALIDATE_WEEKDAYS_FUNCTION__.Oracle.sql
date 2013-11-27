
              CREATE OR REPLACE FUNCTION ValidateWeekDays
              (
                iv_InwkDays IN VARCHAR2
              )
              RETURN NUMBER
              AS
                 v_InwkDays VARCHAR2(30) := iv_InwkDays;
                 v_bResult NUMBER(1,0);
                 v_iPos NUMBER(10,0);
                 v_iNextPos NUMBER(10,0);
                 v_tmp VARCHAR2(50);
              
              BEGIN
                 v_bResult := 0 ;
				 IF NVL(LENGTH(v_inwkdays),0) = 0
				 THEN
					RETURN v_bresult;
				 END IF;
    
                 IF SUBSTR(v_InwkDays, NVL(LENGTH(v_InwkDays), 0), 1) <> ',' THEN
                    v_InwkDays := v_InwkDays || ',' ;
                 END IF;
                 
                IF SUBSTR (v_InwkDays, 1, 1) = ','
				THEN
					v_InwkDays := SUBSTR(v_InwkDays, 2, LENGTH (v_InwkDays)) ;
				END IF;
				
                 v_iPos := 1 ;
                 v_iNextPos := INSTR(v_InwkDays, ',', v_iPos) ;
                 WHILE v_iNextPos > 0 
                 LOOP 
                    
                    BEGIN
                       v_tmp := SUBSTR(v_InwkDays, v_iPos, (v_iNextPos - v_iPos)) ;
                       v_bResult := ValidateWeekDay(v_tmp) ;
                       IF v_bResult = 0 THEN
                          EXIT;
                       ELSE
                       
                       BEGIN
                          v_iPos := v_iNextPos + 1 ;
                          v_iNextPos := INSTR(v_InwkDays, ',', v_iPos) ;
                       END;
                       END IF;
                    END;
                 END LOOP;
                 RETURN v_bResult;
              END;
		