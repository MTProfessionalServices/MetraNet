                                       
              CREATE OR REPLACE PROCEDURE Export_CreateReportDefinition
              (
                v_c_report_title IN VARCHAR2 DEFAULT NULL ,
                v_c_rep_type IN VARCHAR2 DEFAULT NULL ,
                v_c_rep_def_source IN VARCHAR2 DEFAULT NULL ,
                iv_c_rep_query_source IN VARCHAR2 DEFAULT NULL ,
                v_c_rep_query_tag IN VARCHAR2 DEFAULT NULL ,
                iv_ParameterNames IN VARCHAR2 DEFAULT NULL ,
                v_id_rep OUT NUMBER
              )
              AS
                 v_c_rep_query_source VARCHAR2(255) := iv_c_rep_query_source;
                 v_ParameterNames VARCHAR2(4000) := iv_ParameterNames;
                 v_temp NUMBER(1, 0) := 0;
                 v_ipos NUMBER(10,0);
                 v_inextpos NUMBER(10,0);
                 v_paramname VARCHAR2(100);
                 v_paramnameid NUMBER(10,0);
              
              BEGIN                
                 BEGIN
                    SELECT 1 INTO v_temp
                      FROM DUAL
                     WHERE EXISTS ( SELECT id_rep 
                                    FROM t_export_reports 
                                     WHERE c_report_title = v_c_report_title );
                 EXCEPTION
                    WHEN OTHERS THEN
                       NULL;
                 END;
                    
                 IF v_temp = 1 THEN
                 
                 BEGIN
                    SELECT id_rep 
              
                      INTO v_id_rep
                      FROM t_export_reports 
                     WHERE c_report_title = v_c_report_title;
                    RETURN;
                 END;
                 END IF;
                 INSERT INTO t_export_reports
                   ( c_report_title, c_rep_type, c_rep_def_source, c_rep_query_source, c_rep_query_tag )
                   VALUES ( v_c_report_title, v_c_rep_type, v_c_rep_def_source, v_c_rep_query_source, v_c_rep_query_tag )
                   RETURNING id_rep INTO v_id_rep;
                 v_ipos := 0 ;
                 v_inextpos := 0 ;
                 IF LENGTH(NVL(v_ParameterNames, '')) > 0 THEN
                 
                 BEGIN
                    /* Create parameters for this report definition */
                    /* Parse the comma seperated string to get the information for this. */
                    /* fix the comma separated string if the last char is not a comma(",") */
                    v_ParameterNames := LTRIM(v_ParameterNames) ;
                    v_ParameterNames := RTRIM(v_ParameterNames) ;
                    IF SUBSTR(v_ParameterNames, NVL(LENGTH(v_ParameterNames), 0), 1) <> ',' THEN
                       v_ParameterNames := v_ParameterNames || ',' ;
                    END IF;
                    v_inextpos := INSTR(v_ParameterNames, ',', v_ipos) ;
                    WHILE v_inextpos > 0 
                    LOOP 
                       DECLARE
                          v_temp NUMBER(1, 0) := 0;
                       
                       BEGIN
                          v_paramname := SUBSTR(v_ParameterNames, v_ipos, v_inextpos - v_ipos) ;
                          BEGIN
                             SELECT 1 INTO v_temp
                               FROM DUAL
                              WHERE EXISTS ( SELECT * 
                                             FROM t_export_param_names 
                                              WHERE c_param_name = v_paramname );
                          EXCEPTION
                             WHEN OTHERS THEN
                                NULL;
                          END;
                             
                          IF v_temp = 1 THEN
                             SELECT id_param_name 
              
                               INTO v_paramnameid
                               FROM t_export_param_names 
                              WHERE c_param_name = v_paramname;
                          ELSE
                          
                          BEGIN
                             INSERT INTO t_export_param_names
                               ( c_param_name )
                               VALUES ( v_paramname )
                             RETURNING id_param_name INTO v_paramnameid;
                          END;
                          END IF;
                          INSERT INTO t_export_report_params
                            ( id_param_name, id_rep )
                            VALUES ( v_paramnameid, v_id_rep );
                          v_ipos := v_inextpos + 1 ;
                          v_inextpos := INSTR(v_ParameterNames, ',', v_ipos) ;
                       END;
                    END LOOP;
                 END;
                 END IF;
                 RETURN;
              END;
       