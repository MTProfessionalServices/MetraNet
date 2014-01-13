
              CREATE OR REPLACE FUNCTION ValidateWeekDay
              (
                v_InwkDay IN VARCHAR2
              )
              RETURN NUMBER
              AS
                 v_bResult NUMBER(1,0);
                 v_wkDays VARCHAR2(30);
                 v_iPos NUMBER(10,0);
                 v_iNextPos NUMBER(10,0);
                 v_tmp VARCHAR2(50);
              
              BEGIN
                 v_bResult := 0 ;
                 v_wkDays := 'MON,TUE,WED,THU,FRI,SAT,SUN,' ;
                 v_iPos := 1 ;
                 v_iNextPos := INSTR(v_wkDays, ',', v_iPos) ;
                 WHILE v_iNextPos > 0 
                 LOOP 
                    
                    BEGIN
                       v_tmp := SUBSTR(v_wkDays, v_iPos, (v_iNextPos - v_iPos)) ;
                       /* SELECT @tmp */
                       IF v_tmp = v_InwkDay THEN
                       
                       BEGIN
                          v_bResult := 1 ;
                          EXIT;
                       END;
                       ELSE
                       
                       BEGIN
                          v_iPos := v_iNextPos + 1 ;
                          v_iNextPos := INSTR(v_wkDays, ',', v_iPos) ;
                       END;
                       END IF;
                    END;
                 END LOOP;
                 RETURN v_bResult;
              END;
		