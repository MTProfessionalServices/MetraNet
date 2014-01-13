-------------------------------------------------------------------------------------
-- This script changes DB columns with precision/scale (18,6) to (22,10),
-- preserving the isNullable property.
-------------------------------------------------------------------------------------

SET serveroutput ON format word_wrapped;

DECLARE -- top-level
tableName  VARCHAR2(256);
columnName VARCHAR2(256);
xType      VARCHAR2(256);
xPrec      INT;
xScale     INT;
isNullable VARCHAR2(1);
numAlteredNumber INT;
numAlteredDecimal INT;
numAlteredNumeric INT;
numSkipped INT;
dynQuery   VARCHAR2(4000);

-- Define the query that selects columns from tables (not views) that have
-- precision 18 and scale 6.
CURSOR theCursor IS  
    SELECT utc.table_name, utc.column_name, utc.data_type, 
            utc.data_precision,utc. data_scale, utc.nullable
      FROM user_tab_columns utc INNER JOIN user_tables ut  -- exclude views
        ON utc.table_name = ut.table_name
     WHERE utc.data_precision = 18 AND utc.data_scale = 6 AND 
           (utc.data_type = 'NUMBER'  OR  utc.data_type = 'DECIMAL'  OR  utc.data_type = 'NUMERIC')
  ORDER BY utc.table_name, utc.column_name;


BEGIN -- top-level

dbms_output.put_line(' ');
dbms_output.put_line('STARTING CONVERSION OF PRECISION/SCALE (18,6) COLUMNS TO (22,10)');
dbms_output.put_line(' ');

-- First drop constraint from t_recur_enum so we can update type of enum_value column.
FOR x IN (SELECT count(*) cnt FROM dual 
           WHERE EXISTS(
               SELECT * FROM user_constraints
                WHERE table_name = N'T_RECUR_ENUM' AND constraint_name = N'PK_T_RECUR_ENUM'
         ))
LOOP
    IF x.cnt = 1
    THEN
        dbms_output.put_line('Dropping pk_t_recur_enum constraint from t_recur_enum table');
        dbms_output.put_line(' ');
        EXECUTE IMMEDIATE 'ALTER TABLE t_recur_enum DROP CONSTRAINT pk_t_recur_enum';
    END IF;
END LOOP;


numAlteredNumber  := 0;
numAlteredDecimal := 0;
numAlteredNumeric := 0;
numSkipped := 0;

-- Loop through the (18,6) columns, converting them to (22,10).
OPEN theCursor;
LOOP
    FETCH theCursor INTO tableName, columnName, xType, xPrec, xScale, isNullable;
    EXIT WHEN theCursor%NOTFOUND;
  
    -- Double-check precision and scale here because the SELECT appears to
    -- pick up some other columns.
    IF  (xType != 'NUMBER'  AND  xType != 'DECIMAL'  AND  xType != 'NUMERIC')
        OR  xPrec != 18  OR  xScale != 6
    THEN
        numSkipped := numSkipped + 1;
        dbms_output.put_line('*** SKIPPING ' || tableName || '/' || columnName || ' with type(precision,scale) ' || 
              xType || '(' || TO_CHAR(xPrec) || ',' || TO_CHAR(xScale) || ') ***');

    ELSIF xType = 'NUMBER'  -- NUMBER columns
    THEN
       numAlteredNumber := numAlteredNumber + 1;
       dbms_output.put_line('Altering NUMBER ' || tableName || '/' || columnName);
       dynQuery := 'ALTER TABLE ' || tableName || ' MODIFY (' || columnName || ' NUMBER(22,10))';
       EXECUTE IMMEDIATE dynQuery;
    
    ELSIF xType = 'DECIMAL'  -- DECIMAL columns
    THEN
       numAlteredDecimal := numAlteredDecimal + 1;
       dbms_output.put_line('Altering DECIMAL ' || tableName || '/' || columnName);
       dynQuery := 'ALTER TABLE ' || tableName || ' MODIFY (' || columnName || ' DECIMAL(22,10))';
       EXECUTE IMMEDIATE dynQuery;

    ELSE  -- NUMERIC columns
       numAlteredNumeric := numAlteredNumeric + 1;
       dbms_output.put_line('Altering NUMERIC ' || tableName || '/' || columnName);
       dynQuery := 'ALTER TABLE ' || tableName || ' MODIFY (' || columnName || ' NUMERIC(22,10))';
       EXECUTE IMMEDIATE dynQuery;
       
    END IF;
    
END LOOP;

CLOSE theCursor;


-- Finally, restore constraint to t_recur_enum table.
FOR x IN (SELECT count(*) cnt
             FROM dual 
            WHERE EXISTS(SELECT * FROM user_tables WHERE table_name = N'T_RECUR_ENUM'))
LOOP
    IF x.cnt = 1
    THEN
        dbms_output.put_line(' ');
        dbms_output.put_line('Restoring pk_t_recur_enum constraint to t_recur_enum table');
        EXECUTE IMMEDIATE 'ALTER TABLE t_recur_enum ADD CONSTRAINT pk_t_recur_enum PRIMARY KEY (id_prop, enum_value)';
    END IF;
END LOOP;


dbms_output.put_line(' ');
dbms_output.put_line('END CONVERSION OF PRECISION/SCALE (18,6) COLUMNS TO (22,10)');
dbms_output.put_line('CONVERTED ' || TO_CHAR(numAlteredNumber) || ' NUMBER, ' || 
      TO_CHAR(numAlteredNumeric) || ' NUMERIC, AND ' || 
      TO_CHAR(numAlteredDecimal) || ' DECIMAL COLUMNS; SKIPPED ' || 
      TO_CHAR(numSkipped) || ' COLUMNS');
dbms_output.put_line(' ');


COMMIT;

END;  -- top-level
