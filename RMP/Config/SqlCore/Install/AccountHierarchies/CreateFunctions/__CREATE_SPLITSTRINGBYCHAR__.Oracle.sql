
CREATE OR REPLACE FUNCTION SplitStringByChar(Str varchar2, Delimiter varchar2)
RETURN String_Table PIPELINED
IS
    startPosition INTEGER := 0;
    endPosition INTEGER := -1;
    Slice VARCHAR2(256);
BEGIN
    WHILE endPosition <> LENGTH(Str) + 1 LOOP
         IF endPosition < 0 THEN
             endPosition := startPosition;
         END IF;
         
         startPosition := endPosition + 1;
         endPosition := INSTR(Str, Delimiter, startPosition);
         
         IF endPosition = 0 THEN
             endPosition := LENGTH(Str) + 1;
         END IF;
         
         Slice := SUBSTR(Str, startPosition, endPosition - startPosition);
         
         PIPE ROW (String_Record(Slice));
    END LOOP;
END;

