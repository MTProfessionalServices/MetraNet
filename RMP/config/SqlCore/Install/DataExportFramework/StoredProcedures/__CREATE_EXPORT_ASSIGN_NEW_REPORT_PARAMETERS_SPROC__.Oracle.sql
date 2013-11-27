                                      
                                       
              CREATE OR REPLACE PROCEDURE Export_AssignNewReportParams
              (
                p_id_rep IN NUMBER DEFAULT NULL ,
                p_id_param_name IN NUMBER DEFAULT NULL ,
                p_descr IN VARCHAR2 DEFAULT NULL 
              )
              AS
                 /* Now add the default value of this parameter to all instances of this report 
                                First get all the instances this report has and load them in a cursor */
                 p_IDInstance NUMBER(10,0);
                 CURSOR p_AllInstances_Cursor
                   IS SELECT id_rep_instance_id 
                   FROM t_export_report_instance 
                  WHERE id_rep = p_id_rep;
              
              BEGIN
                 /* Assign Parameter to the report */
                 INSERT INTO t_export_report_params
                   ( id_rep, id_param_name, descr )
                   VALUES ( p_id_rep, p_id_param_name, p_descr );
                 OPEN p_AllInstances_Cursor;
                 FETCH p_AllInstances_Cursor INTO p_IDInstance;
                 WHILE p_AllInstances_Cursor%FOUND 
                 LOOP 
                    
                    BEGIN
                       INSERT INTO t_export_default_param_values
                          (id_rep_instance_id, id_param_name, c_param_value)
                          ( SELECT eri.id_rep_instance_id,
                                  erp.id_param_name,
                                  'UNDEFINED'   
                           FROM t_export_report_params erp
                                  JOIN t_export_report_instance eri
                                   ON erp.id_rep = eri.id_rep
                            WHERE erp.id_rep = p_id_rep
                                    AND eri.id_rep_instance_id = p_IDInstance
                                    AND erp.id_param_name = p_id_param_name
                                    AND erp.id_param_name NOT IN ( SELECT id_param_name 
                                                                   FROM t_export_default_param_values 
                                                                    WHERE id_rep_instance_id = p_IDInstance
                                                                            AND id_param_name = p_id_param_name )
                          );
                       FETCH p_AllInstances_Cursor INTO p_IDInstance;
                    END;
                 END LOOP;
                 CLOSE p_AllInstances_Cursor;
              END;
	 