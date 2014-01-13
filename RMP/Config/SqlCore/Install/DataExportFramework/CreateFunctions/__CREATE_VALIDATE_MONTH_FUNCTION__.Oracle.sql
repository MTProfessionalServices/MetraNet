
              CREATE OR REPLACE FUNCTION ValidateMonth
              (
                v_InMonth IN NUMBER
              )
              RETURN NUMBER
              AS
                 v_bResult NUMBER(1,0);
                 v_months VARCHAR2(36);
                 v_iPos NUMBER(10,0);
                 v_iNextPos NUMBER(10,0);
                 v_tmp VARCHAR2(50);
              
              BEGIN
                 v_bResult := 0 ;
                 v_months := '01,02,03,04,05,06,07,08,09,10,11,12,' ;
                 v_iPos := 1 ;
                 v_iNextPos := INSTR(v_months, ',', v_iPos) ;
                 WHILE v_iNextPos > 0 
                 LOOP 
                    
                    BEGIN
                       v_tmp := SUBSTR(v_months, v_iPos, (v_iNextPos - v_iPos)) ;
                        IF CAST(v_tmp AS NUMBER) = v_InMonth THEN
                       
                       BEGIN
                          v_bResult := 1 ;
                          EXIT;
                       END;
                       ELSE
                       
                       BEGIN
                          v_iPos := v_iNextPos + 1 ;
                          v_iNextPos := INSTR(v_months, ',', v_iPos) ;
                       END;
                       END IF;
                    END;
                 END LOOP;
                 RETURN v_bResult;
              END;
		