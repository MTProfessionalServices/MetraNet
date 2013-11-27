
              CREATE OR REPLACE FUNCTION ExportGetParmsAndValues
              (
                v_id_rep_instance_id IN NUMBER
              )
              RETURN VARCHAR2
              AS
                 v_retval VARCHAR2(200);
                 v_param_desc VARCHAR2(100);
                 v_param_value VARCHAR2(100);
                 CURSOR Working_csr
                   IS SELECT c_param_desc ,
                 c_param_value 
                   FROM t_export_default_param_values PARMVALUES
                   JOIN t_export_param_names PARMNAMES
                    ON PARMVALUES.id_param_name = PARMNAMES.id_param_name
                  WHERE id_rep_instance_id = v_id_rep_instance_id;
              
              BEGIN
                 OPEN Working_csr;
                 FETCH Working_csr INTO v_param_desc,v_param_value;
                 v_retval := '' ;
                 WHILE Working_csr%FOUND 
                 LOOP 
                    
                    BEGIN
                       v_retval := v_retval || CASE v_retval
                                                            WHEN '' THEN ''
                       ELSE ', '
                          END || v_param_desc || ' = ' || v_param_value ;
                       FETCH Working_csr INTO v_param_desc,v_param_value;
                    END;
                 END LOOP;
                 CLOSE Working_csr;
                 RETURN v_retval;
              END;
