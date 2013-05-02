
              CREATE OR REPLACE FUNCTION ExportGetProcParms
              (
                v_proc_name IN VARCHAR2
              )
              RETURN VARCHAR2
              AS
                 v_retval VARCHAR2(300);
                 v_column_name VARCHAR2(100);
                   CURSOR Working_csr
                   IS SELECT   argument_name
                      FROM   all_arguments
                      WHERE   object_name = UPPER (v_proc_name)
                      ORDER BY   position;
              
              BEGIN
                 OPEN Working_csr;
                 FETCH Working_csr INTO v_column_name;
                 v_retval := '' ;
                 WHILE Working_csr%FOUND 
                 LOOP 
                    
                    BEGIN
                       v_retval := v_retval || '%' || '%' || v_column_name || '%' || '%' || ',' ;
                       FETCH Working_csr INTO v_column_name;
                    END;
                 END LOOP;
                 CLOSE Working_csr;
                 v_retval := SUBSTR(v_retval, 1, (NVL(LENGTH(v_retval), 0) - 1));
                 RETURN v_retval;
              END;
	 