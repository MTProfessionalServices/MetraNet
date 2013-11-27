/* 	InsertAcctUsageWithUID obsolete since 5.0 release */
DECLARE
   l_cnt         PLS_INTEGER;
   l_proc_name   user_objects.object_name%TYPE;
BEGIN
   l_proc_name   := UPPER ('InsertAcctUsageWithUID');

   SELECT COUNT ( * )
   INTO l_cnt
   FROM user_objects
   WHERE object_name = l_proc_name AND object_type = 'PROCEDURE';

   IF (l_cnt = 1)
   THEN
      DBMS_OUTPUT.put_line ('dropping procedure ' || l_proc_name);

      EXECUTE IMMEDIATE 'drop procedure ' || l_proc_name;
   END IF;
END;
/

/* Leave above blank line */

