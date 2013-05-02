
              CREATE OR REPLACE FUNCTION ValidateMonths
              (
                iv_InMonths IN VARCHAR2
              )
              RETURN NUMBER
              AS
                 v_InMonths VARCHAR2(35) := iv_InMonths;
                 v_bResult NUMBER(1,0);
                 v_iPos NUMBER(10,0);
                 v_iNextPos NUMBER(10,0);
                 v_tmp VARCHAR2(50);
              
              BEGIN
                 v_bResult := 0 ;
                 IF NVL(LENGTH(v_inmonths),0) = 0
				 THEN
						RETURN v_bresult;
				 END IF;
                 IF SUBSTR(v_InMonths, NVL(LENGTH(v_InMonths), 0), 1) <> ',' THEN
                    v_InMonths := v_InMonths || ',' ;
                 END IF;
                 v_iPos := 1 ;
                 v_iNextPos := INSTR(v_InMonths, ',', v_iPos) ;
                 WHILE v_iNextPos > 0 
                 LOOP 
                    
                    BEGIN
                       v_tmp := SUBSTR(v_InMonths, v_iPos, (v_iNextPos - v_iPos)) ;
                       v_bResult := ValidateMonth(CAST(v_tmp AS NUMBER)) ;
                       IF v_bResult = 0 THEN
                          EXIT;
                       ELSE
                       
                       BEGIN
                          v_iPos := v_iNextPos + 1 ;
                          v_iNextPos := INSTR(v_InMonths, ',', v_iPos) ;
                       END;
                       END IF;
                    END;
                 END LOOP;
                 RETURN v_bResult;
              END;
		