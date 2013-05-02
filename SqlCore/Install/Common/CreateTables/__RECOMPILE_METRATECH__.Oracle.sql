
create or replace procedure RecompileMetraTech
AS
   CURSOR mypkg
   IS
      SELECT  object_name,object_type FROM user_objects
       WHERE status = 'INVALID';

   InvalidObject   VARCHAR (256);
   objecttype VARCHAR (256);
   prevcount      INTEGER       := -1;
   current_count  INTEGER       := 0;
   sql_statement varchar(1000);
BEGIN
   dbms_output.put_line('Starting recompilation process...');
   LOOP
      current_count := 0;
      OPEN mypkg;
      LOOP
         FETCH mypkg INTO InvalidObject,objecttype;
         EXIT WHEN mypkg%NOTFOUND;
         current_count := current_count + 1;
         sql_statement :=
         case objecttype
          when 'PROCEDURE' then
           'alter procedure ' || InvalidObject || ' compile'
          when 'PACKAGE BODY' then
           'alter package ' || InvalidObject || ' compile body'
          when 'FUNCTION' then
           'alter function ' || InvalidObject || ' compile'
          when 'VIEW' then
           'alter view ' || InvalidObject || ' compile'
          else 'badstr'
          end;
          dbms_output.put_line('objecttype is ' || objecttype);
          dbms_output.put_line('sqlstring is ' || sql_statement);
         if sql_statement <> 'badstr' then
          dbms_output.put_line('recompiling ' || InvalidObject);
          begin
           execute immediate sql_statement;
           exception when others then
            sql_statement := '';
          end;
         end if;
      END LOOP;
      CLOSE mypkg;
      dbms_output.put_line('Recompiled ' || current_count || ' objects.');

       EXIT WHEN current_count = 0
             OR current_count = prevcount;
       prevcount := current_count;
   END LOOP;
end;
        