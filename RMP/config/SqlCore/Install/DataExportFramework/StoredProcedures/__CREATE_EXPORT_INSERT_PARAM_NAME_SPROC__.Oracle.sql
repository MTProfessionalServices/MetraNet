                                     
              CREATE OR REPLACE PROCEDURE export_InsertParamName
              (
                p_paramName IN VARCHAR2 DEFAULT NULL ,
                p_paramDesc IN VARCHAR2 DEFAULT NULL 
              )
              AS
                 p_temp NUMBER(1, 0) := 0;
              
              BEGIN
                 BEGIN
                    SELECT 1 INTO p_temp
                      FROM DUAL
                     WHERE NOT EXISTS ( SELECT * 
                                        FROM t_export_param_names 
                                         WHERE c_param_name = '%' || '%' || p_paramName || '%' || '%' );
                 EXCEPTION
                    WHEN OTHERS THEN
                       NULL;
                 END;
                    
                 IF p_temp = 1 THEN
                    INSERT INTO t_export_param_names
                      ( c_param_name, c_param_desc )
                      VALUES ( '%' || '%' || p_paramName || '%' || '%', p_paramDesc );
                 ELSE
                 raise_application_error( -20002, p_paramName || ' parameter already exists in DB.' );
                 END IF;
              END;
	