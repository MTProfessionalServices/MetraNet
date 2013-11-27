
            CREATE OR REPLACE FUNCTION IsNumeric 
            (
                p_value IN VARCHAR2
            )
            RETURN NUMBER
            AS
               v_number   NUMBER;
            BEGIN
               v_number := TO_NUMBER (p_value);
               RETURN 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN 0;
            END IsNumeric;
		      