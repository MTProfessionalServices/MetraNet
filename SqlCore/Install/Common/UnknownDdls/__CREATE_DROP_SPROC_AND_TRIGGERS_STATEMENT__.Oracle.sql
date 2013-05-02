
        SELECT decode(object_type,
          'PROCEDURE','DROP PROCEDURE'||' '|| OBJECT_NAME,
          'TRIGGER','DROP TRIGGER'||' '||OBJECT_NAME,
          'PACKAGE', 'DROP PACKAGE'||' '||OBJECT_NAME,
          'SEQUENCE','DROP SEQUENCE'||' '|| OBJECT_NAME,
          'VIEW','DROP VIEW'||' '|| OBJECT_NAME,
          'FUNCTION','DROP FUNCTION'||' '||OBJECT_NAME) as statement
        FROM USER_OBJECTS WHERE OBJECT_TYPE
        IN ('PROCEDURE', 'TRIGGER', 'PACKAGE', 'SEQUENCE','FUNCTION', 'VIEW')
        